//
//  Chat.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/24.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift

extension Chat {
    final class View: UIViewController {
        private let _transition = Transition()

        init() {
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .custom
            transitioningDelegate = _transition
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _headerView = HeaderView()
    }
}

extension Chat.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .white
        view.roundCorners(.allCorners, radius: 16)
        statusBarStyle = .lightContent
        _setupViews()
        _layoutViews()
    }
}

private extension Chat.View {
    func _setupViews() {
        addChildViewController(_headerView)
        view.addSubview(_headerView.view)
        _headerView.didMove(toParentViewController: self)
    }
    
    func _layoutViews() {
        _headerView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _headerView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            _headerView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            _headerView.view.topAnchor.constraint(equalTo: view.topAnchor),
            _headerView.view.heightAnchor.constraint(equalToConstant: ui.headerHeight)
        ])
    }
}

extension UI where Base: Chat.View {
    var headerHeight: CGFloat { return 68 }
}
