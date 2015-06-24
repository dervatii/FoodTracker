//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Diego Valderrama on 6/14/15.
//  Copyright (c) 2015 Diego Valderrama. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //To receive information from ViewController or DataController
    var usdaItem:USDAItem?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func EatItButtonPressed(sender: UIBarButtonItem) {
    }

}
