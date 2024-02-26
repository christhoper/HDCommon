//
//  ViewController.swift
//  HDCommon
//
//  Created by hendy on 02/20/2024.
//  Copyright (c) 2024 hendy. All rights reserved.
//

import UIKit
import HDCommon

class ViewController: UIViewController {
    
    var list: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.list[10] = 9
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
