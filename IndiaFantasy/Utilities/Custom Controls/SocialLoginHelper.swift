//
//  SocialLoginHelper.swift
//  HelperFiles
//
//  Created by Harendra Singh Rathore on 05/10/23.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit
import GoogleSignIn

class SocialLoginHelper: UIViewController {
    
    static let shared = SocialLoginHelper()
    var completionHandler : ((_ userInfo: SocialLoginRequest) -> Void)?
    
    //MARK: - FaceBook Login
    func handleLogInWithFacebookButtonPress() {
        
        let fblogin = LoginManager()
        fblogin.logOut()
        
        let loginManager = LoginManager()
        
        func getFacebookProfileInfo(accessToken:String) {
            let params = ["fields" : "id, name, first_name, last_name, picture.type(large), email"]
            
            GraphRequest(graphPath: "me", parameters: params).start( completion: { (connection, result, error) in
                
                guard let fbDetails = result as? [String: Any], error == nil else {
                    debugPrint("Facebook SignIn Error --> \(error?.localizedDescription ?? "")")
                    return
                }
                
                let userId = fbDetails["id"] as? String ?? ""
                let email = fbDetails["email"] as? String ?? ""
                let name = fbDetails["name"] as? String ?? ""
                let firstName = fbDetails["first_name"] as? String ?? ""
                let lastName = fbDetails["last_name"] as? String ?? ""
                
                let request = SocialLoginRequest(email: email, social_id: userId, name: name, first_name: firstName, last_name: lastName, social_type: .facebook)
                
                debugPrint("Facebook SignIn Details --> \(request)")
                
                if let comp = self.completionHandler{
                    comp(request)
                }
            })
        }
        
        if let accessToken = AccessToken.current{
            getFacebookProfileInfo(accessToken: accessToken.tokenString)
        } else {
            
            loginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
                if (error == nil){
                    let fbloginresult : LoginManagerLoginResult = result!
                    if(fbloginresult.grantedPermissions.contains("email")){
                        getFacebookProfileInfo(accessToken: AccessToken.current?.tokenString ?? "")
                    }
                }
            }
        }
    }
    
    //MARK: - Googele Login
    func handleLogInWithGoogleButtonPress(controller:UIViewController) {
        
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { data, error in
            
            guard let user = data?.user, error == nil else {
                debugPrint("Google SignIn Error --> \(error?.localizedDescription ?? "")")
                return
            }
            
            let userId = user.userID ?? ""
            let email = user.profile?.email ?? ""
            _ = user.idToken?.tokenString ?? ""
            let name = user.profile?.name ?? ""
            let firstName = user.profile?.givenName ?? ""
            let lastName = user.profile?.familyName ?? ""

            let request = SocialLoginRequest(email: email, social_id: userId, name: name, first_name: firstName, last_name: lastName, social_type: .google)

            debugPrint("Google SignIn Details --> \(request)")
            
            if let comp = self.completionHandler{
                comp(request)
            }
        }
    }
}


// MARK: - Apple Sign-in delegate methods
extension SocialLoginHelper : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    //MARK: Apple Login
    func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint("Apple SignIn Error --> \(error.localizedDescription)")
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            var userIdentifier = appleIDCredential.user
            var userFirstName = appleIDCredential.fullName?.givenName ?? ""
            var userLastName = appleIDCredential.fullName?.familyName ?? ""
            var userEmail = appleIDCredential.email
          
            if userEmail != nil{
                CommonFunctions.saveKeychain(service: "firstname", data: userFirstName)
                CommonFunctions.saveKeychain(service: "email", data: userEmail)
                CommonFunctions.saveKeychain(service: "last_name", data: userLastName)
                CommonFunctions.saveKeychain(service: "id", data: userIdentifier)
            }else{
                
                if userIdentifier == CommonFunctions.getValuefromKeyChain(service: "id"){
                    userEmail = CommonFunctions.getValuefromKeyChain(service: "email");
                    userFirstName = CommonFunctions.getValuefromKeyChain(service: "firstname");
                    userLastName = CommonFunctions.getValuefromKeyChain(service: "last_name");
                    userIdentifier = CommonFunctions.getValuefromKeyChain(service: "id");
                }
            }
            
            
            let name = "\(userFirstName) \(userLastName)"
           
            let request = SocialLoginRequest(email: userEmail ?? "", social_id: userEmail ?? "", name: name, first_name: userFirstName, last_name: userLastName, social_type: .apple)

            
            debugPrint("Apple SignIn Details --> \(request)")
            
            if let comp = self.completionHandler{
                comp(request)
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//MARK: - Social Login Request
struct SocialLoginRequest {

    var email: String
    var social_id: String
    var name: String
    var first_name: String
    var last_name: String

    var social_type: SocailTypes
    var referralCode: String = ""
    var login_type: LoginType = .login
}

enum SocailTypes: String {
    case facebook = "fb"
    case google = "google"
    case apple = "apple"
    
    var value: String {
        self.rawValue.description
    }
}

enum LoginType: String {
    case register
    case login
    
    var value: String {
        self.rawValue
    }
}

