//
//  HDCertificationManager.swift
//  HDCommon
//
//  Created by Hendy on 2024/2/21.
//

final public class HDCertificationManager {
    
    public static let shared = HDCertificationManager()
    
    private init() {}
    
    private let CerInfokey = "CerInfoModelCacheKey"

    /// 更新本地保存证书信息
    public func updateCerInfoModels(_ models: [HDHostInfo]) {
        // 更新前先移除之前的证书文件
        FileManager.default.removeFolder()

        // 异步下载新证书
        DispatchQueue.global().async {
            models.forEach { info in
                FileManager.default.downloadCer(url: info.certPath)
            }
            // host证书更新完重置session, 发送更新通知
            HDNetworkingManager.shared.resetSession()
        }

        // 保存证书下载信息
        let data = NSKeyedArchiver.archivedData(withRootObject: models)
        UserDefaults.standard.set(data, forKey: CerInfokey)
    }

    public func getCerInfoModel() -> [HDHostInfo]? {
        guard let data = UserDefaults.standard.value(forKey: CerInfokey) as? Data else  {
            return nil
        }
        return (NSKeyedUnarchiver.unarchiveObject(with: data) as? [HDHostInfo]) ?? nil
    }

    public func getCerUrls() -> [String] {
        guard let infos = getCerInfoModel(), !infos.isEmpty else {
            return []
        }
        return infos.compactMap{ entity in
            guard let url = entity.certPath, !url.isEmpty else {
                return nil
            }
            return url
        }
    }
}


// MARK: - HostInfoEntity
public class HDHostInfo: NSObject, NSCoding {

    // 域名服务id
    public var serviceId: Int = 0
    // 域名映射的ip
    public var ip: String?
    // 域名地址
    public var host: String?
    // cer证书下载更新地址
    public var certPath: String?
    // 域名描述
    public var hostDesc: String?

    public func encode(with coder: NSCoder) {
        coder.encode(serviceId, forKey: "serviceId")
        coder.encode(ip, forKey: "ip")
        coder.encode(host, forKey: "host")
        coder.encode(certPath, forKey: "certPath")
        coder.encode(hostDesc, forKey: "hostDesc")
    }

    required override public init() {
        super.init()
    }

    // MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        serviceId = aDecoder.decodeInteger(forKey: "serviceId")
        ip = aDecoder.decodeObject(forKey: "ip") as? String
        host = aDecoder.decodeObject(forKey: "host") as? String
        certPath = aDecoder.decodeObject(forKey: "certPath") as? String
        hostDesc = aDecoder.decodeObject(forKey: "hostDesc") as? String
    }
}

