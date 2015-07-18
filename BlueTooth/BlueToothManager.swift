
//
//  BlueToothManager.swift
//
//  Created by Karsa wang on 7/9/15.
//  Copyright (c) 2015 Karsa wang. All rights reserved.
//

import CoreBluetooth
import CoreFoundation

let Notify_BlueTooth_update = "Notify_BlueTooth_update"
let Notify_BlueTooth_descriptor_update = "Notify_BlueTooth_descriptor_update"
let print_characteristic_uuid = "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"
let print_service_uuid = "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"

class BlueToothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var myCentralManager:CBCentralManager?
    var peripheralList = [CBPeripheral]()
    var currentConnect: CBPeripheral?
    static let instance = BlueToothManager()
    
    static func shareInstance() -> BlueToothManager {
        return instance
    }
    
    func startScan() {
        self.myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    func stopScan() {
        self.myCentralManager?.stopScan()
    }
    
    
    func conectPeripheral(peripheral: CBPeripheral) {
        self.myCentralManager?.stopScan()
        print("peripheral \(peripheral.name) connecting...")
        self.myCentralManager?.connectPeripheral(peripheral, options: nil)
    }
    func disConnectPeripheral(peripheral: CBPeripheral) {
        print("peripheral \(peripheral.name) disconnecting...")
        self.myCentralManager?.stopScan()
        self.myCentralManager?.cancelPeripheralConnection(peripheral)
    }
    
    func addPeripheral(peripheral: CBPeripheral?) {
        if  peripheral?.name == nil || peripheral?.name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            return
        }
        var shouldAdd = true
        for p in self.peripheralList {
            if p.identifier == peripheral!.identifier {
                shouldAdd = false
                break;
            }
        }
        if shouldAdd {
            peripheralList.insert(peripheral!, atIndex: 0)
            println(peripheral!.name)
            NSNotificationCenter.defaultCenter().postNotificationName(Notify_BlueTooth_update, object: nil)
        }
    }
    
    /*
        CBPeripheralDelegate
    */
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!){
        for s in peripheral.services {
            if let service = s as? CBService {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for  cha in service.characteristics {
            if let char = cha as? CBCharacteristic {
                peripheral.readValueForCharacteristic(char)
                peripheral.discoverDescriptorsForCharacteristic(char)
            }
        }
    }
    func peripheral(peripheral: CBPeripheral!, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
    }
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
    }
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
    }
    
    /*
        CBCentralManagerDelegate
    */
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("CentralManager is initialized")
         switch central.state {
         case CBCentralManagerState.Unauthorized:
             println("The app is not authorized to use Bluetooth low energy.")
         case CBCentralManagerState.PoweredOff:
             println("Bluetooth is currently powered off.")
         case CBCentralManagerState.PoweredOn:
            println("Bluetooth is currently powered on and available to use.")
            self.myCentralManager?.scanForPeripheralsWithServices(nil, options: nil)
         default:break
        }
    }
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        self.addPeripheral(peripheral)
        NSNotificationCenter.defaultCenter().postNotificationName(Notify_BlueTooth_update, object: nil)
    }
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("peripheral \(peripheral.name) connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.currentConnect = peripheral
        NSNotificationCenter.defaultCenter().postNotificationName(Notify_BlueTooth_update, object: nil)
    }
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("peripheral \(peripheral.name) fail connected")
        NSNotificationCenter.defaultCenter().postNotificationName(Notify_BlueTooth_update, object: nil)
    }
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("peripheral \(peripheral.name)  disconnected")
        self.currentConnect = nil
        NSNotificationCenter.defaultCenter().postNotificationName(Notify_BlueTooth_update, object: nil)
    }
}