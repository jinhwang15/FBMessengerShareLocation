//
//  LoginViewController.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 16/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

//MARK: - IMPORTS -
import UIKit

//MARK: - BEGİNNİNG OF SUPERCLASS -
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate
    
{
    var fbUserFullName : NSString!

    @IBOutlet var logoImageView: UIImageView!
//MARK: - LifeCycle -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set Navigation Controller as Hidden
        self.navigationController?.navigationBarHidden=true;
        // Check user if already logged in
        userAlreadyLoggedInCheck()
    }

    func userAlreadyLoggedInCheck()
    {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            returnUserData();
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            
            loginView.frame=CGRectMake(self.view.center.x, self.view.center.y, 150, 80)
            
            self.view.addSubview(loginView)
            //loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            
            
        }
    }

//MARK: - FBSDKLoginKit Delegate Methods -
    func loginButton(loginButton: FBSDKLoginButton!,
        didCompleteWithResult result: FBSDKLoginManagerLoginResult!,
        error: NSError!)
    {
        if ((error) != nil)
        {
                // Process error
        } else if result.isCancelled {
                // Handle cancellations
        } else {
            
                    println("User Logged In")

                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                    // Do work
            
                    returnUserData();
                }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        println("User Logged Out")
    }

//MARK - Fetch User Data -
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                println("User Name is: \(userName)")
                self.fbUserFullName=userName
                self.performSegueWithIdentifier("landingSegue", sender: self)
            }
        })
    }
// MARK: - Navigation -

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "landingSegue")
        {
            var lnd = segue.destinationViewController as! LandingViewController;            
            // Pass the user data to the new view controller.
            lnd.userFullName = fbUserFullName as! String;
        }
    }
}
