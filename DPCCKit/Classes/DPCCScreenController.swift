//
//  DPCCScreenController.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/29.
//

import UIKit
import SinoDetection

final class DPCCScreenController: DPCCBaseController {
    
    var manger = DPCCBluetoothManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScreenUI()
        addNotification()
    }
    
    fileprivate func initScreenUI() {
        view.backgroundColor = .white
        print(DPCCApiConfig.h5ScreenApi)
        if let url = URL.init(string: DPCCApiConfig.h5ScreenApi) {
            webView.load(URLRequest.init(url: url))
        }
        messageHandler.connectDelegate = self
        manger.removeBindDevice()
    }
    
    deinit {
        manger.removeBindDevice()
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(forName: Notification.Name.DPCCDeviceResult, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self else { return }
            if let dict = notification.userInfo as? [String: String] {
                print(dict)
                let str = convertJsonFrom(dict: dict as NSDictionary)
                let jsStr = H5DeviceResult + "(" + str + ")"
                self.webView.evaluateJavaScript(jsStr)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.DPCCDeviceStatus, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self else { return }
            if let dict = notification.userInfo as? [String: String] {
                print(dict)
                let str = convertJsonFrom(dict: dict as NSDictionary)
                let jsStr = H5DeviceStatus + "(" + str + ")"
                self.webView.evaluateJavaScript(jsStr)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.DPCCBluetoothStatus, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let `self` = self else { return }
            if let dict = notification.userInfo as? [String: String] {
                print("App主动:",dict)
                let str = convertJsonFrom(dict: dict as NSDictionary)
                let jsStr = H5BluetoothStatus + "(" + str + ")"
                self.webView.evaluateJavaScript(jsStr)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manger.bindAllDevice()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        manger.disConnectDevices()
        DPCCBluetoothManager.destroy()
    }
    
}

extension DPCCScreenController: DPCCConnectDelegate {
    
    func sendConnect() {
        manger.connectDevice()
    }
    
    func sendBluetoothstate() {
        var dict = [String : String]()
        if DPCCBluetoothManager.shared().isBluetoothOpen {
            dict["status"] = "1"
        } else {
            dict["status"] = "0"
        }
        print("H5主动:",dict)
        let str = convertJsonFrom(dict: dict as NSDictionary)
        let jsStr = H5BluetoothStatus + "(" + str + ")"
        self.webView.evaluateJavaScript(jsStr)
    }
    
    func sendDisconnect() {
        manger.disConnectDevices()
    }
    
}
