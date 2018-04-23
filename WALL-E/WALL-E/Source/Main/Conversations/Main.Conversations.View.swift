//
//  Main.Conversations.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import LayoutKit
import RxSwift

extension Main.Conversations {
    final class View: UIViewController {
        private lazy var _tableView: UITableView = {
            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.separatorStyle = .none
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView.backgroundColor = .clear
            return tableView
        }()
        
        private lazy var _adapter: ReloadableViewLayoutAdapter = {
            let adapter = ReloadableViewLayoutAdapter(reloadableView: _tableView)
            _tableView.register(_Cell.self, forCellReuseIdentifier: View.cellIdentifier)
            _tableView.delegate = adapter
            _tableView.dataSource = adapter
            return adapter
        }()
        
        static let cellIdentifier = String(describing: ReloadableViewLayoutAdapter.self)
    }
}

extension Main.Conversations.View {
    override func loadView() {
        super.loadView()
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(_tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _tableView.frame = view.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        _render(width: size.width)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _render()
    }
}

private extension Main.Conversations.View {
    func _render(width: CGFloat = UIScreen.main.bounds.width) {
        _adapter.reload(
            width: width,
            synchronous: false,
            batchUpdates: nil,
            layoutProvider: _provider
        )
    }
    
    var _provider: () -> [Section<[Layout]>] {
        return { [weak self] in
            return [Section(
                header: nil,
                items: Array(repeating: Main.Conversations.Item(conversation: "Hello"), count: 27),
                footer: nil
            )]
        }
    }
}

extension Main.Conversations.View: MenuButtonDisplayController {
    var showMenuButton: Observable<Bool> {
        return _tableView.verticalScrollDirection.map { $0 == .down }
    }
}

// MARK: - NonBackgroundCell
private extension Main.Conversations.View {
    final class _Cell: UITableViewCell {
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
