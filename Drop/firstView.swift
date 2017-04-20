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
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
        let defaults = UserDefaults.standard
        self.navigationController?.isNavigationBarHidden = true
        let user = defaults.value(forKey: "userName") as? String ?? String()
        let skinList: [String] = ["skin1", "skin2", "skin3", "kim", "trump", "putin"]
        defaults.set(skinList, forKey: "skinList")
        if (!user.isEmpty) {
            ToMenu()
        
    
        }
        else{
            ToLogin()
        }
        
        
    }
        
        
    
    func ToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    func ToLogin(){
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! loginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }






}
