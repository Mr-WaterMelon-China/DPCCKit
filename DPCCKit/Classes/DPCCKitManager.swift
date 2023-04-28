//
//  DPCCKitManager.swift
//  DPCCKit
//
//  Created by 李旺 on 2023/4/27.
//

import Foundation
import SinoDetection

public class DPCCKitManager: NSObject {
    
    public static let shared = DPCCKitManager()
    
    fileprivate override init() {
        super.init()
    }
    
    public class func auth(appKey: String, bundleId: String) {
        SDAuthManager.shared().auth(withAppKey: appKey, bundleId: bundleId)
        let auth = SDAuthManager.shared().authed
        print(auth)
    }
    
    public func getResult(_ type: String,resultVC:@escaping (_ vc:UIViewController) -> Void ) {
        switch type {
        case "0":
            let vc = DPCCDeviceController()
            resultVC(vc)
        case "1":
            let vc = DPCCScreenController()
            resultVC(vc)
        default:
            break
        }
    }
    
}
