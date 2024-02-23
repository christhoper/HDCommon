//
//  UIFont+Extension.swift
//
//
//  Created by bailun on 2024/2/22.
//

extension UIFont: HDExtended {}

extension HDExtension where ExtendedType: UIFont {
    /// 细体
    static func thin(of size: CGFloat, name: String = "PingFangSC-Thin") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
    }
    
    /// 常规
    static func regular(of size: CGFloat, name: String = "PingFangSC-Regular") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    /// 中等
    static func medium(of size: CGFloat, name: String = "PingFangSC-Medium") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    /// 粗体
    static func bold(of size: CGFloat, name: String = "PingFangSC-Semibold") -> UIFont {
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
}

