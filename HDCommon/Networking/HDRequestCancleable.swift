//
//  HDRequestCancleable.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/21.
//

import Alamofire

// MARK: - 可取消的请求

public protocol HDRequestCancleable {
    /// 取消请求抽象
    func cancel()
}

extension HDRequestCancleable {
    /// 取消请求调用实现
    public func cancel() {
        guard let request = self as? Alamofire.Request else { return }
        request.cancel()
    }
}

/// 当前请求类实现可取消协议
extension Alamofire.Request: HDRequestCancleable {}
