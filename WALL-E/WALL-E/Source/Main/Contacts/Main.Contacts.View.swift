//
//  Main.Contacts.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

private let collectionCellIdentifier = "CellIdentifier"
private let collectionHeaderIdentifier = "HeaderIdentifier"
extension Main.Contacts {
    final class View: UIViewController {
        private lazy var _collectionView: UICollectionView = {
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: _layout)
            collectionView.backgroundColor = .clear
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            collectionView.register(_Cell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
            collectionView.register(_Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier)
            return collectionView
        }()
        
        private lazy var _layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = ui.cellSize
            layout.minimumInteritemSpacing = ui.cellHorizontalSpacing
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = ui.cellVerticalSpacing
            layout.sectionInset = UIEdgeInsets(
                top: 0, left: ui.collectionViewSectionHorizontalInset,
                bottom: 0, right: ui.collectionViewSectionHorizontalInset
            )
            layout.headerReferenceSize = .init(width: UIScreen.main.bounds.width, height: ui.collectionHeaderHeight)
            return layout
        }()
    }
}

extension Main.Contacts.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(_collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _collectionView.frame = view.bounds
    }
}

extension Main.Contacts.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! _Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier, for: indexPath) as! _Header
        switch indexPath.section {
        case 0:
            header.title = "Members"
        case 1:
            header.title = "Robots"
        default:
            fatalError("Impossible!")
        }
        return header
    }
}

extension UI where Base: Main.Contacts.View {
    var cellSize: CGSize { return .init(width: 98, height: 98) }
    var cellHorizontalSpacing: CGFloat { return 16 }
    var cellVerticalSpacing: CGFloat { return 20 }
    var collectionViewSectionHorizontalInset: CGFloat { return 20 }
    var collectionHeaderHeight: CGFloat { return 64 }
}

extension Main.Contacts.View: MenuButtonDisplayController {
    var showMenuButton: Observable<Bool> {
        return _collectionView.verticalScrollDirection.map { $0 == .down }
    }
}

// MARK: - Cell
private extension Main.Contacts.View {
    final class _Cell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            _contentView.addSubview(_avatarView)
            _contentView.addSubview(_titleLabel)
            contentView.addSubview(_contentView)
            _layout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _avatarView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524402344412&di=4a23252a1384630713ed00984077d7aa&imgtype=0&src=http%3A%2F%2Fimg2.ph.126.net%2FiWniabDDa1xwCebyA6-75A%3D%3D%2F6597431505982826060.jpg"
            view.kf.setImage(
                with: URL(string: url),
                options: [
                    .transition(.fade(0.25)),
                    .resizeAndCroppingProcessor(targetSize: ui.avatarSize, withCorner: 0.5 * ui.avatarSize.width)
                ]
            )
            return view
        }()
        
        private lazy var _titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.textColor = ui.titleColor
            label.text = "Tangent"
            return label
        }()
        
        private lazy var _contentView: UIView = {
            let view = UIView()
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
    }
}

private extension Main.Contacts.View._Cell {
    func _layout() {
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _avatarView.translatesAutoresizingMaskIntoConstraints = false
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            _contentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            _contentView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            _avatarView.topAnchor.constraint(equalTo: _contentView.topAnchor),
            _avatarView.widthAnchor.constraint(equalToConstant: ui.avatarSize.width),
            _avatarView.heightAnchor.constraint(equalToConstant: ui.avatarSize.height),
            _avatarView.centerXAnchor.constraint(equalTo: _contentView.centerXAnchor),
            _avatarView.bottomAnchor.constraint(equalTo: _titleLabel.topAnchor, constant: -4),
            
            _titleLabel.leftAnchor.constraint(equalTo: _contentView.leftAnchor),
            _titleLabel.rightAnchor.constraint(equalTo: _contentView.rightAnchor),
            _titleLabel.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor),
        ])
    }
}

extension UI where Base: Main.Contacts.View._Cell {
    var titleColor: UIColor { return UIColor(rgb: triple(123)) }
    var avatarSize: CGSize { return .init(width: 68, height: 68) }
}

// MARK: - Header
private extension Main.Contacts.View {
    final class _Header: UICollectionReusableView {
        var title: String = "" {
            didSet {
                _titleLabel.text = title
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(_titleLabel)
            _titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
                _titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
                _titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                _titleLabel.topAnchor.constraint(equalTo: topAnchor)
            ])
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .gray
            label.font = .systemFont(ofSize: 18, weight: .bold)
            return label
        }()
    }
}
