//
//  ESenseScanner.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit
import CoreBluetooth

public class ESenseScanner: NSObject, CBCentralManagerDelegate{

    private let TAG = "ESenseScanner";
    
    private var mDevice:CBPeripheral?
    private var mScanning:Bool = false;
    private var mDeviceName:String;
    public var mBluetoothLeScanner:CBCentralManager?
    public var scanResultHandler:((CBPeripheral?) -> Void)?
    public var connectHandler:((CBPeripheral?) -> Void)?
    public var disconnectHandler:((CBPeripheral?) -> Void)?
    
    public init(name:String){
        mDeviceName = name;
    }
    
    public func scan(_ scanResultHandler:((CBPeripheral?) -> Void)? ){
        if self.mBluetoothLeScanner == nil {
            self.scanResultHandler = scanResultHandler
            self.mBluetoothLeScanner = CBCentralManager(delegate: self, queue: nil)

        }
    }
    
    /**
     * Stops eSense scanning
     */
    public func stopScan() {
        if let scanner = mBluetoothLeScanner {
            scanner.stopScan()
            mScanning = false
            print(TAG,"Stop scan");
        }
    }
    /**
     * Checks if scanning is being performed.
     * @return <code>true</code> if scanning is being performed
     *         <code>false</code> otherwise
     */
    public func isScanning() -> Bool{
        return mScanning;
    }
    
    /**
     * Gets the BluetoothDevice object.
     */
    public func getDevice() -> CBPeripheral?{
        return self.mDevice
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .poweredOff:
            break
        case .poweredOn:
            if let scanner = mBluetoothLeScanner {
                let services: [CBUUID] = [ESenseManager.ESENSE_DEVICE_NAME_SERVICE, ESenseManager.ESENSE_SENSOR_SERVICE]
                scanner.scanForPeripherals(withServices: services, options: nil)
                mScanning = true
                print(TAG,"Start scan");
            }
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        default:
            break
        }
        
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // print(peripheral)
        if let name = peripheral.name {
            if name == self.mDeviceName {
                self.mDevice = peripheral
                print(TAG,"mac address : " + peripheral.identifier.uuidString + ", name : " + name);
                
                self.stopScan()
                
                if let handler = scanResultHandler {
                    handler(self.mDevice)
                }
                
                if let manager = self.mBluetoothLeScanner {
                    manager.connect(peripheral, options: nil)
                }
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let handler = self.connectHandler {
            handler(self.mDevice)
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let handler = self.disconnectHandler {
            handler(self.mDevice)
        }
    }
    
    // public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {}
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {}
    
}
