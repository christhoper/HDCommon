//
//  HDCrashSignalExceptionHandler.swift
//  HDCommon
//
//  Created by bailun on 2024/2/26.
//

import Darwin

typealias HDSignalHandler = @convention(c) (Int32, UnsafeMutablePointer<siginfo_t>?, UnsafeMutableRawPointer?) -> Void

/*
 SIGABRT--程序中止命令中止信号
 SIGALRM--程序超时信号
 SIGFPE--程序浮点异常信号
 SIGILL--程序非法指令信号
 SIGHUP--程序终端中止信号
 SIGINT--程序键盘中断信号
 SIGKILL--程序结束接收中止信号
 SIGTERM--程序kill中止信号
 SIGSTOP--程序键盘中止信号
 SIGSEGV--程序无效内存中止信号
 SIGBUS--程序内存字节未对齐中止信号
 SIGPIPE--程序Socket发送失败中止信号
 */

var ABRTSignalHandler: HDSignalHandler? = nil
var BUSSignalHandler: HDSignalHandler? = nil
var FPESignalHandler: HDSignalHandler? = nil
var ILLSignalHandler: HDSignalHandler? = nil
var PIPESignalHandler: HDSignalHandler? = nil
var SEGVSignalHandler: HDSignalHandler? = nil
var SYSSignalHandler: HDSignalHandler? = nil
var TRAPSignalHandler: HDSignalHandler? = nil

public class HDCrashSignalExceptionHandler {
    
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


    }
    
    static func signalsRegister() {
        HDSignalRegister(signal: SIGABRT)
        HDSignalRegister(signal: SIGBUS)
        HDSignalRegister(signal: SIGFPE)
        HDSignalRegister(signal: SIGILL)
        HDSignalRegister(signal: SIGPIPE)
        HDSignalRegister(signal: SIGSEGV)
        HDSignalRegister(signal: SIGSYS)
        HDSignalRegister(signal: SIGTRAP)
    }
    
}

func HDSignalRegister(signal: Int32) {
    let action = __sigaction_u(__sa_sigaction: signalHandler)
    var sigActionNew = sigaction(__sigaction_u: action, sa_mask: sigset_t(), sa_flags: signal)

    if sigaction(SIGUSR2, &sigActionNew, nil) != 0 {
        return
    }
}


private func signalHandler(code: Int32, info: UnsafeMutablePointer<__siginfo>?, uap: UnsafeMutableRawPointer?) -> Void {
    // 屏蔽其他库的信号处理程序
//    var mask = sigset_t()
//    sigemptyset(&mask)
//    sigaddset(&mask, signal)
//    sigprocmask(SIG_BLOCK, &mask, nil)
    
    // 获取当前时间
    let date = Date()
    // 获取应用程序的名称和版本号
//    let process = Process()
//    let appName = process.infoDictionary?["CFBundleName"] as? String
//    let appVersion = process.infoDictionary?["CFBundleShortVersionString"] as? String

    // 获取当前线程的名称
    let thread = Thread.current
    let threadName = thread.name

    // 创建自定义错误
    let error = NSError(domain: "com.example.app", code: 1, userInfo: nil)

    // 格式化堆栈信息
    let stackTrace = Thread.callStackSymbols.map { frame -> String in
      let components = frame.components(separatedBy: ":")
      guard components.count >= 2 else {
        return frame
      }
      let functionName = components[1]
      let address = components[2]
      return "\(functionName) (\(address))"
    }.joined(separator: "\n")

    let data = """
    时间: \(date)
    线程: \(threadName)
    错误: \(error)

    堆栈信息:
    \(stackTrace)
    """
    // 将堆栈信息写入文件
    
    FileManager.hd.writeData(data: data.data(using: .utf8))
    // 退出应用程序
    exit(1)
}
