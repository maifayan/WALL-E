//
//  Main.Conversations.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RealmSwift
import LayoutKit
import RxSwift

extension Main.Conversations {
    final class View: UIViewController {
        private let _context: Context
        private var _token: NotificationToken?
        private var _messages: Results<Message>?

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
        _adapter.listen(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), in: UITableViewDelegate.self) { [weak self] in
            guard $0.count == 2, let indexPath = $0[1] as? IndexPath, let context = self?._context, let contact = self?._messages?[indexPath.row].other else { return }
            let view = Chat.View(context: context, contact: contact)
            self?.present(view, animated: true, completion: nil)
            self?._tableView.deselectRow(at: indexPath, animated: true)
        }
        _tableView.delegate = _adapter
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
        _setupRender()
    }
}

private extension Main.Conversations.View {
    func _setupRender() {
        let results = _context.auto.main.objects(Message.self).filter("typeValue != %@", Message.MessageType.typing.rawValue).sorted(byKeyPath: "updatedAt", ascending: false).distinct(by: ["conversationId"])
        _token = results.observe { [weak self] changes in
            switch changes {
            case .initial:
                self?._render()
            case .update(_, let deletions, let insertions, let modifications):
                self?._render(updates: (insert: insertions, delete: deletions, reload: modifications))
            default: ()
            }
        }
        _messages = results
    }
    
    func _render(width: CGFloat = UIScreen.main.bounds.width, updates: (insert: [Int], delete: [Int], reload: [Int])? = nil) {
        let bu: BatchUpdates? = {
            guard let updates = updates else { return nil }
            let bu = BatchUpdates()
            bu.insertItems.append(contentsOf: updates.insert.map { IndexPath(row: $0, section: 0) })
            bu.deleteItems.append(contentsOf: updates.delete.map { IndexPath(row: $0, section: 0) })
            bu.reloadItems.append(contentsOf: updates.reload.map { IndexPath(row: $0, section: 0) })
            return bu
        }()
        
        _adapter.reload(
            width: width,
            synchronous: true,
            batchUpdates: bu,
            layoutProvider: _provider
        )
    }
    
    var _provider: () -> [Section<[Layout]>] {
        return { [weak self] in
            return [Section(
                header: nil,
                items: self?._messages?.map(Main.Conversations.Item.init) ?? [],
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
