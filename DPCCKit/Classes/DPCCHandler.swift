//
//  DPCCHandler.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/25.
//

import Foundation
import WebKit

//用于原生以及H5交互的对象
let DPCCBridgeKey = "DPCCBridge"

//方法名,H5调用具体哪个原生方法
let DPCCMethodKey = "function"

//原生回调H5哪个方法，用于原生传递参数给H5
let H5CallBack = "callBack"

//H5调用原生的时候带的参数
let DPCCParams = "params"

//H5获取原生用户信息
let DPCCAccountInfo = "getAccountInfo"

//H5获取原生设备列表
let DPCCDeviceList = "getDeviceList"

//H5获取原生用户信息
let DPCCSaveUserInfo = "saveUserInfo"

//H5调用原生back
let DPCCBack = "back"

//H5调用原生搜索设备
let DPCCScan = "scanDevice"

//H5调用原生绑定设备
let DPCCBind = "bindDevice"

//H5调用原生清除数据
let DPCCClear = "clearData"

//H5调用原生连接
let DPCCConnect = "connectDevice"

//H5调用蓝牙状态
let DPCCBloothState = "bloothState"

//原生调用H5连接状态
let H5DeviceStatus = "DPCC_deviceState"

//原生调用H5数据结果
let H5DeviceResult = "DPCC_deviceResult"

//原生调用H5蓝牙权限开关
let H5BluetoothStatus = "DPCC_bloothState"

//H5调用原生断开连接
let DPCCDisconnect = "disconnect"

func convertJsonFrom(dict: NSDictionary?) -> String {
  
    let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    return jsonStr! as String
}

func convertJsonFrom(array: Array<Any>) -> String {
     
    if (!JSONSerialization.isValidJSONObject(array)) {
        return ""
    }
     
    let data = try? JSONSerialization.data(withJSONObject: array, options: [])
    if let temp = data {
        let JSONString = NSString(data:temp as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    return ""
     
}

class DPCCHandler: NSObject,WKScriptMessageHandler {
    
    weak open var scanDelegate: DPCCScanDelegate?
    
    weak open var commonDelegate: DPCCCommonDelegate?
    
    weak open var connectDelegate: DPCCConnectDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if let dict = message.body as? [String: AnyObject] {
            
            //js调用app的方法名
            let functionName = dict[DPCCMethodKey] as? String
            //app调用js的方法名称
            let callBack = dict[H5CallBack] as? String
            //js携带的参数
            let params = dict[DPCCParams] as? [String: String]

            switch functionName {
            case DPCCAccountInfo:
                getAccountInfo(callBack)
                
            case DPCCDeviceList:
                getDeviceList(callBack)
                
            case DPCCSaveUserInfo:
                saveAccountInfo(params)
                
            case DPCCBack:
                backAction()
                
            case DPCCScan:
                scanDevice(callBack, params: params)
                
            case DPCCBind:
                bindDevice(params)
                
            case DPCCClear:
                clearData()
                
            case DPCCConnect:
                connect()
                
            case DPCCBloothState:
                bluetoothState()
                
            case DPCCDisconnect:
                disconnect()
                
            default: break
            }
        }
    }
    
    fileprivate func getAccountInfo(_ callBack: String?) {
        commonDelegate?.sendAccountInfo(callBack)
    }
    
    fileprivate func getDeviceList(_ callBack: String?) {
        commonDelegate?.sendDeviceList(callBack)
    }
    
    fileprivate func saveAccountInfo(_ params: [String:Any]?) {
        guard let temp = params else {
            return
        }
        if let account = temp["account"] as? String {
            DPCCUserDefaultsManager.set(account, forKey: DPCCUserDefaultsKey.account)
        }
        if let password = temp["password"] as? String {
            DPCCUserDefaultsManager.set(password, forKey: DPCCUserDefaultsKey.password)
        }
        if let customerName = temp["customerName"] as? String {
            DPCCUserDefaultsManager.set(customerName, forKey: DPCCUserDefaultsKey.customerName)
        }
        if let name = temp["name"] as? String {
            DPCCUserDefaultsManager.set(name, forKey: DPCCUserDefaultsKey.name)
        }
        if let access_token = temp["access_token"] as? String {
            DPCCUserDefaultsManager.set(access_token, forKey: DPCCUserDefaultsKey.accessToken)
        }
        
    }
    
    fileprivate func backAction() {
        commonDelegate?.sendBack()
    }
    
    fileprivate func scanDevice(_ callBack: String?,params: [String: String]?) {
        scanDelegate?.sendScanDevice(callBack, params: params)
    }
    
    fileprivate func bindDevice(_ params: [String: String]?) {
        scanDelegate?.sendBindDevice(params)
    }
    
    fileprivate func clearData() {
        scanDelegate?.sendClearData()
    }
    
    fileprivate func connect() {
        connectDelegate?.sendConnect()
    }
    
    fileprivate func bluetoothState() {
        connectDelegate?.sendBluetoothstate()
    }
    
    fileprivate func disconnect() {
        connectDelegate?.sendDisconnect()
    }
}

protocol DPCCCommonDelegate: NSObjectProtocol {
    
   //获取账号信息
   func sendAccountInfo(_ callBack: String?)
   
   //获取账号设备列表
   func sendDeviceList(_ callBack: String?)
    
   //回到原生
   func sendBack()
    
}

protocol DPCCScanDelegate: NSObjectProtocol {
    
    //搜索设备
    func sendScanDevice(_ callBack: String?,params: [String: String]?)
    
    //绑定设备
    func sendBindDevice(_ params: [String: String]?)
    
    //清除设备
    func sendClearData()
}

protocol DPCCConnectDelegate: NSObjectProtocol {
    
    //连接设备
    func sendConnect()
    
    //蓝牙状态
    func sendBluetoothstate()
    
    //断开设备
    func sendDisconnect()
}
