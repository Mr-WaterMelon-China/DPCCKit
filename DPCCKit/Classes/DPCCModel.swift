//
//  DPCCModel.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/28.
//

import Foundation

// MARK: -环境
enum DPCCEnvironment: String {
    case develop = "Develop" // 开发
    case test = "Test" // 测试
    case production = "App Store" // 正式
}

// MARK: -全局配置信息
struct GlobalConfig {
    
    // 修改环境打包 0-开发 1-测试 2-生产
    fileprivate static let environmentIndex = 1
    
    // 当前使用的环境
    static var environment: DPCCEnvironment {
        return [.develop, .test, .production][environmentIndex]
    }
}

struct DPCCApiConfig {
    
    static var h5DeviceApi: String {
        var str = ""
        switch GlobalConfig.environment {
        case .develop:
            str =  "http://172.9.193.138:8081/"
        case .test:
            str =  "https://management.national-dpcc.com/"
        case .production:
            str = "https://management.national-dpcc.com/"
        }
        return str + "#/dpcc-bluetooth-dpccMange"
    }
    
    static var h5ScreenApi: String {
        var str = ""
        switch GlobalConfig.environment {
        case .develop:
            str =  "http://172.9.193.138:8081/"
        case .test:
            str =  "https://management.national-dpcc.com/"
        case .production:
            str = "https://management.national-dpcc.com/"
        }
        return str + "#/dpcc-bluetooth-screening"
    }
}

struct DPCCUserDefaultsManager {
    
    static func set(_ value: Any?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        UserDefaults.standard.synchronize()
    }

    static func removeObject(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func clear() {
        _ = UserDefaults.standard.dictionaryRepresentation().map {
            UserDefaults.standard.removeObject(forKey: $0.key)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func removeModel(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func object(forKey defaultName: String) -> Any? {
        return UserDefaults.standard.object(forKey: defaultName)
    }

    static func string(forKey defaultName: String) -> String? {
        return UserDefaults.standard.string(forKey: defaultName)
    }

    static func integer(forKey defaultName: String) -> Int {
        return UserDefaults.standard.integer(forKey: defaultName)
    }

    static func bool(forKey defaultName: String) -> Bool {
        return UserDefaults.standard.bool(forKey: defaultName)
    }

    static func double(forKey defaultName: String) -> Double {
        return UserDefaults.standard.double(forKey: defaultName)
    }

}

struct DPCCUserDefaultsKey {
    //账号
    static let account = "DPCC.account"
    //密码
    static let password = "DPCC.password"
    //用户名
    static let name = "DPCC.name"
    //机构名
    static let customerName = "DPCC.customerName"
    //token
    static let accessToken = "DPCC.accessToken"
    //血糖仪
    static let sugarDevice = "DPCC.sugarDevice"
    //血压计
    static let pressureDevice = "DPCC.pressureDevice"
    //身高体重仪
    static let heightDevice = "DPCC.heightDevice"
    //腰围尺
    static let waistDevice = "DPCC.waistDevice"
}

class UserCookies: NSObject {
    
    static let shared = UserCookies()
    
    override init() {
        super.init()
    }
    
    var account: String {
        if let type = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.account) as? String {
            return type
        } else {
            return ""
        }
    }
    
    var password: String {
        if let type = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.password) as? String {
            return type
        } else {
            return ""
        }
    }
    
    var name: String {
        if let type = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.name) as? String {
            return type
        } else {
            return ""
        }
    }
    
    var customerName: String {
        if let type = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.customerName) as? String {
            return type
        } else {
            return ""
        }
    }
    
    var accessToken: String {
        if let type = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.accessToken) as? String {
            return type
        } else {
            return ""
        }
    }
    
    var sugarDevice: [String: AnyObject]? {
        if let dict = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.sugarDevice) as? [String: AnyObject] {
           return dict
        }
        return nil
    }
    
    var pressureDevice: [String: AnyObject]? {
        if let dict = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.pressureDevice) as? [String: AnyObject] {
           return dict
        }
        return nil
    }
    
    var heightDevice: [String: AnyObject]? {
        if let dict = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.heightDevice) as? [String: AnyObject] {
           return dict
        }
        return nil
    }
    
    var waistDevice: [String: AnyObject]? {
        if let dict = DPCCUserDefaultsManager.object(forKey: DPCCUserDefaultsKey.waistDevice) as? [String: AnyObject] {
           return dict
        }
        return nil
    }
}

