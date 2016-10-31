# EFTools
iOS Tools for ElevenFifty.  Requires Xcode 8 and Swift 3.

## Table of Contents

* [How To Use](#how-to-use-eftools)
* [Features](#features)	 
  * [Working with a REST Backend](#working-with-a-rest-backend)
  * [Better Segues](#better-segues)
  * [Easier UIColors](#easier-uicolors)
  * [Quick Spinners](#quick-spinners)
  * [Validation](#validation)
  * [Alert Messages](#alert-messages)
  * [Table View Controllers](#table-view-controllers)

## How to use EFTools
If you are already using Cocoapods, this is easy. If you aren't - then start!  Here's a sample Podfile that uses EFTools in Xcode 8:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
xcodeproj 'testapp.xcodeproj'

pod 'EFTools', :git => 'https://github.com/ElevenFifty/EFTools.git', :tag => '3.0'
pod 'Valet', :git => 'https://github.com/square/Valet.git', :branch => 'develop/3.0'
```
**Until Valet moves their Swift 3 branch to master, you must override what EFTools points to in your Podfile**

**You will use tag 1.0.3 for any projects still Using Swift 2.3**

EFTools has many dependencies that will be pulled down for you.  They are as follows:
* AlamoFire (https://github.com/Alamofire/Alamofire)
* Freddy (https://github.com/bignerdranch/Freddy)
* Instabug (https://instabug.com)
* MBProgressHUD (https://github.com/jdg/MBProgressHUD)
* TPKeyboardAvoiding (https://github.com/michaeltyson/tpkeyboardavoiding)
* Valet (https://github.com/square/Valet)

The following are libraries that used to be included in EFTools, but no longer are - projects that you build with previous versions of EFTools may require you to add these libraries:
* AFDateHelper (https://github.com/melvitax/AFDateHelper)
* ParseFacebookUtils
* ParseTwitterUtils
* ParseUI (by default this also pulls in Parse)
* SCLAlertView (https://github.com/vikmeup/SCLAlertView-Swift)
* SwiftyJSON (https://github.com/SwiftyJSON/SwiftyJSON)
* SwiftKeychainWrapper (https://github.com/jrendel/SwiftKeychainWrapper)
* SnapKit (http://snapkit.io/docs/)

**EFTools no longer has a Parse branch, so there are no longer subsets to be pulled down as there was in previous versions**


##Features
####Working with a REST Backend
EFTools greatly simplifies the process of interacting with a REST backend service by giving you the following: EFWebServices and EFNetworkModel (EFWebProtocol is no more!).

To use these, we first start with the EFNetworkModel protocol.  This will drive the connection process.  Here is an example class:

```
import UIKit
import EFTools
import Alamofire
import Freddy

class Model: EFNetworkModel {
    public var patchRemoves: Set<String>?
    public var patchAdds: [String : AnyObject]?
    public var encoding: ParameterEncoding?

    var id: Int?
    var name: String?
    var amount: Double?
    var count: Int?
    
    // requestType is not required - but useful (see switches below)
    var requestType: RequestType = .Recent
    enum RequestType {
        case Create
        case Delete
        case Recent
    }
    
    required ****init() {}
    
    required init(json: JSON) { // REQUIRED METHOD, USED TO PARSE RETURNED JSON
        id = try? json.getInt(at: Constants.Model.id)
        name = try? json.getString(at: Constants.Model.name)
        amount = try? json.getDouble(at: Constants.Expense.amount)
        count = try? json.getInt(at: Constants.Expense.count)
    }
    
    func method() -> Alamofire.Method { // REQUIRED METHOD, USED TO BUILD NETWORK REQUEST
        switch requestType {
        case .Create:
            return .POST
        case .Delete:
            return .DELETE
        case .Recent:
            return .GET
        }
    }
    
    func path() -> String { // REQUIRED METHOD, USED TO BUILD NETWORK REQUEST
        switch requestType {
        case .Create:
            return "/createModel"
        case .Delete:
            return "/deleteModel/\(id!)"
        case .Recent:
            return "/getModels"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? { // REQUIRED METHOD, USED TO BUILD NETWORK REQUEST - WORKS FOR POST BODY AND GET QUERIES
        switch requestType {
        case .Create: // RETURNS A DICTIONARY FOR THE POST BODY
            var params: [String: AnyObject] = [:]
            
            params[Constants.Model.amount] = name
            params[Constants.Model.categoryId] = amount
            params[Constants.Model.latitude] = count
            
            return params
        default: // .Delete AND .Recent DO NOT REQUIRE SENDING ANY PARAMETERS
        	  return nil
        }
    }
    
    func patches() -> [[String: AnyObject]]? { // REQUIRED METHOD, USED TO BUILD PATCH NETWORK REQUEST - SHOULD ALMOST ALWAYS RETURN NIL
        return nil
    }
    
    func headers() -> [String: AnyObject]? { // REQUIRED METHOD, USED TO BUILD PATCH NETWORK REQUEST - SHOULD ALMOST ALWAYS RETURN NIL
        return nil
    }
}
```

To use this model, we would use it in conjuction with EFWebServices.  Functions are already in place to do basic requests, like posting an object, getting object, getting a list of objects, and deleting an object.  For instance, to create an instance of the above model class, use the following code:
```
let model = Model()
model.name = "Test Model"
model.amount = "42.42"
model.count = 91
EFWebServices.shared.postObject(expense) { (object, error) -> Void in
	if let object = object as? Model {
		// your post was successful
	} else {
		EFUtils.showError(title: "Error", message: error ?? "There was an error")
	}
```

You then begin use of EFWebServices by calling this (preferrably in the AppDelegate in didFinishLaunchingWithOptions):

```
WebServices.setBaseURL("https://www.server.com") // Minimum required setting, others can optionally be called as needed.
```

**By default, errors are handled by checking the status code of the response, and then a default error string is returned.**

When making calls using the default functions, there are a few things to note:
* By default, all calls now return the DataResponse, so you can parse the return however you want without overriding the default functions
* There is now an optional autoParse parameter in all calls that you can use to bypass EFTools parsing the json.  By default, this is set to true.

Here is an example network call where you are relying on EFTools to parse the response:

```
let getTest = TestModel(1)
EFWebServices.shared.getObject(getTest) { (response, object, errorString) in
    if let object = object {
        // Success
    } else {
        // Error
    }
}
```

If you want to explicitely have EFTools not parse the json, you can do so with the following:

```
let getTest = TestModel()
EFWebServices.shared.getObjects(getTest, autoParse: false) { (response, objects, errorString) in
    if let response = response {
        guard case .success(_) = response.result, let data = response.data else {
            if case .failure(error) = response.result {
                // Failure with status code
            } else {
                // Failure with data
            }
            return
         }
                
         // Success
     }
}
```

If you choose to not use the default functions provided by EFTools (or want to create additional ones), it is recommended that you create an Extension to EFWebServices instead of subclassing EFWebServices.

####Better Segues
Error-proof your segues by eliminating using simple strings.  Instead, comply to the SegueHandlerType prototype (a full writeup of this process can be found at https://www.natashatherobot.com/protocol-oriented-segue-identifiers-swift/).

To conform to the protocol, simply make an enum of all your segues:

```
class ThingsViewController: UIViewController, SegueHandlerType {
	enum SegueIdentifier: String {
   		// THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
   		case SegueA
    	case SegueTwo
    	case SegueD
	}
	
	// Rest of class goes here
	
}
```

Then, to perform a segue, call:

```
self.performSegueWithIdentifier(.SegueOne, sender: self)
```

And, finally, if you need to, in your prepareForSegue function, you can perform a switch on your segues:

```
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .SegueA:
            // Do some things
        case .SegueTwo:
            // Do other things
        case .SegueD:
            // Do _other_ other things
        }
    }
```


####Easier UIColors
Gone are the days of having to divide doubles to create your custom UIColors.  Where you used to do this:

```
let color = UIColor(red: 100.0/255.0, green: 25.0/255.0, blue: 63.0/255.0, alpha: 1.0)
```
Now you can do this:

```
// define your own alpha
let color = UIColor.rgba(red: 100, green: 25, blue: 63, alpha: 1.0)
// or default alpha to 1.0
let color2 = UIColor.rgb(red: 100, green: 25, blue: 63)
```

You can also quickly get the hex value of a color:

```
let hexValue = UIColor.hexValue(UIColor.redValue)
```

####Quick Spinners
Have something that's going to take a while in your project?  Add a spinner:

```
ProgressUtilities.showSpinner(self.view)
// or
ProgressUtilities.showSpinner(self.view, title: "Loading")
```

If you want to edit more properties of the spinner, you can get direct access to it:

```
ProgressUtilities.showSpinner(self.view, title: "Loading")
let hud = ProgressUtilities.getHud()!
hud.labelColor = UIColor.greenColor()
```

And don't forget to hide it when you are done with it!

```
ProgressUtilities.hideSpinner()
```

####Validation
Check to make sure an email address is valid:

```
EFUtils.isValidEmail(_emailAddress_) // returns true or false
```

Validate a password.  By default, the validation function requires 6 characters, and at least one each of the following: uppercase letter, lowercase letter, number, and special character.  You can change these requirements by passing in parameters.  For example, the following will only require upper and lowercase letters, but will have a minmum of 6 characters:

```
EFUtils.isValidPassword(_password_, minLength: 10, number: false, specialCharacter: false) // returns true or false
```

####Alert Messages
To display a quick alert message to the user, call the following:

```
EFUtils.showError(title: _title_, message: _message_, useBasic: true)
```

All parameters in this function are optional.  By default, the following will happen:
* title will be "Error"
* message will be "An error occurred with your request."
* useBasic is deprecated and optional, it has no effect.

To display an alert with a textField, call the following:

```
EFUtils.showTextFieldAlert(title: _title_, message: _message_, defaultButton: _defaultButtonText_, cancelButton: _cancelButtonText_) { (text) -> Void in
	// ... do stuff
}
```

The parameters are as follows:
* title required, will be the title of the alert
* message is required, will be the message of the alert
* defaultButton is optional, will be the text of the default button, and by default is "Continue"
* cancelButton is optional, will be the text of the cancel button, and by default is "Cancel"
* useBasic is deprecated, as SCLAlertView has been removed from EFTools.
* completion block: required, and will return the text of the textfield when the defaultButton is tapped.  Do with this what you will.

####Table View Controllers
EFTools contains EFTableViewController which subclasses UITableViewController.

This subclass does two things:
* Document specific methods of each subclass you may want to override and why
* Provide quick access to animated cells

After subclassing EFTableViewController for your own use, you can Option-click on your class to view its documentation and see important methods to override.

Here's a quick code example, which you would set up in viewDidLoad, to show how to set up cell animations.  Further details can be seen by looking at each class's documentation:

```
setCellType([.Scale, .Fade])
setInitialAlpha(0.5)
setInitialScale(1.5, yscale: 1.5)
setShowType(ShowType.Reload)
setDuration(0.5)
setInitialAlpha(0.25)
```

This example will fade the cells in while making them scale down to their proper size.  Each of these effects have defaults, which are available in each class's documentation.
