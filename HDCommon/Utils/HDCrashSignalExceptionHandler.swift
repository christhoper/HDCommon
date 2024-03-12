//
//  HDCrashSignalExceptionHandler.swift
//  HDCommon
//
//  Created by bailun on 2024/2/26.
//

import Darwin

private var app_old_exceptionHandler:(@convention(c) (NSException) -> Swift.Void)? = nil

/*
 SIGABRT--程序中止命令中止信号
 SIGFPE--程序浮点异常信号
 SIGILL--程序非法指令信号
 SIGSEGV--程序无效内存中止信号
 SIGBUS--程序内存字节未对齐中止信号
 SIGPIPE--程序Socket发送失败中止信号
 SIGTRAP--断点
 SIGSYS--进程试图执行一个未定义的系统调用
 SIGALRM--程序超时信号
 SIGHUP--程序终端中止信号
 SIGINT--程序键盘中断信号
 SIGKILL--程序结束接收中止信号
 SIGTERM--程序kill中止信号
 SIGSTOP--程序键盘中止信号
 */

// MARK: - 崩溃类型
private enum CrashType {
    
    /// 信号
    case signal
    
    case exception
    
    var name: String {
        switch self {
        case .signal:
            return "Signal 崩溃"
        case .exception:
            return "Exception 崩溃"
        }
    }
}

public class HDCrashSignalExceptionHandler {
    
    private static var crashType: CrashType = .exception
    
    /// 注册
    public static func registerHandlers() {
        
        // 其他库注册的
        backupOriginalHandlers()
        
        //
        signalsRegister()
    }
}

private extension HDCrashSignalExceptionHandler {
    
    static func backupOriginalHandlers() {
        app_old_exceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(HDExtensionHandle)
    }
    
    static func signalsRegister() {
        signal(SIGABRT, HDSignalHandle)
        signal(SIGBUS, HDSignalHandle)
        signal(SIGFPE, HDSignalHandle)
        signal(SIGILL, HDSignalHandle)
        signal(SIGPIPE, HDSignalHandle)
        signal(SIGSEGV, HDSignalHandle)
        signal(SIGSYS, HDSignalHandle)
        signal(SIGTRAP, HDSignalHandle)
    }
    
    static let HDExtensionHandle: @convention(c) (NSException) -> Swift.Void = {
        (exteption) -> Void in
        if (app_old_exceptionHandler != nil) {
            app_old_exceptionHandler!(exteption)
        }

        crashType = .exception
        let callStack = exteption.callStackSymbols.joined(separator: "\r")
        let reason = exteption.reason ?? ""
        let name = exteption.name
        
        let stackTrace = Thread.callStackSymbols.map { frame -> String in
          let components = frame.components(separatedBy: ":")
          guard components.count >= 2 else {
            return frame
          }
          let functionName = components[1]
          let address = components[2]
          return "\(functionName) (\(address))"
        }.joined(separator: "\n")
        
        logInfo(signal: 0, stackTrace: callStack, descrision: "\(callStack)\r \(reason) \r \(name)")
    }
    
    static let HDSignalHandle: @convention(c) (Int32) -> Void = {
        (signal) -> Void in
        crashType = .signal
        var stack = Thread.callStackSymbols
        stack.removeFirst(2)
        let callStack = stack.joined(separator: "\r")
        logInfo(signal: signal, stackTrace: callStack, descrision: "Signal crash")
        killApp()
    }
    
    static func logInfo(signal: Int32, stackTrace: String, descrision: String) {
        let appVersion = Bundle.hd.appVersion
        let appName = Bundle.hd.appDisplayName
        let date = Date().hd.toformatterTimeString(formatter: "yyyy-MM-dd")
        let date1 = Date().hd.toformatterTimeString(formatter: "HH:mm:ss")
        let hms = date1.components(separatedBy: ":").joined(separator: "-")
        let error = NSError(domain: "com.crash.app", code: 1, userInfo: nil)
        // 获取当前线程的名称
        let thread = Thread.current
        let threadName: String = thread.name ?? "线程名是空的"
        let content = """
        时间: \(date) \(date1)
        线程: \(threadName)
        APP版本: \(appVersion)
        APP名: \(appName)
        崩溃类型: \(crashType.name)
        错误: \(error)
        错误类型:\(name(of: signal))
        Reason: \(descrision)
        堆栈信息:
        \(stackTrace)
        """
        
        FileManager.hd.writeData(for: "\(date)-\(hms)", data: content.data(using: .utf8))
    
    }
    
    static func name(of signal: Int32) -> String {
        switch (signal) {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }
    
    static func killApp() {
        NSSetUncaughtExceptionHandler(nil)
        signal(SIGABRT, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGSYS, SIG_DFL)
        signal(SIGTRAP, SIG_DFL)
        
        kill(getpid(), SIGKILL)
    }
}
