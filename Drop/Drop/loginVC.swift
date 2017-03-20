//
//  loginVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 20.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit


class loginVC: UIViewController{
    
    override func viewDidLoad() {
        
    }
    
    @IBOutlet weak var userName: UITextField!

    
    
    @IBAction func login(_ sender: UIButton) {
        let defaults = UserDefaults.standard
    
        if verifyUsername(self.userName.text!) {
    
            defaults.set(self.userName.text!, forKey: "userName")
            print(defaults.value(forKey: "userName") as? String ?? String())
            
 
            ToMenu()
        }
        else{}
    }
   
    func ToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    func verifyUsername (_ userName: String) -> Bool{
       return true
    }
}
