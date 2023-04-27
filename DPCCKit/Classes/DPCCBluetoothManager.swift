//
//  DPCCBluetoothManager.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/29.
//

import Foundation
import CoreBluetooth
import SinoDetection

class BluetoothDeviceInfoModel: NSObject {
    
    var bluePeripheral: CBPeripheral?
    var blueName = ""
    var uuidString = ""
    var macAddress = ""
    
    required init(_ peripheral: CBPeripheral?,name: String,uuid: String) {
        bluePeripheral = peripheral
        blueName = name
        uuidString = uuid
    }
}

class DPCCBluetoothManager: NSObject {
    
    private static var privateShared: DPCCBluetoothManager?
    
    fileprivate var centralManager: CBCentralManager?
    
    var isBluetoothOpen = true
    
    fileprivate var deviceArr = [SDDeviceModel]() //传给SDK
    
    fileprivate var tempDeviceArr = [DPCCDeviceModel]() //用于测量结果判断
    
    class func shared() -> DPCCBluetoothManager {
        guard let unwrapShared = privateShared else {
            privateShared = DPCCBluetoothManager()
            return privateShared!
        }
        return unwrapShared
    }
    
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    class func destroy() {
        privateShared = nil
    }
    
    fileprivate func getDeviceFromUserDefaults() {
        deviceArr.removeAll()
        tempDeviceArr.removeAll()
        if let dict = UserCookies.shared.sugarDevice {
            let model = DPCCDeviceModel.init(withDict: dict)
            tempDeviceArr.append(model)
        }
        if let dict = UserCookies.shared.pressureDevice {
            let model = DPCCDeviceModel.init(withDict: dict)
            tempDeviceArr.append(model)
        }
        if let dict = UserCookies.shared.heightDevice {
            let model = DPCCDeviceModel.init(withDict: dict)
            tempDeviceArr.append(model)
        }
        if let dict = UserCookies.shared.waistDevice {
            let model = DPCCDeviceModel.init(withDict: dict)
            tempDeviceArr.append(model)
        }
        if tempDeviceArr.count > 0 {
            for temp in tempDeviceArr {
                let model = SDDeviceManager.shared().createDeviceModel(withProductCode: temp.productCode, deviceName: temp.productName, bluetoothPrefixName: temp.bluetoothName, machineCode: temp.machineCode, mac: temp.macAddress, sn: "", dataProtocolCode: temp.dataProtocolCode, image: "", uuid: temp.uuidString)
                deviceArr.append(model)
            }
        }
    }
    
    func removeBindDevice() {
        deviceArr.removeAll()
        tempDeviceArr.removeAll()
        SDBluetoothManager.shared().boundDevices.removeAll()
    }
    
    func bindAllDevice() {
        getDeviceFromUserDefaults()
        SDBluetoothManager.shared().boundDevices = deviceArr
    }
    
    func connectDevice() {
        if isBluetoothOpen  {
            self.didUpdateDevices()
        }
    }
    
    func disConnectDevices() {
        SDBluetoothManager.shared().disconnectDevices()
    }
    
    fileprivate func didUpdateDevices() {
        guard tempDeviceArr.count > 0 else {
            return
        }
        SDBluetoothManager.shared().connectDevices()
        SDBluetoothManager.shared().didReceiveData = { dic,state,model in
            if let status = state {
                if status.state == .connected {
                    print("我连上了")
                    for temp in self.tempDeviceArr {
                        if temp.uuidString == model.uuid {
                            NotificationCenter.default.post(name: NSNotification.Name.DPCCDeviceStatus, object: nil, userInfo: ["parentType": temp.parentType,"status": "1"])
                            break
                        }
                    }
                } else if status.state == .unconnect {
                    print("我断开了")
                    for temp in self.tempDeviceArr {
                        if temp.uuidString == model.uuid {
                            NotificationCenter.default.post(name: NSNotification.Name.DPCCDeviceStatus, object: nil, userInfo: ["parentType": temp.parentType,"status": "0"])
                            break
                        }
                    }
                }
            }
            if let temp = dic {
                if let data = temp["data"] as? [String: AnyObject] {
                    if let type = data["type"] as? String,
                       let result = data["result"] as? [String: AnyObject] {
                        for temp in self.tempDeviceArr {
                            if temp.uuidString == model.uuid {
                                self.dealResult(type, result: result, device: temp)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func dealResult(_ type: String,
                                result: [String: AnyObject],
                                device: DPCCDeviceModel) {
        switch type {
        case DPCCValueType.pressure.rawValue:
            let model = DPCCPressureModel(withDict: result)
            if let sysPressure = model.BloodMeasureHigh?.value,
               let diaPressure = model.BloodMeasureLow?.value {
                NotificationCenter.default.post(name: NSNotification.Name.DPCCDeviceResult, object: nil, userInfo: ["parentType": device.parentType,"sysPressure": sysPressure,"diaPressure": diaPressure])
            }
        case DPCCValueType.height.rawValue:
            let model = DPCCHeightModel(withDict: result)
            if let height = model.height?.value,let weight = model.weight?.value {
                NotificationCenter.default.post(name: NSNotification.Name.DPCCDeviceResult, object: nil, userInfo: ["parentType": device.parentType,"height": height,"weight": weight])
            }
        case DPCCValueType.sugar.rawValue:
            let model = DPCCSugarModel(withDict: result)
            if let value = model.glu?.value {
                NotificationCenter.default.post(name: NSNotification.Name.DPCCDeviceResult, object: nil, userInfo: ["parentType": device.parentType,"value": value])
            }
        default: break
        }
    }
}

extension DPCCBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothOpen = true
            connectDevice()
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
        var dict = [String : String]()
        if isBluetoothOpen {
            dict["status"] = "1"
        } else {
            dict["status"] = "0"
        }
        NotificationCenter.default.post(name: NSNotification.Name.DPCCBluetoothStatus, object: nil,userInfo: dict)
    }
    
}

extension String {
    
    var DPCCUIntValue: UInt {
        if let integer = UInt(self) {
            return integer
        }
        return 0
    }
}
