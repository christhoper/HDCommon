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
    
    lazy var jumpBtn: UIButton = {
        let button = UIButton()
        button.setTitle("传递多个层级事件", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(jumpEvent(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(jumpBtn)
        jumpBtn.frame = CGRect(x: 100, y: 100, width: 160, height: 44)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
           // 测试crash
//            var model = TestModel()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func jumpEvent(_ sender: UIButton) {
        let controller = TransferEventsViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
