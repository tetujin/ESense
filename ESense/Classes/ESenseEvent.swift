//
//  ESenseEvent.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit

public class ESenseEvent:NSObject{
    private var timestamp:Int64 = 0;  //phone's timestamp
    private var packetIndex:Int = 0;
    private var accel:[Int16]   = [0,0,0];   // 3-elements array with X, Y and Z axis for accelerometer
    private var gyro:[Int16]    = [0,0,0];   // 3-elements array with X, Y and Z axis for gyroscope
    
    /**
     * Constructs an empty event
     */
    override init(){

    }
    
    /**
     * Constructs an event with values received from the device
     * @param accel ADC values for the accelerometer
     * @param gyro ADC values for the gyroscope
     */
    convenience init(accel:[Int16], gyro:[Int16]){
        self.init()
        self.accel = accel;
        self.gyro = gyro;
    }
    
    public func getTimestamp() -> Int64{
        return timestamp;
    }
    
    public func setTimestamp(_ timestamp:Int64 ) {
        self.timestamp = timestamp;
    }
    
    public func getPacketIndex() -> Int {
        return packetIndex;
    }
    
    public func setPacketIndex(_ packetIndex:Int ) {
        self.packetIndex = packetIndex;
    }
    
    public func getAccel() -> [Int16] {
        return accel;
    }
    
    public func setAccel(_ accel:[Int16]) {
        self.accel = accel;
    }
    
    public func getGyro() -> [Int16] {
        return gyro;
    }
    
    public func setGyro(_ gyro:[Int16]) {
        self.gyro = gyro;
    }
    
    /**
     * Converts current ADC accelerometer values to acceleration in g
     * @param config device configuration
     * @return acceleration in g on X, Y and Z axis
     */
    public func convertAccToG(config:ESenseConfig) -> [Double]{
        var data:[Double] = [0,0,0];
        for (i, v) in accel.enumerated() {
            data[i] = (Double(v) / config.getAccSensitivityFactor());
        }
        return(data);
    }
    
    /**
     * Converts current ADC gyroscope values to rotational speed in degrees/second
     * @param config device configuration
     * @return rotational speed in deg/s on X, Y and Z axis
     */
    public func convertGyroToDegPerSecond(config:ESenseConfig) -> [Double]{
        var data:[Double] = [0,0,0];
        for (i,v) in gyro.enumerated() {
            data[i] = (Double(v) / config.getGyroSensitivityFactor());
        }
        return(data);
    }
}
