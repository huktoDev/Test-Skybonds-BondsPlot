//
//  AppDelegate.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 13.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

}

class TestViewController: UIViewController {
    
    @IBOutlet weak var isinTextField: UITextField!
    
    @IBAction func applyTapped() {
        bondsPlot.bondISIN = isinTextField.text
    }
    
    var bondsPlot: BondsPlotViewController {
        return children.compactMap { $0 as? BondsPlotViewController }.first!
    }
}

