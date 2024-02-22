//
//  HDRequestResult.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/21.
//

//MARK: - 网络请求错误类型

public enum HDRequestError: Error {
    /// 无网络、网络异常
    case netless(String)
    /// 网络超时
    case timeout(String)
    /// 服务器异常
    case serviceException(String)
    /// 请求已取消
    case cancelled(String)
    /// subcode错误
    case subcodeError(String)
    
    /// 错误提示文案
    public var errorMessage: String {
        switch self {
        case .netless(let msg):
            return msg
        case .timeout(let msg):
            return msg
        case .serviceException(let msg):
            return msg
        case .cancelled(let msg):
            return msg
        case .subcodeError(let msg):
            return msg
        }
    }
}
