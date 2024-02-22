//
//  HDNetworkingManager+FileManager.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/21.
//

// MARK: - 证书下载存储管理
public extension FileManager {

    /// 下载保存证书
    @discardableResult
    func downloadCer(url: String?) -> Data? {
        guard let urlStr = url, !urlStr.isEmpty, let loadURL = URL(string: urlStr) else {
            return nil
        }
        do {
            let fileName = loadURL.lastPathComponent
            let data: Data = try Data(contentsOf: loadURL)
            self.saveCertification(for: fileName, data: data)
            return data
        } catch {
            print("❎❎~证书下载失败:❎❎\(error.localizedDescription)~")
            return nil
        }
    }
    
    /// 本地文件路径
    private func configureLocalFolder() -> String {
        if let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
           let info = Bundle.main.infoDictionary {
            let projectName = info["CFBundleExecutable"] as? String ?? "STL"
            return (document as NSString).appendingPathComponent("/\(projectName)/Cer")
        }
        return ""
    }
    
    private func saveCertification(for certificationName: String = "certification", path: String?) {
        guard let path = path else {
            print("❎❎path为空❎❎")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url) {
            self.saveCertification(data: data)
        }
    }
    
    //MARK: - 保存证书
    func saveCertification(for certificationName: String = "certification", data: Data?) {
        guard let data = data else {
            print("❎❎data为空❎❎")
            return
        }
    
        let savePath = configureLocalFolder()
        /// 是否存在
        let fileExists = FileManager.default.fileExists(atPath: savePath)
        if !fileExists {
            do {
                try FileManager.default.createDirectory(atPath: savePath, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: URL(fileURLWithPath: "\(savePath)/\(certificationName)"))
            } catch {
                print("❎❎创建文件夹失败❎❎")
            }
        } else {
            do {
                try data.write(to: URL(fileURLWithPath: "\(savePath)/\(certificationName)"))
            } catch {
                print("❎❎保存失败❎❎")
            }
        }
    }
    
    //MARK: - 读取证书
    func getCertification(for certificationName: String = "certification") -> Data? {
        let localPath = configureLocalFolder() + "/\(certificationName)"
        let url = URL(fileURLWithPath: localPath)
        let handle = try? FileHandle(forReadingFrom: url)
        let data = handle?.readDataToEndOfFile()
        return data
    }
    
    //MARK: - 读取某个文件下所有的数据
    func getAllCertifications() -> [Data]? {
        let localPath = configureLocalFolder()
        let paths = try? FileManager.default.contentsOfDirectory(atPath: localPath)
        var results: [Data]?
        if let allPaths = paths {
            results = allPaths.compactMap{ (path) in
                let url = URL(fileURLWithPath: localPath + "/\(path)")
                let handle = try? FileHandle(forReadingFrom: url)
                let data = handle?.readDataToEndOfFile()
                if let resultData = data {
                    return resultData
                }
                return nil
            }
        }
        
        return results
    }
    
    //MARK: - 删除整个Folder
    func removeFolder() {
        let folder = configureLocalFolder()
        try? FileManager.default.removeItem(atPath: folder)
    }
}

// MARK: - 证书数据
public extension HDNetworkingManager {

    /// 获取证书公钥
    /// - Parameter urls: 证书下载url
    /// - Returns: 证书数据
    func getCertifications() -> [SecCertificate] {

        /// 1、优先读取本地沙盒证书
        if let datas = FileManager.default.getAllCertifications() {
            return configCertifications(for: datas)
        }

        /*
        2、本地没有，获取网络证书
           ①存取证书
        */

        let cerURLs = HDCertificationManager.shared.getCerUrls()
        if cerURLs.isEmpty {return []}

        var datas: [Data]?
        datas = cerURLs.compactMap { url in
            return FileManager.default.downloadCer(url: url)
        }
        return configCertifications(for: datas)
    }

    /// 获取公钥
    /// - Parameter datas: 证书data
    private func configCertifications(for datas: [Data]?) -> [SecCertificate] {
        guard let cerDatas = datas else {
            return []
        }
        var certtificates: [SecCertificate] = []
        // 因为沙河里面文件没有添加后缀。所以暂时不用考虑过滤文件格式问题 (".cer", ".CER", ".crt", ".CRT", ".der", ".DER")
        certtificates = cerDatas.compactMap { data in
            let certificateData = data as CFData
            if let certificate = SecCertificateCreateWithData(nil, certificateData) {
                return certificate
            }
            return nil
        }
        return certtificates
    }
}
