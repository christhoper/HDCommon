//
//  HDNetworkingManager.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/20.
//

import Alamofire

final public class HDNetworkingManager {
    
    public static let shared = HDNetworkingManager()

    /// 网络异常提示信息
    private var networkHint: HDNetworkHint?
    
    /// 网络超时时间, 默认10s
    private var timeout: TimeInterval = 10
    
    /// 通用请求头生成闭包
    private var generalHeaderHandler: (() -> [String: String])?
    
    /// 通用查询参数生成闭包
    private var generalQueryParamHandler: (() -> [String : Any])?
    
    /// 是否开启调试模式, 控制台打印数据
    private var isEnableDebug: Bool = false
    
    /// Https 证书文件所在的Bundle
    private var cerBundle: Bundle = Bundle.main

    /// 证书数据
    private var certificates: [SecCertificate] = []

    /// https请求的host集合, 用于验证https请求的证书
    private var cerHostsHandle: (() -> Set<String>)?
    
    /// 不需要SSL证书认证的api（白名单）
    private var ignoreApiHandle: (() -> [String])?

    /// 默认session，用于白名单内的api请求
    private lazy var defaultSession: Alamofire.Session = {
        let configuration = URLSessionConfiguration.af.default
        return Alamofire.Session(configuration: configuration)
    }()

    /// 用于动态重置session
    private var _cerSession: Alamofire.Session?

    /// 需要配置SSL证书认证的session
    private var cerSession: Alamofire.Session {
        if _cerSession != nil {return _cerSession!}

        /// 没有配置cerHosts使用默认session
        guard let hosts = self.cerHostsHandle?(), !hosts.isEmpty else {
            return defaultSession
        }

        /// 优先使用沙盒中的证书, 没有就去bundle中找
        self.certificates = getCertifications()
        if self.certificates.isEmpty {
            self.certificates = cerBundle.af.certificates
        }

        /// 如果有Https证书，则设置相关证书验证
        var serverTrustManager: ServerTrustManager? = nil
        if !certificates.isEmpty {
            var trustEvaluators = [String : ServerTrustEvaluating]()
            let trustEvaluator = PinnedCertificatesTrustEvaluator(certificates: certificates,
                                                                   acceptSelfSignedCertificates: false,
                                                                   performDefaultValidation: false,
                                                                   validateHost: true)
            hosts.forEach { host in
                if let trustHost = URLComponents(string: host)?.host {
                    trustEvaluators[trustHost] = trustEvaluator
                } else {
                    trustEvaluators[host] = trustEvaluator
                }
            }
            serverTrustManager = ServerTrustManager(evaluators: trustEvaluators)
        }

        let configuration = URLSessionConfiguration.af.default
        let sessionManager = Alamofire.Session(configuration: configuration, serverTrustManager: serverTrustManager)
        _cerSession = sessionManager
        return sessionManager
    }


    func httpSession(for api: String) -> Alamofire.Session {
        /// 没有配置要验证的host
        guard let hosts = self.cerHostsHandle?(), !hosts.isEmpty else {
            return defaultSession
        }

        /// 白名单内的api不需要验证证书
        if let ignoreApis = self.ignoreApiHandle?(), ignoreApis.contains(api) {
            return defaultSession
        }

        /// 没有配置的host，不需要验证
        let cerHosts:[String] = hosts.compactMap { url in
            if let host = URLComponents(string: url)?.host {
                return host
            }
            return url
        }
        if let apiHost = URLComponents(string: api)?.host, cerHosts.contains(apiHost) {
            return cerSession
        }
        return defaultSession
    }
    private init() {
        print("哈哈哈哈哈")
    }
}

// MARK: - 请求&取消

public extension HDNetworkingManager {
    
    /// get请求
    ///
    /// - Parameters:
    ///   - request: 请求参数，参数为请求参数实体对象
    ///   - success: 请求成功回调，参数为请求响应实体对象
    ///   - failure: 请求失败回调，参数为请求失败类型
    /// - Returns: 当前的请求DataRequest
    @discardableResult
    func get(request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        return self.request(method: .get, request: request, result: result)
    }
    
    /// post请求
    ///
    /// - Parameters:
    ///   - request: 请求参数，参数为请求参数实体对象
    ///   - success: 请求成功回调，参数为请求响应实体对象
    ///   - failure: 请求失败回调，参数为请求失败类型
    /// - Returns: 当前的请求DataRequest
    @discardableResult
    func post(request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        return self.request(method: .post, request: request, result: result)
    }
    
    /// put请求
    ///
    /// - Parameters:
    ///   - request: 请求参数，参数为请求参数实体对象
    ///   - success: 请求成功回调，参数为请求响应实体对象
    ///   - failure: 请求失败回调，参数为请求失败类型
    /// - Returns: 当前的请求DataRequest
    @discardableResult
    func put(request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        return self.request(method: .put, request: request, result: result)
    }
    
