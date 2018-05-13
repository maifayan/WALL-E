//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 colors.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 0 files.
  struct file {
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 0 fonts.
  struct font {
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 14 images.
  struct image {
    /// Image `account_ok`.
    static let account_ok = Rswift.ImageResource(bundle: R.hostingBundle, name: "account_ok")
    /// Image `chat_back`.
    static let chat_back = Rswift.ImageResource(bundle: R.hostingBundle, name: "chat_back")
    /// Image `chat_images`.
    static let chat_images = Rswift.ImageResource(bundle: R.hostingBundle, name: "chat_images")
    /// Image `chat_keyboard`.
    static let chat_keyboard = Rswift.ImageResource(bundle: R.hostingBundle, name: "chat_keyboard")
    /// Image `chat_send`.
    static let chat_send = Rswift.ImageResource(bundle: R.hostingBundle, name: "chat_send")
    /// Image `chat`.
    static let chat = Rswift.ImageResource(bundle: R.hostingBundle, name: "chat")
    /// Image `close_menu`.
    static let close_menu = Rswift.ImageResource(bundle: R.hostingBundle, name: "close_menu")
    /// Image `edit`.
    static let edit = Rswift.ImageResource(bundle: R.hostingBundle, name: "edit")
    /// Image `menu_robot`.
    static let menu_robot = Rswift.ImageResource(bundle: R.hostingBundle, name: "menu_robot")
    /// Image `menu_settings`.
    static let menu_settings = Rswift.ImageResource(bundle: R.hostingBundle, name: "menu_settings")
    /// Image `menu_theme`.
    static let menu_theme = Rswift.ImageResource(bundle: R.hostingBundle, name: "menu_theme")
    /// Image `menu`.
    static let menu = Rswift.ImageResource(bundle: R.hostingBundle, name: "menu")
    /// Image `robot`.
    static let robot = Rswift.ImageResource(bundle: R.hostingBundle, name: "robot")
    /// Image `scroll_bottom`.
    static let scroll_bottom = Rswift.ImageResource(bundle: R.hostingBundle, name: "scroll_bottom")
    
    /// `UIImage(named: "account_ok", bundle: ..., traitCollection: ...)`
    static func account_ok(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.account_ok, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "chat", bundle: ..., traitCollection: ...)`
    static func chat(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.chat, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "chat_back", bundle: ..., traitCollection: ...)`
    static func chat_back(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.chat_back, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "chat_images", bundle: ..., traitCollection: ...)`
    static func chat_images(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.chat_images, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "chat_keyboard", bundle: ..., traitCollection: ...)`
    static func chat_keyboard(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.chat_keyboard, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "chat_send", bundle: ..., traitCollection: ...)`
    static func chat_send(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.chat_send, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "close_menu", bundle: ..., traitCollection: ...)`
    static func close_menu(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.close_menu, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "edit", bundle: ..., traitCollection: ...)`
    static func edit(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.edit, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "menu", bundle: ..., traitCollection: ...)`
    static func menu(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.menu, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "menu_robot", bundle: ..., traitCollection: ...)`
    static func menu_robot(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.menu_robot, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "menu_settings", bundle: ..., traitCollection: ...)`
    static func menu_settings(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.menu_settings, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "menu_theme", bundle: ..., traitCollection: ...)`
    static func menu_theme(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.menu_theme, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "robot", bundle: ..., traitCollection: ...)`
    static func robot(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.robot, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "scroll_bottom", bundle: ..., traitCollection: ...)`
    static func scroll_bottom(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.scroll_bottom, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 7 nibs.
  struct nib {
    /// Nib `LaunchViewController`.
    static let launchViewController = _R.nib._LaunchViewController()
    /// Nib `LoginView`.
    static let loginView = _R.nib._LoginView()
    /// Nib `MenuContentView`.
    static let menuContentView = _R.nib._MenuContentView()
    /// Nib `ProfileHeaderView`.
    static let profileHeaderView = _R.nib._ProfileHeaderView()
    /// Nib `RegisterView`.
    static let registerView = _R.nib._RegisterView()
    /// Nib `RobotCreationContentView`.
    static let robotCreationContentView = _R.nib._RobotCreationContentView()
    /// Nib `ThemePickerView`.
    static let themePickerView = _R.nib._ThemePickerView()
    
    /// `UINib(name: "LaunchViewController", in: bundle)`
    static func launchViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.launchViewController)
    }
    
    /// `UINib(name: "LoginView", in: bundle)`
    static func loginView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.loginView)
    }
    
    /// `UINib(name: "MenuContentView", in: bundle)`
    static func menuContentView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.menuContentView)
    }
    
    /// `UINib(name: "ProfileHeaderView", in: bundle)`
    static func profileHeaderView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.profileHeaderView)
    }
    
    /// `UINib(name: "RegisterView", in: bundle)`
    static func registerView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.registerView)
    }
    
    /// `UINib(name: "RobotCreationContentView", in: bundle)`
    static func robotCreationContentView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.robotCreationContentView)
    }
    
    /// `UINib(name: "ThemePickerView", in: bundle)`
    static func themePickerView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.themePickerView)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 0 reuse identifiers.
  struct reuseIdentifier {
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try nib.validate()
  }
  
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _LaunchViewController.validate()
      try _LoginView.validate()
      try _MenuContentView.validate()
    }
    
    struct _LaunchViewController: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "LaunchViewController"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> LaunchViewController? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? LaunchViewController
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "robot", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'robot' is used in nib 'LaunchViewController', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    struct _LoginView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "LoginView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> LoginView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? LoginView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "robot", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'robot' is used in nib 'LoginView', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    struct _MenuContentView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "MenuContentView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> _MenuContentView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? _MenuContentView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "menu_robot", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'menu_robot' is used in nib 'MenuContentView', but couldn't be loaded.") }
        if UIKit.UIImage(named: "menu_theme", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'menu_theme' is used in nib 'MenuContentView', but couldn't be loaded.") }
        if UIKit.UIImage(named: "menu_settings", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'menu_settings' is used in nib 'MenuContentView', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    struct _ProfileHeaderView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "ProfileHeaderView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _RegisterView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "RegisterView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> RegisterView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? RegisterView
      }
      
      fileprivate init() {}
    }
    
    struct _RobotCreationContentView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "RobotCreationContentView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> RobotCreationContentView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? RobotCreationContentView
      }
      
      fileprivate init() {}
    }
    
    struct _ThemePickerView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "ThemePickerView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> _ThemePickerView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? _ThemePickerView
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  struct storyboard {
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType {
      typealias InitialController = UIKit.UIViewController
      
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}
