//
//  Dictionary+Extension.swift
//  HDCommon
//
//  Created by bailun on 2024/2/23.
//

extension Dictionary: HDExtended {}

public extension HDExtension where ExtendedType == Dictionary<String, Any> {
    
    // MARK: 2.1、字典转JSON
    /// 字典转JSON
    @discardableResult
    func dictionaryToJson() -> String? {
        if (!JSONSerialization.isValidJSONObject(self.type)) {
            print("无法解析出JSONString")
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: self.type) {
            let JSONString = NSString(data:data,encoding: String.Encoding.utf8.rawValue)
            return JSONString! as String
        } else {
            print("无法解析出JSONString")
            return nil
        }
    }
}
