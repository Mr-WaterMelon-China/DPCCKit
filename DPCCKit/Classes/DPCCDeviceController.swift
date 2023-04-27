//
//  DPCCDeviceController.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/29.
//

import UIKit
import CoreBluetooth
import SinoDetection

final class DPCCDeviceController: DPCCBaseController {
    
    var centralManager: CBCentralManager?
    
    var isBluetoothOpen = true
    
    var bluetoothParams: [String: String]?
    
    var bluetoothCallBack: String?
    
    var bluetoothDeviceArr = [BluetoothDeviceInfoModel]()
    
    var deviceModel: DPCCTOSDKModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDeviceUI()
    }
    
    fileprivate func initDeviceUI() {
        view.backgroundColor = .white
        messageHandler.scanDelegate = self
        print(DPCCApiConfig.h5DeviceApi)
        if let url = URL.init(string: DPCCApiConfig.h5DeviceApi) {
            
            webView.load(URLRequest.init(url: url))
        }
    }
    
    fileprivate func addData(_ model: BluetoothDeviceInfoModel) {
        var isExist = false
        for temp in bluetoothDeviceArr {
            if temp.uuidString == model.uuidString {
                isExist = true
                break
            }
        }
        if !isExist {
            bluetoothDeviceArr.append(model)
        }
        sendDeviceToJS()
    }
    
    fileprivate func sendDeviceToJS() {
        guard bluetoothDeviceArr.count > 0 else {
            return
        }
        guard let dict = bluetoothParams else {
            return
        }
        var arr = [[String: String]]()
        for device in bluetoothDeviceArr {
            var param = [String: String]()
            if let temp = dict["productName"] {
                param["productName"] = temp
            }
            if let temp = dict["parentType"] {
                param["parentType"] = temp
            }
            param["bluetoothName"] = device.blueName
            param["uuidString"] = device.uuidString
            param["macAddress"] = device.macAddress
            
            if let temp = deviceModel {
                param["deviceType"] = "\(temp.deviceType)"
                param["productCode"] = temp.productCode
                param["dataProtocolCode"] = temp.dataProtocolCode
                param["machineCode"] = temp.machineCode
            }

            arr.append(param)
        }
        guard let callBack = bluetoothCallBack else {
            return
        }
        let arrStr = convertJsonFrom(array: arr)
        print("112233:",arrStr)
        let jsStr = callBack + "(" + arrStr + ")"
        webView.evaluateJavaScript(jsStr)
    }
    
    fileprivate func dealDeviceType() {
        guard let temp = bluetoothParams else {
            return
        }
        if let type = temp["iosType"] {
            switch type {
            case "888":
                //腰围尺，新的sdk暂未加
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_TYPE_UNKNOWN.rawValue, pCode: "", dCode: "", mCode: "")
            case "999":
                //云康宝
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_RUNCOBO_HEIGHT_WEIGHT_BLE.rawValue, pCode: "100228", dCode: "runcobo_height_weight_ble", mCode: "")
            case "60":
                //上禾，新的sdk暂未加
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_TYPE_UNKNOWN.rawValue, pCode: "", dCode: "", mCode: "")
            case "6":
                //脉搏波血压计9805
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_MAIBOBO_BPG_BLE.rawValue, pCode: "100215", dCode: "maibobo_BPG_ble", mCode: "")
            case "7":
                //脉搏波7000B
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_MAIBOBO_BPG_BLE.rawValue, pCode: "100216", dCode: "maibobo_BPG_ble", mCode: "")
            case "8":
                //诺凡803
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_ONE_TEST_BPG_BLE.rawValue, pCode: "100019", dCode: "one_test_BPG_ble", mCode: "")
            case "158":
                //金准+air,sdk未对接
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_TYPE_UNKNOWN.rawValue, pCode: "100012", dCode: "jin_wen_air_ble", mCode: "")
            case "52":
                //臻准2000
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_SINO_STANDARD_BLE_01.rawValue, pCode: "100082", dCode: "sino_standard_ble_01", mCode: "2000")
                
            case "109":
                //KA-11
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_EAKA_BLE.rawValue, pCode: "100055", dCode: "ea_ka_ble", mCode: "")
                
            case "110":
                //UG-11 Code
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_UG_11_BLE.rawValue, pCode: "100008", dCode: "ug_11_ble", mCode: "")
                
            case "49":
                //UG-11 Air
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_UG_11_BLE.rawValue, pCode: "100006", dCode: "ug_11_ble", mCode: "")
                
            case "41":
                //WL-1
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_WL_1_BLE.rawValue, pCode: "100082", dCode: "wl_1_ble", mCode: "")
                
            case "34":
                //安稳+Air
                deviceModel = DPCCTOSDKModel(SDCDeviceType.DEVICE_AQ_AIR_BLE.rawValue, pCode: "100004", dCode: "safe_aq_air_ble", mCode: "0012")
                
            default:
                break
            }
        }
    }
}

