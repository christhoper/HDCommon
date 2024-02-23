//
//  DateFormatter+Extension.swift
//  HDCommon
//
//  Created by bailun on 2024/2/23.
//


/*
 
 在一般情况下，DateFormatter 的实例创建是一个相对较轻量级的操作，但并非完全无成本。创建 DateFormatter 实例涉及到一些初始化工作，包括设置日期格式、时区等。

 在实际应用中，如果你频繁地需要使用 DateFormatter 对象来进行日期的格式化或解析，建议尽可能重用已创建的 DateFormatter 实例，而不是在每次需要时都创建新的实例。这是因为重用实例可以减少对象创建的开销，并提高性能。
 
 // 使用时
 let formattedDate = DateFormatter.shared.string(from: someDate)
 
 */

public extension DateFormatter {
    
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        // 配置 formatter 的其他属性，例如日期格式、时区等
        return formatter
    }()
}
