//
//  ViewController.swift
//  Facebook-Login
//
//  Created by miguel olmedo on 20/10/14.
//  Copyright (c) 2014 idealista. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate
{
    
    @IBOutlet weak var viewFbLogin:         FBLoginView!
    @IBOutlet weak var lblName:             UILabel!
    @IBOutlet weak var lblBirthday:         UILabel!
    @IBOutlet weak var lblLocation:         UILabel!
    @IBOutlet weak var lblFriends:          UILabel!
    @IBOutlet weak var viewLoginFacebook:   UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.viewFbLogin.readPermissions = [ "public_profile", "email", "user_friends", "user_birthday", "user_location" ]
        self.viewFbLogin.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("loginWithFB"))
        self.viewLoginFacebook.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - FBLoginViewDelegate
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!)
    {
        println("access token: \(FBSession.activeSession().accessTokenData.accessToken)");
        
        self.loggedUser(user.name, birthday: user.birthday, location: user.location.name)
    }
    
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!)
    {
    }
    
    func loginWithFB()
    {
        if FBSession.activeSession().state == FBSessionState.Open || FBSession.activeSession().state == FBSessionState.OpenTokenExtended{
            FBSession.activeSession().closeAndClearTokenInformation()
        } else {
            FBSession.openActiveSessionWithReadPermissions([ "public_profile", "email", "user_friends", "user_birthday", "user_location" ], allowLoginUI: true,
                completionHandler: { (session, sessionState, error) -> Void in
                    println("access token: \(session.accessTokenData.accessToken)");
                if error == nil {
                    self.userLogged()
                } else {}
            })
        }
    }
    
    func userLogged()
    {
        let meRequest = FBRequest.requestForMe()
        meRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            
            let data = result as NSDictionary
            self.loggedUser(result.objectForKey("name") as? String, birthday: result.objectForKey("birthday") as String?,
                location: result.valueForKeyPath("location.name") as? String)
        }
    }
    
    @IBAction func tapBtnGetFriends(sender: AnyObject)
    {
        let friendsRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            let data = result as NSDictionary
            let friends = data.objectForKey("data") as [NSDictionary]
            
            NSLog("friends: %@", friends)
            
            var text = ""
            for friend in friends {
                let friendName = friend.objectForKey("name") as String
                text += "\(friendName)\n"
            }
            self.lblFriends.text = text
        }
    }
    
    func loggedUser(name: String?, birthday: String?, location: String?)
    {
        self.lblName.hidden = name == nil
        self.lblBirthday.hidden = birthday == nil
        self.lblLocation.hidden = location == nil
        
        self.lblName.text = name
        self.lblBirthday.text = birthday
        self.lblLocation.text = location
    }
    
}