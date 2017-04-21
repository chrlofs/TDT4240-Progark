//
//  firstView.swift
//  Drop
//
//  Created by Kristoffer Thorset on 20.04.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit

class firstView: UIViewController{
    let gameSettings = GameSettings.getInstance()
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
        if gameSettings.isLoggedIn() {
            ToMenu()
        } else {
            ToLogin()
        }
    }
    
    func ToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: false)
    }
    func ToLogin(){
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! loginVC
        self.navigationController?.pushViewController(loginVC, animated: false)
    }






}
