//
//  TransferEventsViewController.swift
//  HDCommon_Example
//
//  Created by bailun on 2024/3/12.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import HDCommon

class TransferEventsViewController: UIViewController {

    lazy var eventView1: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var eventView2: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(eventView1)
        view.addSubview(eventView2)
        eventView1.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 200)
        eventView2.frame = CGRect(x: 0, y: 310, width: view.frame.width, height: 200)
        
        let event1 = TestEventView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200), eventName: "event1")
        eventView1.addSubview(event1)
        let event2 = TestEventView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 400), eventName: "event2")
        eventView2.addSubview(event2)
        let event3 = TestEventView(frame: CGRect(x: 30, y: 44, width: event2.frame.width-60, height: event2.frame.height-44*2), eventName: "event3")
        event2.addSubview(event3)
        let event4 = TestEventView(frame: CGRect(x: 30, y: 44, width: event3.frame.width-60, height: event3.frame.height-44*2), eventName: "event4")
        event3.addSubview(event4)
    }
}

extension TransferEventsViewController: HDResponderProtocol {
    
    func transferEvent<T>(_ any: T) where T : HDCommon.HDEventProtocol {
        print("传递到了这里", any)
    }
    
    
}