    /// delete请求
    ///
    /// - Parameters:
    ///   - request: 请求参数，参数为请求参数实体对象
    ///   - success: 请求成功回调，参数为请求响应实体对象
    ///   - failure: 请求失败回调，参数为请求失败类型
    /// - Returns: 当前的请求DataRequest
    @discardableResult
    func delete(request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        return self.request(method: .delete, request: request, result: result)
    }
    
    /// 取消所有未完成的请求
    func cancelAllTask() {
        self.cancelAllDataTasks()
    }
    
    /// 取消指定 api 的未完成请求
    /// - Parameter api: 取消指定api的请求, 为nil则取消当前session所有的未完成请求
    func cancelDataTask(api: String) {
        self.cancelDataTask(url: api)
    }
    
    /// 取消指定的未完成request
    /// - Parameter request: 指定的 DataRequest
    func cancel(request: HDRequestCancleable?) {
        self.cancelRequest(request)
    }

    /// 证书更新后需重置session
    func resetSession() {
        _cerSession = nil
    }
}

//MARK: - 网络请求配置方法

public extension HDNetworkingManager {
    
    /// 配置网络请求异常提示信息
    ///
    /// - Parameters:
    ///   - networkHint: 网络异常提示模型
    func configNetworkHint(_ networkHint: HDNetworkHint) {
        self.networkHint = networkHint
    }
    
    /// 配置通用请求头
    ///
    /// - Parameter generalHeaderHandle: 生成通用请求头闭包
    func configGeneralHeaderHandle(_ generalHeaderHandle: @escaping @autoclosure (() -> [String: String])) {
        self.generalHeaderHandler = generalHeaderHandle
    }
    
    /// 配置通用查询参数
    ///
    /// - Parameter generalHeaderHandle: 生成通用请求头闭包
    func configGeneralQueryParamHandler(_ generalQueryParamHandler: @escaping (() -> [String: String])) {
        self.generalQueryParamHandler = generalQueryParamHandler
    }
    
    /// 配置需要SSL证书认证的https请求的host
    /// - Parameter hosts: https 请求的host集合
    func configHttpsHostListHandle(_ hosts: (() -> Set<String>)?) {
        self.cerHostsHandle = hosts
    }

    /// 配置需要忽略SSL证书认证的Api
    /// - Parameter ignoreApiHandle: 动态配置的api
    func configIgnoreApiHandle(_ ignoreApiHandle: (() -> [String])?) {
        self.ignoreApiHandle = ignoreApiHandle
    }
    
    /// 是否开启日志打印
    ///
    /// - Parameter isEnable: 是否开启日志打印
    func configEnableDebug(_ isEnable: Bool) {
        self.isEnableDebug = isEnable
    }
    
    /// cer证书所在的Bundle
    /// - Parameter bundle: 指定的bundle
    func configCerBundle(_ bundle: Bundle) {
        self.cerBundle = bundle
    }
    
    /// 错误处理
    ///
    /// - Parameter error: error
    /// - Returns: 根据Error，返回对应的错误描述
    func responseErrorType(error: Error) -> HDRequestError? {
        // 如果未设置网络异常提示模型，则使用默认提示文案
        if self.networkHint == nil {
            self.networkHint = HDNetworkHint()
        }
        
        var errorCode = URLError.unknown
        if let afError = error as? AFError,
           let underlyingError = afError.underlyingError {
            if let urlError = underlyingError as? URLError {
                errorCode = urlError.code
            } else {
                let code = (underlyingError as NSError).code
                errorCode = URLError.Code(rawValue: code)
            }
        }
        
        var errorType = HDRequestError.serviceException(networkHint!.serviceExceptionMsg)
        print("@@@@@@@@", error)
        switch errorCode {
        case .timedOut, .cannotLoadFromNetwork:
            errorType = .timeout(networkHint!.timeoutMsg)
            
        case .networkConnectionLost, .notConnectedToInternet, .internationalRoamingOff:
            
            errorType = .netless(networkHint!.netlessMsg)
            
        case .cannotConnectToHost, .cannotFindHost, .badURL:
            errorType = .serviceException(networkHint!.serviceExceptionMsg)
            
        case .cancelled:
            errorType = .cancelled(networkHint!.cancelledMsg)
            
        default:
            errorType = .serviceException(networkHint!.serviceExceptionMsg)
        }
        
        return errorType
    }
}

// MARK: - 处理并发出请求

private extension HDNetworkingManager {
    
