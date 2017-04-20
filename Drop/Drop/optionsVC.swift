//
//  optionsVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 14.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class optionsVC: UIViewController{
    override func viewDidLoad() {
    self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
}
