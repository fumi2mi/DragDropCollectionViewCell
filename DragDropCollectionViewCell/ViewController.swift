//
//  ViewController.swift
//  DragDropCollectionViewCell
//
//  Created by Fumitaka Imamura on 2021/11/05.
//

import UIKit

class ViewController: UICollectionViewController {
    static let cellIndentifier = "Cell"

    var names = ["First", "Second", "Third", "Fourth", "Fifth"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        names.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIndentifier, for: indexPath) as! CollectionViewCell
        cell.label.text = names[indexPath.row]
        return cell
    }
}

extension ViewController: UICollectionViewDragDelegate {
    // ドラッグ中のItemを指定
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: names[indexPath.row] as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    // Dropしたときの動作
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destination: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destination = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destination = IndexPath(row: row, section: section)
        }

        for (index, item) in coordinator.items.enumerated() {
            let indexPath = IndexPath(row: destination.row + index,
                                      section: destination.section)
            guard let sourceIndexPath = item.sourceIndexPath else { return }
            collectionView.performBatchUpdates ({
                let name = names.remove(at: sourceIndexPath.item)
                names.insert(name, at: indexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [indexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: indexPath)
        }
    }

    // ドラッグ中の動作
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            if session.items.count > 1 {
                return UICollectionViewDropProposal(operation: .cancel)
            } else {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
}

// 画面表示の設定
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGFloat = self.view.bounds.width / 3 - 2
        return CGSize(width: cellSize, height: cellSize)
    }
}
