//
//  multiplayerMenuVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 13.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class multiplayerMenuVC: UIViewController{
    override func viewDidLoad() {
    }

    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }

    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
}
