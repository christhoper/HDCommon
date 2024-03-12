//
//  TestEventView.swift
//  HDCommon_Example
//
//  Created by bailun on 2024/3/12.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import HDCommon

class TestEventView: UIView {

    var enity: TestEventViewEvent?

    lazy var testBtn: UIButton = {
        let button = UIButton()
        button.setTitle("事件", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(onClickButton(_:)), for: .touchUpInside)
        return button
    }()
    
    convenience init(frame: CGRect, eventName: String) {
        self.init(frame: frame)
        enity = TestEventViewEvent(name: eventName, event: "\(Int.random(in: 0..<1000))")
        addSubview(testBtn)
        testBtn.frame = CGRect(x: 0, y: 0, width: frame.width, height: 44)
        testBtn.setTitle(eventName, for: .normal)
        backgroundColor = UIColor.randomColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClickButton(_ sender: UIButton) {
        self.lookupEvent(enity!)
    }
}

struct TestEventViewEvent: HDEventProtocol {
    var name: String
    var event: String
    
    init(name: String, event: String) {
        self.name = name
        self.event = event
    }
}

extension UIColor {
    
    static func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)

        let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        return randomColor
    }
}
