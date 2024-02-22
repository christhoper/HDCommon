//
//  UIFont+Extension.swift
//
//
//  Created by bailun on 2024/2/22.
//

public extension UIFont {
    
    /// 细体
    static func stl_thin(of size: CGFloat, name: String = "PingFangSC-Thin") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
    }
    
    /// 常规
    static func stl_regular(of size: CGFloat, name: String = "PingFangSC-Regular") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    /// 中等
    static func stl_medium(of size: CGFloat, name: String = "PingFangSC-Medium") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    /// 粗体
    static func stl_bold(of size: CGFloat, name: String = "PingFangSC-Semibold") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}

