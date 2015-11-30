# SwiftGen

[![CI Status](http://img.shields.io/travis/AliSoftware/SwiftGen.svg?style=flat)](https://travis-ci.org/AliSoftware/SwiftGen)

SwiftGen is a suite of tools written in Swift 2 to auto-generate Swift 2 code for various assets of your project:

* [`enums` for your Assets Catalogs](#uiimage)
* [`enums` for your `Localizable.strings` strings](#localizablestrings).
* [`enums` for your `UIStoryboard` and their Scenes](#uistoryboard)
* [`enums` for your `UIColor`s](#uicolor).

## Installation

> Note: The tools are written in Swift 2.0 and need to be compiled with the latest Xcode 7.  
> 
> For a list of recent changes, see the [CHANGELOG](CHANGELOG.md).

### Via Homebrew

To install SwiftGen via [Homebrew](http://brew.sh), simply use:

```sh
$ brew update
$ brew install swiftgen
```

### Compile from source

Alternatively, you can clone the repository and use `rake install` to build the tool.  
_With this solution you're sure to build and install the latest version from `master`._

You can install to the default locations (no parameter) or to custom locations:

```sh
# Binary is installed in `./swiftgen/bin`, frameworks in `./swiftgen/lib` and templates in `./swiftgen/templates`
$ rake install
# - OR -
# Binary will be installed in `~/swiftgen/bin`, framworks in `~/swiftgen/fmk` and templates in `~/swiftgen/tpl`
$ rake install[~/swiftgen/bin,~/swiftgen/fmk,~/swiftgen/tpl]
```

## Usage

The tool is provided as a unique `swiftgen` binary command-line, with the following subcommands:

* `swiftgen images [OPTIONS] DIR`
* `swiftgen strings [OPTIONS] FILE`
* `swiftgen storyboards [OPTIONS] DIR`
* `swiftgen colors [OPTIONS] FILE`

Each subcommand has its own option and syntax, but some options are common to all:

* `--output FILE`: set the file where to write the generated code. If omitted, the generated code will be printed on `stdout`.
* `--template NAME`: define the Stencil template to use (by name, see [here for more info](documentation/Templates.md#using-a-name)) to generate the output.
* `--templatePath PATH`: define the Stencil template to use, using a full path.

You can use `--help` on `swiftgen` or one of its subcommand to see the detailed usage.

## Templates

SwiftGen uses [Stencil](https://github.com/kylef/Stencil) as its template engine.

It comes bundled with some default templates for each of the subcommand (`colors`, `images`, `strings`, `storyboard`, …), but you can also create your own templates if the defaults don't suit your coding conventions or needs. Simply store them in `~/Library/Application Support/SwiftGen/templates`, then use the `-t` / `--template` option to specify the name of the template to use.

💡 You can use the `swiftgen templates` command to list all the available templates (both custom and bundled templates) for each subcommand.

For more information about how to create your own templates, [see the dedicated documentation](documentation/Templates.md).

> Don't hesitate to make PRs share your improvements suggestions on the default templates 😉

## Playground

The `SwiftGen.playground` available in this repository will allow you to play with the code that the tools typically generates, and see some examples of how you can take advantage of it.

This allows you to have a quick look at how typical code generated by SwiftGen looks like, and how you will then use the generated enums in your code.

> Note: The playground is in the Xcode 7 format, and uses its new concept of "Playground pages" to regroup multiple playground pages in a single Playground.

---

## UIImage

```
swiftgen images /dir/to/search/for/imageset/assets
```

This will generate an `enum Asset` in an extension of `UIImage`, with one `case` per image asset in your assets catalog, so that you can use them as constants.

### Generated code

The generated code will look like this:

```swift
extension UIImage {
  enum Asset : String {
    case GreenApple = "Green-Apple"
    case RedApple = "Red-Apple"
    case Banana = "Banana"
    case BigPear = "Big_Pear"
    case StopButtonEnabled = "stop.button.enabled"
    
    var image: UIImage {
      return UIImage(named: self.rawValue)!
    }
  }
      
  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
```

### Usage Example

```swift
let image1 = UIImage(asset: .Banana)   // Prefered way
let image2 = UIImage.Asset.Apple.image // Alternate way
```

This way, no need to enter the `"Banana"` string in your code and risk any typo.

### Benefits & Limitations

There are multiple benefits in using this:

* Avoid any typo you could have when using a String
* Free auto-completion
* Avoid the risk to use an non-existing asset name
* All this will be ensured by the compiler.

Note that this script only generate extensions and code compatible with `UIKit` and `UIImage`. It would be nice to have an option to generate OSX code in the future.


## Localizable.strings

```
swiftgen strings /path/to/Localizable.strings
```

This will generate a Swift `enum L10n` that will map all your `Localizable.strings` keys to an `enum case`. Additionaly, if it detects placeholders like `%@`,`%d`,`%f`, it will add associated values to that `case`.

### Generated code

Given the following `Localizable.strings` file:

```swift
"alert_title" = "Title of the alert";
"alert_message" = "Some alert body there";
"greetings" = "Hello, my name is %@ and I'm %d";
"apples.count" = "You have %d apples";
"bananas.owner" = "Those %d bananas belong to %@.";
```

The generated code will contain this:

```swift
enum L10n {
  /// Title of the alert
  case AlertTitle
  /// Some alert body there
  case AlertMessage
  /// Hello, my name is %@ and I'm %d
  case Greetings(String, Int)
  /// You have %d apples
  case ApplesCount(Int)
  /// Those %d bananas belong to %@.
  case BananasOwner(Int, String)
}

extension L10n : CustomStringConvertible {
  var description : String { return self.string }

  var string : String {
    /* Implementation Details */
  }
  ...
}

func tr(key: L10n) -> String {
  return key.string
}
```

### Usage Example

Once the code has been generated by the script, you can use it this way in your Swift code:

```swift
let title = L10n.AlertTitle.string
// -> "Title of the Alert"

// Alternative syntax, shorter
let msg = tr(.AlertMessage)
// -> "Some alert body there"

// Strings with parameters
let nbApples = tr(.ApplesCount(5))
// -> "You have 5 apples"

// More parameters of various types!
let ban = tr(.BananasOwner(2, "John"))
// -> "Those 2 bananas belong to John."
```

## UIStoryboard

```
swiftgen storyboards /dir/to/search/for/storyboards
```

This will generate an `enum` for each of your `UIStoryboard`, with one `case` per storyboard scene.

### Generated code

The generated code will look like this:

```swift
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
    enum Message : String, StoryboardSceneType {
      static let storyboardName = "Message"

      case Composer = "Composer"
      static func composerViewController() -> UIViewController {
        return Message.Composer.viewController()
      }

      case URLChooser = "URLChooser"
      static func urlChooserViewController() -> XXPickerViewController {
        return Message.URLChooser.viewController() as! XXPickerViewController
      }
    }
    enum Wizard : String, StoryboardSceneType {
      static let storyboardName = "Wizard"

      case CreateAccount = "CreateAccount"
      static func createAccountViewController() -> CreateAccViewController {
          return Wizard.CreateAccount.viewController() as! CreateAccViewController
      }

      case ValidatePassword = "Validate_Password"
      static func validatePasswordViewController() -> UIViewController {
          return Wizard.ValidatePassword.viewController()
      }
    }
  }

  struct Segue {
    enum Message : String, StoryboardSegueType {
      case Back = "Back"
      case Custom = "Custom"
      case NonCustom = "NonCustom"
    }
  }
}
```

### Usage Example

```swift
// Initial VC
let initialVC = UIStoryboard.Scene.Wizard.initialViewController()
// Generic ViewController constructor, returns a UIViewController instance
let validateVC = UIStoryboard.Scene.Wizard.ValidatePassword.viewController()
// Dedicated type var that returns the right type of VC (CreateAccViewController here)
let createVC = UIStoryboard.Scene.Wizard.createAccountViewController()

override func prepareForSegue(_ segue: UIStoryboardSegue, sender sender: AnyObject?) {
  switch UIStoryboard.Segue.Message(rawValue: segue.identifier)! {
  case .Back:
    // Prepare for your custom segue transition
  case .Custom:
    // Prepare for your custom segue transition
  case .NonCustom:
    // Prepare for your custom segue transition
  }
}

initialVC.performSegue(UIStoryboard.Segue.Message.Back)
```


## UIColor

```
swiftgen colors /path/to/colors-file.txt
```

This will generate a `enum Name` in an extension of `UIColor`, with one `case` per color listed in the text file passed as argument.

The text file is expected to have one line per color to register, each line being composed by the Name to give to the color, followed by ":", followed by the Hex representation of the color (like `rrggbb` or `rrggbbaa`, optionally prefixed by `#` or `0x`). Whitespaces are ignored.

### Generated code

Given the following `colors.txt` file:

```
Cyan         : 0xff66ccff
ArticleTitle : #33fe66
ArticleBody  : 339666
Translucent  : ffffffcc
```

The generated code will look like this:

```swift
extension UIColor {
  /* Private Implementation details */
  ...
}

extension UIColor {
  enum Name : UInt32 {
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
    /// Alpha: 80% <br/> (0xffffffcc)
    case Translucent = 0xffffffcc
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#339666"></span>
    /// Alpha: 100% <br/> (0x339666ff)
    case ArticleBody = 0x339666ff
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff66cc"></span>
    /// Alpha: 100% <br/> (0xff66ccff)
    case Cyan = 0xff66ccff
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#33fe66"></span>
    /// Alpha: 100% <br/> (0x33fe66ff)
    case ArticleTitle = 0x33fe66ff
  }

  convenience init(named name: Name) {
    self.init(rgbaValue: name.rawValue)
  }
}
```

### Usage Example

```swift
UIColor(named: .ArticleTitle)
UIColor(named: .ArticleBody)
UIColor(named: .Translucent)
```

This way, no need to enter the color red, green, blue, alpha values each time and create ugly constants in the global namespace for them.


---


# License

This code and tool is under the MIT License. See `LICENSE` file in this repository.

It also relies on [`Stencil`](https://github.com/kylef/Stencil/blob/master/LICENSE), [`Commander`](https://github.com/kylef/Commander/blob/master/LICENSE) and [`PathKit`](https://github.com/kylef/PathKit/blob/master/LICENSE) licenses.

Any ideas and contributions welcome!
