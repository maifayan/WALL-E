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
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _adapter: ReloadableViewLayoutAdapter = {
            let adapter = ReloadableViewLayoutAdapter(reloadableView: tableView)
            tableView.delegate = adapter
            tableView.dataSource = adapter
            return adapter
        }()
    }
}

extension Chat.ContentView {
    enum Event {
        case tap
    }
}

extension Chat.ContentView {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupTableView()
        _bindEvents()
    }
}

private extension Chat.ContentView {
    func _setupTableView() {
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    func _reload(layouts: [Layout], batchUpdates: BatchUpdates?) {
        _adapter.reload(width: view.width, synchronous: false, batchUpdates: batchUpdates, layoutProvider: {
            return [Section(header: nil, items: layouts, footer: nil)]
        })
    }
    
    func _bindEvents() {
        _refresh.subscribeOnMain(onNext: { [weak self] in
            switch $0 {
            case .nodes(let layouts, let batchUpdates):
                self?._reload(layouts: layouts, batchUpdates: batchUpdates)
            case .scroll(let info):
                guard self?._isOnBottom == true else { return }
                UIView.animate(withDuration: info.duration, delay: 0, options: info.animationOptions, animations: {
                    self?.tableView.contentOffset.y -= info.constant
                })
            }
        }).disposed(by: rx.disposeBag)
        
        view.tap { [weak self] _ in self?._eventCallback(.tap) }
    }
}

private extension Chat.ContentView {
    var _isOnBottom: Bool {
        return (tableView.contentOffset.y - (tableView.contentSize.height - tableView.height))._standard >= 0
    }
}

fileprivate extension CGFloat {
    // 四舍五入取两位小数
    var _standard: CGFloat {
        return CGFloat(lroundf(Float(self) * 100)) / 100
    }
}