extension Notification.Name {
    //数据
    static let DPCCDeviceResult:Notification.Name = Notification.Name(rawValue: "DPCCDeviceResult")
    //设备状态
    static let DPCCDeviceStatus:Notification.Name = Notification.Name(rawValue: "DPCCDeviceStatus")
    //蓝牙状态
    static let DPCCBluetoothStatus:Notification.Name = Notification.Name(rawValue: "DPCCBluetoothStatus")
}

enum DPCCValueType: String {
    case pressure = "bloodPressure"
    case sugar = "bloodGlucose"
    case waist = "waist"
    case height = "HeightAndWeight"
}

class DPCCDeviceModel: NSObject {
    
    var parentType = ""
    var bluetoothName = ""
    var productName = ""
    var uuidString = ""
    var macAddress = ""
    var deviceType = ""
    var productCode = ""
    var dataProtocolCode = ""
    var machineCode = ""
    
    required init(withDict dict: [String: AnyObject]) {
        if let temp = dict["parentType"] as? String {
            parentType = temp
        }
        if let temp = dict["bluetoothName"] as? String {
            bluetoothName = temp
        }
        if let temp = dict["productName"] as? String {
            productName = temp
        }
        if let temp = dict["uuidString"] as? String {
            uuidString = temp
        }
        if let temp = dict["productCode"] as? String {
            productCode = temp
        }
        if let temp = dict["macAddress"] as? String {
            macAddress = temp
        }
        if let temp = dict["deviceType"] as? String {
            deviceType = temp
        }
        if let temp = dict["dataProtocolCode"] as? String {
            dataProtocolCode = temp
        }
        if let temp = dict["machineCode"] as? String {
            machineCode = temp
        }
    }
}

class DPCCPressureModel: NSObject {
    
    var P: DPCCValueModel? //脉搏
    var BloodMeasureHigh: DPCCValueModel? //收缩压
    var BloodMeasureLow: DPCCValueModel? //舒张压

    required init(withDict dict: [String: AnyObject]) {
        if let temp = dict["P"] as? [String: AnyObject] {
            P = DPCCValueModel.init(withDict: temp)
        }
        if let temp = dict["BloodMeasureHigh"] as? [String: AnyObject] {
            BloodMeasureHigh = DPCCValueModel.init(withDict: temp)
        }
        if let temp = dict["BloodMeasureLow"] as? [String: AnyObject] {
            BloodMeasureLow = DPCCValueModel.init(withDict: temp)
        }
    }
}

class DPCCHeightModel: NSObject {
    
    var height: DPCCValueModel?
    var weight: DPCCValueModel?

    required init(withDict dict: [String: AnyObject]) {
        if let temp = dict["height"] as? [String: AnyObject] {
            height = DPCCValueModel.init(withDict: temp)
        }
        if let temp = dict["weight"] as? [String: AnyObject] {
            weight = DPCCValueModel.init(withDict: temp)
        }
    }
}

class DPCCSugarModel: NSObject {
    
    var glu: DPCCValueModel?
    
    required init(withDict dict: [String: AnyObject]) {
        if let temp = dict["GLU"] as? [String: AnyObject] {
            glu = DPCCValueModel.init(withDict: temp)
        }
    }
}

class DPCCValueModel: NSObject {
    
    var value = "" //值
    var unit = "" //单位

    required init(withDict dict: [String: AnyObject]) {
        if let temp = dict["value"] as? String {
            value = temp
        }
        if let temp = dict["unit"] as? String {
            unit = temp
        }
    }
}

class DPCCTOSDKModel: NSObject {
    
    var deviceType: UInt = 0
    var productCode = ""
    var dataProtocolCode = ""
    var machineCode = ""
    
    required init(_ type: UInt,
                  pCode: String,
                  dCode: String,
                  mCode: String) {
        deviceType = type
        productCode = pCode
        dataProtocolCode = dCode
        machineCode = mCode
    }
}