    /// 网络请求
    ///
    /// - Parameters:
    ///   - request: 请求参数，参数为请求参数实体对象
    ///   - success: 请求成功回调，参数为请求响应实体对象
    ///   - failure: 请求失败回调，参数为请求失败提示
    func request(method: HTTPMethod, request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        
        /// 设置网络超时时间
        self.timeout = TimeInterval(request.timeout)
        
        // 获取通用请求头
        var requestHeaders = HTTPHeaders()
        if let generalHeaders = self.generalHeaderHandler?() {
            generalHeaders.forEach { (header) in
                requestHeaders.add(HTTPHeader(name: header.key, value: header.value))
            }
        }
        // 添加附加的headers
        if let appendHeaders = request.appendHeaders {
            appendHeaders.forEach { (header) in
                requestHeaders.add(HTTPHeader(name: header.key, value: header.value))
            }
        }
        request.headers = requestHeaders
        
        // 获取通用查询参数
        if let queryParams = self.generalQueryParamHandler?() {
            if request.extraQueryParams == nil {
                request.extraQueryParams = [String: Any]()
            }
            
            queryParams.forEach { (header) in
                let (key, value) = header
                request.extraQueryParams?.updateValue(value, forKey: key)
            }
        }
        if let _ = request.httpBody {
            return requestJSON(method: method, request: request, result: result)
            
        } else {
            return json(method: method, request: request, result: result)
        }
    }
    
    /// 直接设置 httpBody 的请求方式
    func requestJSON(method: HTTPMethod, request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        do {
         
            var handledRequest = try request.asURLRequest()
            handledRequest.httpMethod = method.rawValue
            handledRequest.timeoutInterval = timeout
            handledRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            /// 外部附加请求头设置
            if let appendHeaders = request.appendHeaders {
                appendHeaders.forEach { (header) in
                    handledRequest.setValue(header.value, forHTTPHeaderField: header.key)
                }
            }
            // 针对请求设置Content-Type
            let encoding = self.handleEncodeingType(request: request, method: method)
            if encoding is JSONEncoding {
                handledRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } else {
                handledRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            let session = httpSession(for: request.api)
            let dataRequest = session.request(handledRequest)
            
            return self.request(dataRequest, result: result)
        } catch {
            return nil
        }
    }
    
    /// 设置params的请求方式
    func json(method: HTTPMethod, request: HDRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
                
        if let api = try? request.asURL().absoluteString {
            request.api = api
        }
        
        let encoding = self.handleEncodeingType(request: request, method: method)
        let session = httpSession(for: request.api)
        let dataRequest = session.request(request.api, method: method, parameters: request.params, encoding: encoding, headers: request.headers, requestModifier: {$0.timeoutInterval = self.timeout})

        return self.request(dataRequest, result: result)
    }
    
    /// 请求数据及数据处理
    func request(_ request: DataRequest, result: @escaping ((Result<Any, HDRequestError>) -> Void)) -> HDRequestCancleable? {
        return request.responseJSON {(response) in
            switch response.result {
            case .success(let json):
                result(.success(json))
                
            case .failure(let error):
                result(.failure(self.defaultError()))
            }
        }
    }
    
    /// 取消指定 request
    func cancelRequest(_ request: HDRequestCancleable?) {
        request?.cancel()
    }
    
    /// 取消所有未完成的请求
    func cancelAllDataTasks() {
        defaultSession.session.getAllTasks { (tasks) in
            tasks.forEach{$0.cancel()}
        }
        cerSession.session.getAllTasks { (tasks) in
            tasks.forEach{$0.cancel()}
        }
    }
    
    /// 取消指定api请求
    func cancelDataTask(url: String) {
        /// 获取未完成的任务
        let session = httpSession(for: url)
        session.session.getTasksWithCompletionHandler({ (dataTasks, _, _) in
            dataTasks.forEach {
                if let taskURL = $0.originalRequest?.url?.absoluteString, taskURL.contains(url) {
                    $0.cancel()
                }
            }
        })
    }
    
    /// 根据请求方式及请求对象返回ParameterEncoding对象, 编码方式
    ///
    /// - Parameters:
    ///   - request: 指定的请求对象
    ///   - method: 指定的请求方式
    /// - Returns: ParameterEncoding对象
    func handleEncodeingType(request: HDRequest, method: HTTPMethod) -> ParameterEncoding {
        var encodeing: ParameterEncoding = URLEncoding.default
        if request.encoding != nil {
            encodeing = request.encoding!
        } else {
            switch method {
            case .post:
                encodeing = JSONEncoding.default
                
            default:
                break
            }
        }
        return encodeing
    }
    
    /// 默认错误
    /// - Returns: 错误类型
    func defaultError() -> HDRequestError {
        guard let networkHint = self.networkHint else {
            return HDRequestError.serviceException(HDNetworkHint().serviceExceptionMsg)
        }
        return HDRequestError.serviceException(networkHint.serviceExceptionMsg)
    }
    
    /// 获取Api的 host·
    func apiHost(_ api: String?) -> String? {
        guard let apiURL = api else {return nil}
        return URLComponents(string: apiURL)?.host
    }
}
