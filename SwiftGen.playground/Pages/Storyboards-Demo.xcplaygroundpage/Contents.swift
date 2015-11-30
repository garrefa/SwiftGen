//: #### Other pages
//:
//: * [Demo for `swiftgen strings`](Strings-Demo)
//: * [Demo for `swiftgen images`](Images-Demo)
//: * Demo for `swiftgen storyboards`
//: * [Demo for `swiftgen colors`](Colors-Demo)

import UIKit

class CreateAccViewController : UIViewController {}

//: #### Example of code generated by swiftgen-storyboard

// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardSceneType {
    static var storyboardName : String { get }
}

extension StoryboardSceneType {
    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: nil)
    }
    
    static func initialViewController() -> UIViewController {
        return storyboard().instantiateInitialViewController()!
    }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
    func viewController() -> UIViewController {
        return Self.storyboard().instantiateViewControllerWithIdentifier(self.rawValue)
    }
    static func viewController(identifier: Self) -> UIViewController {
        return identifier.viewController()
    }
}

protocol StoryboardSegueType : RawRepresentable { }

extension UIViewController {
  func performSegue<S : StoryboardSegueType where S.RawValue == String>(segue: S, sender: AnyObject? = nil) {
    performSegueWithIdentifier(segue.rawValue, sender: sender)
  }
}

extension UIStoryboard {
    struct Scene {
        enum Wizard : String, StoryboardSceneType {
            static let storyboardName = "Wizard"
            
            case CreateAccount = "CreateAccount"
            static func createAccountViewController() -> CreateAccViewController {
                return Wizard.CreateAccount.viewController() as! CreateAccViewController
            }
            
            case AcceptCGU = "Accept-CGU"
            static func acceptCGUViewController() -> UIViewController {
                return Wizard.AcceptCGU.viewController()
            }
            
            case ValidatePassword = "Validate_Password"
            static func validatePasswordViewController() -> UIViewController {
                return Wizard.ValidatePassword.viewController()
            }
            
            case Preferences = "Preferences"
            static func preferencesViewController() -> UIViewController {
                return Wizard.Preferences.viewController()
            }
        }
    }
    
  struct Segue {
        enum Wizard : String, StoryboardSegueType {
            case Custom = "Custom"
            case Back = "Back"
            case NonCustom = "NonCustom"
            case ShowPassword = "ShowP//: #### Usage Example
assword"
        }
    }
}


let initialVC = UIStoryboard.Scene.Wizard.initialViewController()
initialVC.title

let validateVC = UIStoryboard.Scene.Wizard.ValidatePassword.viewController()
validateVC.title

/* Note: the following line would crash when run in playground, because the storyboard file
   was not compiled alongside the playground code, so the CreateAccViewController class was
   not known by the storyboard. But it should work correctly in a real project. */
// let cgu = UIStoryboard.Scene.Wizard.createAccountViewController()

let segue = UIStoryboard.Segue.Wizard.ShowPassword
initialVC.performSegue(segue)

switch segue {
  case .ShowPassword:
    print("Working! 🎉")
  default:
    print("Not working! 😱")
}

/*******************************************************************************
This is a «real world» example of how you can benefit from the generated enum;
you can easily switch or directly compare the passed in `segue` with the corresponding
segues for a specific storyboard.
*******************************************************************************/
//override func prepareForSegue(_ segue: UIStoryboardSegue, sender sender: AnyObject?) {
//  switch UIStoryboard.Segue.Message(rawValue: segue.identifier)! {
//  case .Custom:
//    // Prepare for your custom segue transition
//  case .NonCustom:
//    // Pass in information to the destinatio