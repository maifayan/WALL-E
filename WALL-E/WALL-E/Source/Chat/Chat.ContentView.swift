//
//  Chat.ContentView.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/26.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import LayoutKit
import RxSwift
import RxCocoa
import MessageListener

extension Chat {
    final class ContentView: UITableViewController {
        private let _refresh: Observable<Presenter.ContentViewRefreshing>
        private let _eventCallback: (Event) -> ()
        
        init(refresh: Observable<Presenter.ContentViewRefreshing>, eventCallback: @escaping (Event) -> ()) {
            _refresh = refresh
            _eventCallback = eventCallback
            super.init(style: .plain)
        }
        
        deinit {
            log()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _revealer = AccessoryViewRevealer(tableView: tableView)
        private lazy var _adapter = ReloadableViewLayoutAdapter(reloadableView: tableView)
        
        // Variable
        private var _isScrollTooFar = false
    }
}

extension Chat.ContentView {
    enum Event {
        case tap
        case scrollTooFar(Bool)
    }
}

extension Chat.ContentView {
    override func viewDidLoad() {
        super.viewDidLoad()
        _bindEvents()
        _setupTableView()
    }
}

// MARK: - DataSource
extension Chat.ContentView {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return _adapter.currentArrangement.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _adapter.currentArrangement[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ui.reuseIdentifier, for: indexPath) as! Chat.Cell
        // Item
        let item = _adapter.currentArrangement[indexPath.section].items[indexPath.item]
        item.makeViews(in: cell.contentView)
        // Date
        cell.message = "16:20"
        return cell
    }
}

private extension Chat.ContentView {
    func _setupTableView() {
        tableView.register(Chat.Cell.self, forCellReuseIdentifier: ui.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.delegate = _adapter
        // Activate revealer
        _ = _revealer
    }
    
    func _reload(layouts: [Layout], batchUpdates: BatchUpdates?) {
        _adapter.reload(width: view.width, synchronous: false, batchUpdates: batchUpdates, layoutProvider: {
            return [Section(header: nil, items: layouts, footer: nil)]
        }) { [weak self] in
            if batchUpdates == nil {
                DispatchQueue.main.async {
                    self?._scrollToBottom(animated: false)
                }
            }
        }
    }
    
    func _bindEvents() {
        // In
        _refresh.subscribeOnMain(onNext: { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .nodes(let layouts, let batchUpdates):
                self._reload(layouts: layouts, batchUpdates: batchUpdates)
            case .scrollWithKeyboard(let info):
                guard self._isOnBottom == true else { return }
                UIView.animate(withDuration: info.duration, delay: 0, options: info.animationOptions, animations: {
                    self.tableView.contentOffset.y -= info.constant
                })
            case .scrollToBottom:
                self._scrollToBottom()
            }
        }).disposed(by: rx.disposeBag)
        
        // Out
        view.tap { [weak self] _ in self?._eventCallback(.tap) }
        _adapter.listen(#selector(UITableViewDelegate.scrollViewDidScroll(_:)), in: UITableViewDelegate.self) { [weak self] _ in
            guard let `self` = self else { return }
            let offsetY = self.tableView.contentOffset.y
            let flag = offsetY < self._bottomOffset.y - 2 * UIScreen.main.bounds.height
            guard self._isScrollTooFar != flag else { return }
            self._eventCallback(.scrollTooFar(flag))
            self._isScrollTooFar = flag
        }
    }
}

private extension Chat.ContentView {
    var _isOnBottom: Bool {
        return (tableView.contentOffset.y - (tableView.contentSize.height - tableView.height))._standard >= 0
    }
    
    var _bottomOffset: CGPoint {
        return CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
    }
    
    func _scrollToBottom(animated: Bool = true) {
        tableView.setContentOffset(_bottomOffset, animated: animated)
    }
}

extension UI where Base: Chat.ContentView {
    var reuseIdentifier: String { return "Chat.Identifier" }
}

fileprivate extension CGFloat {
    // 四舍五入取两位小数
    var _standard: CGFloat {
        return CGFloat(lroundf(Float(self) * 100)) / 100
    }
}
