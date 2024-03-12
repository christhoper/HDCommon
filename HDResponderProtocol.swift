//
//  HDResponderProtocol.swift
//  HDCommon
//
//  Created by bailun on 2024/3/12.
//

// MARK: - 事件协议
public protocol HDEventProtocol {}

// MARK: - 事件响应传递协议
public protocol HDResponderProtocol: UIResponder {
    
    func transferEvent<T: HDEventProtocol>(_ any: T)
}

extension UIView {
    
    /// 查询响应链，找到则响应事件
    public func lookupEvent<T: HDEventProtocol>(_ any: T) {
        var next = self.next
        while next != nil {
            if let nextProtocol = next as? HDResponderProtocol {
                nextProtocol.transferEvent(any)
                // 只处理一个或者所有遵守 HDResponderProtocol 的视图
//                next = nil
            }
            
            next = next?.next
        }
    }
}