extension DPCCDeviceController: DPCCScanDelegate {
    
    func sendClearData() {
        print("H5调用清除数据啦")
        centralManager?.stopScan()
        bluetoothDeviceArr.removeAll()
    }
    
    
    func sendScanDevice(_ callBack: String?, params: [String : String]?) {
        bluetoothCallBack = callBack
        bluetoothParams = params
        dealDeviceType()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func sendBindDevice(_ params: [String : String]?) {
        guard let temp = params else {
            return
        }
        guard let parentType = temp["parentType"] else {
            return
        }
       
        bluetoothDeviceArr.removeAll()
        switch parentType {
        case "100","101","103":
            //血糖仪
            DPCCUserDefaultsManager.set(temp, forKey: DPCCUserDefaultsKey.sugarDevice)
        case "102":
            //血压计
            DPCCUserDefaultsManager.set(temp, forKey: DPCCUserDefaultsKey.pressureDevice)
        case "999":
            //身高体重仪
            DPCCUserDefaultsManager.set(temp, forKey: DPCCUserDefaultsKey.heightDevice)
        case "104":
            //腰围尺
            DPCCUserDefaultsManager.set(temp, forKey: DPCCUserDefaultsKey.waistDevice)
        default:
            break
        }
    }
    
    fileprivate func dealBluetoothState() {
        var dict = [String: String]()
        if isBluetoothOpen {
            dict["status"] = "1"
        } else {
            dict["status"] = "0"
        }
        let str = convertJsonFrom(dict: dict as NSDictionary)
        let jsStr = H5BluetoothStatus + "(" + str + ")"
        self.webView.evaluateJavaScript(jsStr)
    }
}

extension DPCCDeviceController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothOpen = true
            centralManager?.stopScan()
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        case .unknown:
            isBluetoothOpen = false
        case .resetting:
            isBluetoothOpen = false
        case .unsupported:
            isBluetoothOpen = false
        case .unauthorized:
            isBluetoothOpen = false
        case .poweredOff:
            isBluetoothOpen = false
        @unknown default: break
        }
        dealBluetoothState()
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let temp = bluetoothParams else {
            return
        }
        guard let device = deviceModel else {
            return
        }
        var blueNameArr = [String]()
        if let blueName = temp["bluetoothNames"] {
            blueNameArr = blueName.components(separatedBy: ",")
        }
        if let name = peripheral.name {
            if blueNameArr.count > 0 {
                for temp in blueNameArr {
                    if name.contains(temp) {
                        let model = BluetoothDeviceInfoModel(peripheral, name: name, uuid: peripheral.identifier.uuidString)
                        if let data = advertisementData["kCBAdvDataManufacturerData"] as? NSData {
                            if let type = SDCDeviceType(rawValue: device.deviceType) {
                                let mac = data.getMacAddress(with: type)
                                model.macAddress = mac
                            }
                        }
                        addData(model)
                    }
                }
            }
        }
    }
    
}

