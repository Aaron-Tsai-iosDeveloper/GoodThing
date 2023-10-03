//
//  CustomCollectionView.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/3.
//

import UIKit

class CustomCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let customLayout = UICollectionViewFlowLayout()
        customLayout.scrollDirection = .vertical
        customLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        customLayout.minimumLineSpacing = 100
        super.init(frame: frame, collectionViewLayout: customLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
