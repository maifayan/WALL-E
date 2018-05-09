//
//  Main.Contacts.ViewModel.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/9.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Main.Contacts {
    final class ViewModel {
        private unowned let _collectionView: UICollectionView
        init(collectionView: UICollectionView) {
            _collectionView = collectionView
        }
    }
}
