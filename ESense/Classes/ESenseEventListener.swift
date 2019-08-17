//
//  ESenseEventListener.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit


public protocol ESenseEventListener {
    /**
     * Called when the information on battery voltage has been received
     * @param voltage battery voltage in Volts
     */
    func onBatteryRead(_ voltage:Double);
    
    /**
     * Called when the button event has changed
     * @param pressed true if the button is pressed, false if it is released
     */
    func onButtonEventChanged(_ pressed:Bool);
    
    /**
     * Called when the information on advertisement and connection interval has been received
     * @param minAdvertisementInterval minimum advertisement interval (unit: milliseconds)
     * @param maxAdvertisementInterval maximum advertisement interval (unit: milliseconds)
     * @param minConnectionInterval minimum connection interval (unit: milliseconds)
     * @param maxConnectionInterval maximum connection interval (unit: milliseconds)
     */
    func onAdvertisementAndConnectionIntervalRead(_ minAdvertisementInterval:Int, _ maxAdvertisementInterval:Int,  _ minConnectionInterval:Int, _ maxConnectionInterval:Int);
    
    /**
     * Called when the information on the device name has been received
     * @param deviceName name of the device
     */
    func onDeviceNameRead(_ deviceName:String);
    
    /**
     * Called when the information on sensor configuration has been received
     * @param config current sensor configuration
     */
    func onSensorConfigRead(_ config:ESenseConfig);
    
    /**
     * Called when the information on accelerometer offset has been received
     * @param offsetX x-axis factory offset
     * @param offsetY y-axis factory offset
     * @param offsetZ z-axis factory offset
     */
    func onAccelerometerOffsetRead(_ offsetX:Int, _ offsetY:Int, _ offsetZ:Int);
}
