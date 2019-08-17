//
//  ViewController.swift
//  ESense
//
//  Created by tetujin on 08/15/2019.
//  Copyright (c) 2019 tetujin. All rights reserved.
//

import UIKit
import ESense
import CoreBluetooth

class ViewController: UIViewController{

    var manager:ESenseManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager = ESenseManager(deviceName: "eSense-0063", listener: self)
        if let m = manager {
            print(m.connect(timeout: 10))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
    }
    
}

extension ViewController:ESenseConnectionListener{
    func onDeviceFound(_ manager: ESenseManager) {
        print(#function)
    }
    
    func onDeviceNotFound(_ manager: ESenseManager) {
        print(#function)
    }
    
    func onConnected(_ manager: ESenseManager) {
        print(#function)
        manager.setDeviceReadyHandler { peripheral in
            manager.removeDeviceReadyHandler()
            print(manager.registerEventListener(self))
            print(manager.getBatteryVoltage())
            print(manager.registerSensorListener(self, hz: 1))
            print(manager.getAdvertisementAndConnectionInterval())
            print(manager.getAccelerometerOffset())
            print(manager.getSensorConfig())
            print(manager.setSensorConfig(ESenseConfig()))
            print(manager.setDeviceName("eSense-0063"))
        }
    }
    
    func onDisconnected(_ manager: ESenseManager) {
        print(#function)
    }
}

extension ViewController:ESenseEventListener{
    func onBatteryRead(_ voltage: Double) {
        print(#function, voltage)
    }
    
    func onButtonEventChanged(_ pressed: Bool) {
        print(#function, pressed)
    }
    
    func onAdvertisementAndConnectionIntervalRead(_ minAdvertisementInterval: Int, _ maxAdvertisementInterval: Int, _ minConnectionInterval: Int, _ maxConnectionInterval: Int) {
        print(#function, minAdvertisementInterval, maxAdvertisementInterval, minConnectionInterval, maxConnectionInterval)
    }
    
    func onDeviceNameRead(_ deviceName: String) {
        print(#function, deviceName)
    }
    
    func onSensorConfigRead(_ config: ESenseConfig) {
        print(#function, config)
    }
    
    func onAccelerometerOffsetRead(_ offsetX: Int, _ offsetY: Int, _ offsetZ: Int) {
        print(#function, offsetX, offsetY, offsetZ)
    }
}

extension ViewController:ESenseSensorListener{
    func onSensorChanged(_ evt: ESenseEvent) {
        print(evt.getTimestamp(), evt.convertAccToG(config: ESenseConfig()))
    }
}

