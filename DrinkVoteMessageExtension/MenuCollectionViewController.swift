//
//  MenuCollectionViewController.swift
//  DrinkVote MessagesExtension
//
//  Created by Quoc Nguyen on 2018/10/24.
//  Copyright © 2018 Quoc Nguyen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let menuImage = ["add_beer", "add_beer_2", "add_beer_3", "add_beer_4", "add_beer_5", "add_beer_6"]
class MenuCollectionViewController: UICollectionViewController {

    var didSelectAddBeer: ((Int) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuImage.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuCollectionViewCell
        cell.didSelect = { [weak self] in
            self?.didSelectAddBeer?(indexPath.item + 1)
        }
        let image = UIImage(named: menuImage[indexPath.item])?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        cell.button.setImage(image, for: UIControl.State.normal)
        return cell
    }
}

class MenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    var didSelect: (() -> Void)?
    
    @IBAction func touchUpInside(_ sender: Any) {
        self.didSelect?()
    }
}
