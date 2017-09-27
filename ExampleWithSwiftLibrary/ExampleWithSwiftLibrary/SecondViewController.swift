//
//  SecondViewController.swift
//  ExampleWithSwiftLibrary
//
//  Created by Patrick BODET on 19/08/2017.
//  Copyright © 2016 iDevelopper. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftButton.target = self.revealViewController
        leftButton.action = #selector(PBRevealViewController.revealLeftView)

        rightButton.target = self.revealViewController
        rightButton.action = #selector(PBRevealViewController.revealRightView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
