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
    var loadingAnimation : UIActivityIndicatorView!
    var alertView : UIAlertController!
//MARK: - LifeCycle -
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set Navigation Controller as Hidden
        
        self.navigationController?.navigationBarHidden=true;
        
        // Activity Indicator initialize
        loadingAnimation = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingAnimation.center=self.view.center
        loadingAnimation.hidesWhenStopped=true
        self.view.addSubview(loadingAnimation)
        
        // Check user if already logged in
        
        userAlreadyLoggedInCheck()
        
        
    }

    func userAlreadyLoggedInCheck()
    {
        loadingAnimation.startAnimating()

        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            returnUserData();
        }
        else
        {
            // create fb login button and set frame
            
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            
            self.view.addSubview(loginView)

            loginView.frame=CGRectMake((self.view.frame.size.width - 110) / 2, ((self.view.frame.size.height - 40) / 2), 110, 40)
            
            // Permissions that is requested from user
            
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            
            // FBSDKLoginButtonDelegate assign
            
            loginView.delegate = self
            
            loadingAnimation.stopAnimating()

        }
    }

//MARK: - FBSDKLoginKit Delegate Methods -
    func loginButton(loginButton: FBSDKLoginButton!,
        didCompleteWithResult result: FBSDKLoginManagerLoginResult!,
        error: NSError!)
    {
        if ((error) != nil)
        {
            handleErrors(error)
            
                // Process error
        } else if result.isCancelled {
                // Handle cancellations
        } else {
            
                    loadingAnimation.startAnimating()
            
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

    func handleErrors(error : NSError!)
    {
        
        alertView = UIAlertController(title:"Error", message:"Error: \(error)", preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(self.alertView, animated: true, completion: nil)
        
        // Process error
        println("Error: \(error)")
        
        self.loadingAnimation.stopAnimating()
    }

//MARK - Fetch User Data -
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {

                self.handleErrors(error)

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
        self.loadingAnimation.stopAnimating()

        if (segue.identifier == "landingSegue")
        {
            var lnd = segue.destinationViewController as! LandingViewController;            
            // Pass the user data to the new view controller.
            lnd.userFullName = fbUserFullName as! String;
        }
    }
}
