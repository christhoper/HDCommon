//
//  HDCrashManager.swift
//  HDCommon
//
//  Created by bailun on 2024/2/26.
//

final public class HDCrashManager {
    
    public static let shared = HDCrashManager()
    
    private init() {
        
    }
    
}

extension HDCrashManager {
    
    /// 注册
    public func register() {
        HDCrashSignalExceptionHandler.registerHandlers()
    }
}
