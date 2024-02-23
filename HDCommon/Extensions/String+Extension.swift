//
//  String+Extension.swift
//  HDCommon
//
//  Created by bailun on 2024/2/23.
//

extension String: HDExtended {}

public extension HDExtension where ExtendedType == String {
    
    /// JSON 字符串 ->  Array
    /// - Returns: Array
    func jsonStringToArray() -> Array<Any>? {
        let jsonString = self.type 
        let jsonData:Data = jsonString.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return (array as! Array<Any>)
        }
        return nil
    }

    /// JSON 字符串 ->  Dictionary
    /// - Returns: Dictionary
    func jsonStringToDictionary() -> Dictionary<String, Any>? {
        let jsonString = self.type
        let jsonData: Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return (dict as! Dictionary<String, Any>)
        }
        return nil
    }
}
