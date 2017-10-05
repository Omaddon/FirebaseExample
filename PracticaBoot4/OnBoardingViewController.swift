//
//  OnBoardingViewController.swift
//  PracticaBoot4
//
//  Created by MIGUEL JARDÓN PEINADO on 4/10/17.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase


class OnBoardingViewController: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    
    var handler: AuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ver Schema: saca información adicional por consola
        
        if self.isUserLogin() {
            self.title = Auth.auth().currentUser?.email
            self.performSegue(withIdentifier: "GotoMain", sender: nil)
        } else {
            self.observerUserActivity()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if handler != nil {
            Auth.auth().removeStateDidChangeListener(handler!)
        }
    }


    private func observerUserActivity() {
        handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                print("Usuario creado: \(String(describing: user?.email))")
            }
        }
    }
    
    private func nextVCSegue() {
        self.performSegue(withIdentifier: "GotoMain", sender: nil)
    }
    
    private func isUserLogin() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        } else {
            return false
        }
    }
    
    private func createAccount() {
        Analytics.logEvent("Create_Account", parameters: ["method" : "mail-pwd"])
        
        Auth.auth().createUser(withEmail: emailTxt.text!, password: pwdTxt.text!) { (user, error) in
                                
            if let error = error {
                print("Tenemos un error: \(error.localizedDescription)")
            }
            
            if user != nil {
                print("Usuario creado: \(String(describing: user?.email))")
                
                // Validar el mail del nuevo usuario
                user?.sendEmailVerification(completion: { (error) in
                    Analytics.logEvent("Send_email_verification", parameters: nil)
                    
                    if let error = error {
                        print("Tenemos un error: \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    
    private func login() {
        Analytics.logEvent("User_Login", parameters: ["method" : "mail-pwd"])
        
        Auth.auth().signIn(withEmail: emailTxt.text!, password: pwdTxt.text!) { (user, error) in
            if let error = error {
                print("Tenemos un error: \(error.localizedDescription)")
            }
            
            // Si las pwd no es la correcta, user = nil
            if user != nil {
               self.nextVCSegue()
            }
        }
    }
    
    private func logout() {
        Analytics.logEvent("User_Logut", parameters: nil)
        
        do {
            try Auth.auth().signOut()
            self.title = Auth.auth().currentUser?.email
        } catch {
            
        }
//        !try Auth.auth().signOut()
    }
    
    private func resetUserPwd() {
        if self.isUserLogin() {
            let user = Auth.auth().currentUser
            Auth.auth().sendPasswordReset(withEmail: (user?.email)!, completion: { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    

    @IBAction func createNewAccount(_ sender: Any) {
        self.createAccount()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.login()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.logout()
    }
    
    @IBAction func resetPwd(_ sender: Any) {
        self.logout()
    }
    
    
}

























