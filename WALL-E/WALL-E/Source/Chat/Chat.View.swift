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
        private lazy var _presenter = Presenter(self)

        init() {
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .custom
            transitioningDelegate = _transition
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _headerView = HeaderView()
        private lazy var _inputView = InputView()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

private extension Chat.View {
    func _setupViews() {
        addChildViewController(_headerView)
        view.addSubview(_headerView.view)
        _headerView.didMove(toParentViewController: self)
        
        addChildViewController(_inputView)
        view.addSubview(_inputView.view)
        _inputView.didMove(toParentViewController: self)
    }
    
    func _layoutViews() {
        _headerView.view.translatesAutoresizingMaskIntoConstraints = false
        _inputView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let inputViewBottomAnchor: NSLayoutYAxisAnchor = {
            if #available(iOS 11, *) {
                return view.safeAreaLayoutGuide.bottomAnchor
            } else {
                return view.bottomAnchor
            }
        }()
        
        let inputViewBottomConstraint = _inputView.view.bottomAnchor.constraint(equalTo: inputViewBottomAnchor)
        _presenter.fitKeyboard(for: inputViewBottomConstraint)

        NSLayoutConstraint.activate([
            _headerView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            _headerView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            _headerView.view.topAnchor.constraint(equalTo: view.topAnchor),
            _headerView.view.heightAnchor.constraint(equalToConstant: ui.headerHeight),
            
            _inputView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            _inputView.view.rightAnchor.constraint(equalTo: view.rightAnchor),

            inputViewBottomConstraint
        ])
    }
}

extension UI where Base: Chat.View {
    var headerHeight: CGFloat { return 68 }
}
