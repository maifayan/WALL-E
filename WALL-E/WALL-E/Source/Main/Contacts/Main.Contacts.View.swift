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

private let collectionHeaderIdentifier = "HeaderIdentifier"
extension Main.Contacts {
    final class View: UIViewController {
        private let _context: Context
        
        init(context: Context) {
            _context = context
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            log()
        }
        
        private lazy var _collectionView: UICollectionView = {
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: _layout)
            collectionView.backgroundColor = .clear
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        
        private var _renderer: Renderer<_Cell>!
    }
}

extension Main.Contacts.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(_collectionView)
        _setupRenderer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _collectionView.frame = view.bounds
    }
    
    private func _setupRenderer() {
        let sections = [
            RenderSection(type: _Cell.self, filter: Contact.predicateForMember, sort: nil),
            RenderSection(type: _Cell.self, filter: Contact.predicateForRobot, sort: nil),
        ]
        _renderer = _collectionView.setupRenderer(context: _context, sections: sections)
        // Reset dataSource: Renderer -> Self
        // 为什么要将DataSource从Renderer转移到Self
        // 因为Renderer不提供给CollectionView设置Header、Footer的功能
        // 所以这里要用Self包装Renderer
        _collectionView.dataSource = self
    }
}

extension Main.Contacts.View: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _renderer.numberOfSections(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _renderer.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return _renderer.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: collectionHeaderIdentifier, for: indexPath) as! _Header
        header.title = indexPath.section == 0 ? "Members" : "Robots"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contact = _renderer.entity(of: indexPath)
        present(Profile.View(context: _context, contact: contact), animated: true, completion: nil)
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
        
        private lazy var _avatarView = AvatarView()

        private lazy var _titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.textColor = ui.titleColor
            return label
        }()
        
        private lazy var _contentView: UIView = {
            let view = UIView()
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
    }
}

extension Main.Contacts.View._Cell: RenderItem {
    func render(entity: Contact) {
        _avatarView.set(entity, sizeValue: ui.avatarSizeValue)
        _titleLabel.text = entity.name
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
            _avatarView.widthAnchor.constraint(equalToConstant: ui.avatarSizeValue),
            _avatarView.heightAnchor.constraint(equalToConstant: ui.avatarSizeValue),
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
    var avatarSizeValue: CGFloat { return 68 }
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
