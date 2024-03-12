//
//  HDExtended.swift
//  HDCommon
//
//  Created by bailun on 2024/2/22.
//

 // #   where ExtendedType: xxx 和 where ExtendedType == xxx 的区别
// ## 前者约束是xxx类型或者它的子类都可以，后者约束则必须是xxx类型

// MARK: - 使遵守HDExtended协议的扩展可以使用链式语法
public struct HDExtension<ExtendedType> {
    
    public private(set) var type: ExtendedType
    
    public init(_ type: ExtendedType) {
        self.type = type
    }
}

// MARK: - HDExtended协议
// 链式协议
public protocol HDExtended {
    
    associatedtype ExtendedType
    
    static var hd: HDExtension<ExtendedType>.Type { get set }
    
    var hd: HDExtension<ExtendedType> { get set }
}

extension HDExtended {
    
    public static var hd: HDExtension<Self>.Type {
        get { HDExtension<Self>.self }
        set {}
    }
    
    public var hd: HDExtension<Self> {
        get { HDExtension(self) }
        set {}
    }
}
