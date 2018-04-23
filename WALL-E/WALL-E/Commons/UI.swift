//
//  UI.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit


struct UI<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

protocol UICompatible {
    associatedtype CompatibleType
    static var ui: UI<CompatibleType>.Type { get }
    var ui: UI<CompatibleType> { get }
}

extension UICompatible {
    var ui: UI<Self> {
        return UI(self)
    }
    
    static var ui: UI<Self>.Type {
        return UI<Self>.self
    }
}

extension NSObject: UICompatible { }

extension UIView {
    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
}

// Theme
final class Theme {
    final class Refreshable {
        private(set) weak var target: AnyObject?
        private(set) var keyPath: AnyKeyPath
        private(set) var refresh: () -> ()
        
        init(target: AnyObject, keyPath: AnyKeyPath, refresh: @escaping () -> ()) {
            self.target = target
            self.keyPath = keyPath
            self.refresh = refresh
        }
        
        func isAvailable() -> Bool {
            return target != nil
        }
        
        func isFor(keyPath: AnyKeyPath, target: AnyObject) -> Bool {
            return self.keyPath == keyPath && self.target === target
        }
        
        func execute() { refresh() }
    }

    static let shared = Theme()
    private init() { }
    
    private var _refreshables: [PartialKeyPath<Theme>: [Refreshable]] = [:]
    private let _lock = NSRecursiveLock()

    fileprivate func addRefreshable(_ refreshable: Refreshable, for keyPath: PartialKeyPath<Theme>) {
        _lock.lock(); defer { _lock.unlock() }
        if _refreshables[keyPath] != nil {
            _refreshables[keyPath]?.append(refreshable)
        } else {
            _refreshables[keyPath] = [refreshable]
        }
    }
    
    fileprivate func removeRefreshables(themeKeyPath: PartialKeyPath<Theme>, for keyPath: AnyKeyPath, target: AnyObject) {
        _lock.lock(); defer { _lock.unlock() }
        _refreshables[themeKeyPath] = _refreshables[themeKeyPath]?.filter { !$0.isFor(keyPath: keyPath, target: target) }
    }
    
    var mainColor: UIColor = UIColor(rgb: Theme.colors[0])

    func refresh<V>(keyPath: ReferenceWritableKeyPath<Theme, V>, to value: V) {
        _lock.lock(); defer { _lock.unlock() }
        self[keyPath: keyPath] = value
        _refreshables[keyPath] = _refreshables[keyPath]?.filter(flip(Refreshable.isAvailable)())
        _refreshables[keyPath]?.forEach(flip(Refreshable.execute)())
    }
}

extension UI where Base: AnyObject {
    func adapt<V>(themeKeyPath: KeyPath<Theme, V>, for keyPath: ReferenceWritableKeyPath<Base, V>) {
        let refreshable = Theme.Refreshable(target: base, keyPath: keyPath) { [weak target = base] in
            target?[keyPath: keyPath] = Theme.shared[keyPath: themeKeyPath]
        }
        Theme.shared.addRefreshable(refreshable, for: themeKeyPath)
        refreshable.execute()
    }
    
    func adapt<V>(themeKeyPath: KeyPath<Theme, V>, for keyPath: ReferenceWritableKeyPath<Base, V?>) {
        let refreshable = Theme.Refreshable(target: base, keyPath: keyPath) { [weak target = base] in
            target?[keyPath: keyPath] = Theme.shared[keyPath: themeKeyPath]
        }
        Theme.shared.addRefreshable(refreshable, for: themeKeyPath)
        refreshable.execute()
    }
    
    func adapt<I, O>(themeKeyPath: KeyPath<Theme, I>, for keyPath: ReferenceWritableKeyPath<Base, O>, mapper: @escaping (I) -> O) {
        let refreshable = Theme.Refreshable(target: base, keyPath: keyPath) { [weak target = base] in
            target?[keyPath: keyPath] = mapper(Theme.shared[keyPath: themeKeyPath])
        }
        Theme.shared.addRefreshable(refreshable, for: themeKeyPath)
        refreshable.execute()
    }
    
    func cancelAdapt(themeKeyPath: PartialKeyPath<Theme>, for keyPath: PartialKeyPath<Base>) {
        Theme.shared.removeRefreshables(themeKeyPath: themeKeyPath, for: keyPath, target: base)
    }
}

// Color
typealias RGB = (r: CGFloat, g: CGFloat, b: CGFloat)
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
    
    convenience init(rgb: RGB, alpha: CGFloat = 1) {
        self.init(r: rgb.r, g: rgb.g, b: rgb.b, alpha: alpha)
    }
}

extension Theme {
    static let colors: [RGB] = [(240, 147, 144)]
}

// Corner
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
