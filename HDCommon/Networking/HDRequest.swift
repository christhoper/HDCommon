//
//  HDRequest.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/21.
//

import Alamofire

//MARK: - 网络请求请求实体

public class HDRequest: NSObject, URLConvertible, URLRequestConvertible, HDRequestCancleable {
    
    /// 请求的API，包含域名、api路径两部分
    public var api: String!
    
    /// 请求参数
    public var params: Parameters?
    
    /// 只有服务端指定将某些参数追加在api后面时，才设置此参数(不适用于get请求时设置此参数)
    public var extraQueryParams: Parameters?
    
    /// 请求参数（直接设置请求的请求体，通常用于自定义模型转变为Data数据）
    public var httpBody: Data?
    
    /// 默认请求超时设置为10s
    public var timeout: Int = 10
    
    /// 请求头
    public var headers: HTTPHeaders?
    
    /// 附加请求头
    public var appendHeaders: [String : String]?
    
    /// 指定请求的参数编码方式
    public var encoding: ParameterEncoding?

    
    /// Types adopting the `URLConvertible` protocol can be used to construct URLs, which are then used to construct URL requests.
    public func asURL() throws -> URL {
        guard extraQueryParams != nil else {
            return URL(string: api)!
        }
        
        let components = NSURLComponents.init(string: api)
        var queryItems = [URLQueryItem]()
        for (key, value) in extraQueryParams! {
            let valueString = "\(value)"
            queryItems.append(URLQueryItem.init(name: key, value: valueString))
        }
        components?.queryItems = queryItems
        
        return components?.url ?? URL(string: api)!
    }
    
    /// Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
    public func asURLRequest() throws -> URLRequest {
        let url = try self.asURL()
        var request = URLRequest(url:  url)
        
        /// 设置请求头
        if let headers = self.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        /// 设置请求题
        request.httpBody = httpBody
        
        return request
    }
}


//MARK: - 数组参数拓展

private let arrayParametersKey = "arrayParametersKey"
 
public extension Array {
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}
 
public struct ArrayEncoding: ParameterEncoding {
 
    public let options: JSONSerialization.WritingOptions
 
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
 
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
 
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
 
            urlRequest.httpBody = data
 
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
 
        return urlRequest
    }
}

//MARK: - 网络请求异常提示模型

public class HDNetworkHint: NSObject {
    
    /// 无网络连接时提示语
    public var netlessMsg: String = "当前无网络连接"
    
    /// 网络请求超时提示语
    public var timeoutMsg: String = "网络请求超时"
    
    /// 服务未知异常提示语
    public var serviceExceptionMsg: String = "服务器开小差了"
    
    /// 请求取消
    public var cancelledMsg: String = "请求已取消"
}
