# EFTools
iOS Tools for ElevenFifty

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
If you are already using Cocoapods, this is easy. If you aren't - then start!  Here's a sample Podfile that uses EFTools in Xcode 7:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
xcodeproj 'testapp.xcodeproj'

pod 'EFTools', :git => 'https://github.com/ElevenFifty/EFTools.git', :tag => '1.0.1'
```

**You will use tag 0.1 for any projects still building in Xcode 6.4**

EFTools has many dependencies that will be pulled down for you.  They are as follows:
* AFDateHelper (https://github.com/melvitax/AFDateHelper)
* AlamoFire (https://github.com/Alamofire/Alamofire)
* Instabug (https://instabug.com)
* MBProgressHUD (https://github.com/jdg/MBProgressHUD)
* ParseFacebookUtils
* ParseTwitterUtils
* ParseUI (by default this also pulls in Parse)
* SCLAlertView (https://github.com/vikmeup/SCLAlertView-Swift)
* SnapKit (http://snapkit.io/docs/)
* SwiftyJSON (https://github.com/SwiftyJSON/SwiftyJSON)
* TPKeyboardAvoiding (https://github.com/michaeltyson/tpkeyboardavoiding)

By default, EFTools pulls down all of these.  You can also pull down subsets with the following Podfile lines:

1. pod 'EFTools/Basic', :git => 'https://github\.com/ElevenFifty/EFTools.git', :tag => '1.0'
  * pulls down AFDateHelper, Instabug, MBProgressHUD, SCLAlertView, SnapKit, and TPKeyboardAvoiding
2. pod 'EFTools/Parse', :git => 'https://github\.com/ElevenFifty/EFTools.git', :tag => '1.0'
  * pulls down ParseUI/Parse, ParseFacebookUtils, ParseTwitterUtils, and everything that "Basic" pulls down
3. pod 'EFTools/Alamofire', :git => 'https://github\.com/ElevenFifty/EFTools.git', :tag => '1.0'
  * pulls down Alamofire, SwiftyJSON, and everything that "Basic" pulls down


##Features
####Working with a REST Backend
EFTools greatly simplifies the process of interacting with a REST backend service by giving you the following: EFWebServices, EFWebProtocol, and EFNetworkModel.

To use these, we first start with the EFNetworkModel protocol.  This will drive the connection process.  Here is an example class:

```
import UIKit
import EFTools
import Alamofire
import SwiftyJSON

class Model: EFNetworkModel {
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
    
    init() {}
    
    required init(json: JSON) { // REQUIRED METHOD, USED TO PARSE RETURNED JSON
        id = json[Constants.Model.id].intValue
        name = json[Constants.Model.name].stringValue
        amount = json[Constants.Expense.amount].double
        count = json[Constants.Expense.count].int
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
    
    func patches() -> [[String: AnyObject]]? { // REQUIRED METHOD, USED TO BUILD NETWORK REQUEST - SHOULD ALMOST ALWAYS RETURN NIL
        return nil
    }
    
    func headers() -> [String: AnyObject]? { // REQUIRED METHOD, USED TO BUILD NETWORK REQUEST - SHOULD ALMOST ALWAYS RETURN NIL
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

A few setup steps are required as well.  The following steps must be taken:
* Implement the EFWebProtocol, preferably in an EFWebServices subclass
* Setup the base settings for EFWebServices

An example of step 1 is as follows:

```
import Foundation
import EFTools
import Alamofire
import SwiftyJSON

class WebServices: EFWebServices, EFWebProtocol {
    static func setBaseURL(url: String) {
        self.shared.baseURL = url
    }
    
    static func addHeaders(headers: [String: AnyObject]) {
        self.shared.headers = headers
    }
    
    static func addQueries(queries: [String: String]) {
        self.shared.queries = queries
    }
    
    static func setAuthHeader(headerName: String) {
        self.shared.authHeader = headerName
    }
    
    static func setAuthPrefix(headerPrefix: String) {
        self.shared.authPrefix = headerPrefix
    }
}
```

And you would then setup the base setting for EFWebServices by calling this (preferrably in the AppDelegate in didFinishLaunchingWithOptions):

```
WebServices.setBaseURL("https://www.server.com") // Minimum required setting, others can optionally be called as needed.
```

**A Few Notes**
* By default, errors are handled by checking if the returned json can be converted to a string.  If it cannot, a generic string (from EFConstants) is returned.  Possible future functionality includes a method for providing your own parsing completion block.
* You can use your own methods for making requests, you are not limited to the functions in EFWebServices.  To do so, put something like the following in your EFWebServices subclass (which we'll call WebServices):

```
class func getStuff(newObject: OtherModel, completion:(release: GARelease?, error: String?) -> Void) {
    // It would be a good idea to check if you have a network connection here
    // Also, the OtherModel class above must conform to the EFNetworkModel protocol
    request(AuthRouter.EFRequest(newObject)).response { (request, response, jsonObject, error) -> Void in
        // Parse the response here
    }
}
```

And then you can call your custom function like this:

```
WebServices.getStuff(otherModelInstance, completion: { (object, error) -> Void in
	if let object = object as? OtherModel {
		// Success
	} else {
		// Failed
	}
}
```

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
* useBasic will be true, which means UIAlertController will be used.  If you set this value to false, [SCLAlertView](https://github.com/vikmeup/SCLAlertView-Swift) will be used.

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
* useBasic is optional, will be true by default and will use UIAlertController.  False will use SCLAlertView.
* completion block: required, and will return the text of the textfield when the defaultButton is tapped.  Do with this what you will.

####Table View Controllers
Depending on whether you are using Parse or not, EFTools contains two different kinds of table view controllers:
* EFTableViewController - subclasses UITableViewController
* EFQueryTableViewController - subclasses PFQueryTableViewController

These subclasses do two things:
* Document specific methods of each subclass you may want to override and why
* Provide quick access to animated cells

After subclassing either of these classes for your own use, you can Option-click on each class to view their documentation and see important methods to override.

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
