//
//  ESenseConfig.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit

public class ESenseConfig: NSObject {
    
    /**
     * Gyroscope full scale range in +-degrees/second
     */
    public enum GyroRange {
        case DEG_250
        case DEG_500
        case DEG_1000
        case DEG_2000
        
        static let values = [DEG_250, DEG_500, DEG_1000, DEG_2000]
    
        func ordinal() -> Int{
            return ordinal(self)
        }
        
        func ordinal(_ gyroRange:GyroRange) -> Int {
            for (i, value) in ESenseConfig.GyroRange.values.enumerated() {
                if value == gyroRange {
                    return i
                }
            }
            return 0
        }
    }
    
    /**
     * Accelerometer full scale range in +-g
     */
    public enum AccRange {
        case G_2
        case G_4
        case G_8
        case G_16
        
        static let values = [G_2, G_4, G_8, G_16]
        
        func ordinal() -> Int{
            return ordinal(self)
        }
        
        func ordinal(_ accRange:AccRange) -> Int {
            for (i, value) in ESenseConfig.AccRange.values.enumerated() {
                if value == accRange {
                    return i
                }
            }
            return 0
        }
    }
    
    /**
     * Gyroscope low pass filter configuration. Each value except DISABLED represents the bandwidth of the filter in Hz.
     */
    public enum GyroLPF {
        case BW_250
        case BW_184
        case BW_92
        case BW_41
        case BW_20
        case BW_10
        case BW_5
        case BW_3600
        case DISABLED
        
        static let values = [BW_250, BW_184, BW_92, BW_41, BW_20, BW_10, BW_5, BW_3600, DISABLED]
        
        func ordinal() -> Int{
            return ordinal(self)
        }
        
        func ordinal(_ gyroLPF:GyroLPF) -> Int {
            for (i, value) in ESenseConfig.GyroLPF.values.enumerated() {
                if value == gyroLPF {
                    return i
                }
            }
            return 0
        }
    }
    
    /**
     * Accelerometer low pass filter configuration. Each value except DISABLED represents the bandwidth of the filter in Hz.
     */
    public enum AccLPF {
        case BW_460
        case BW_184
        case BW_92
        case BW_41
        case BW_20
        case BW_10
        case BW_5
        case DISABLED
        
        static let values = [BW_460, BW_184, BW_92, BW_41, BW_20, BW_10, BW_5, DISABLED]
        
        func ordinal() -> Int{
            return ordinal(self)
        }
        
        func ordinal(_ accLPF:AccLPF) -> Int {
            for (i, value) in ESenseConfig.AccLPF.values.enumerated() {
                if value == accLPF {
                    return i
                }
            }
            return 0
        }
    }
    
    private var gyroRange:GyroRange
    private var accRange:AccRange
    private var gyroLPF:GyroLPF
    private var accLPF:AccLPF
    
    /**
     * Constructs a configuration object with the specified ranges and low pass filter values
     * @param accRange accelerometer range
     * @param gyroRange gyroscope range
     * @param accLPF accelerometer low pass filter configuration
     * @param gyroLPF gyroscope low pass filter configuration
     */
    public init(accRange:AccRange, gyroRange:GyroRange, accLPF:AccLPF, gyroLPF:GyroLPF) {
        self.accRange = accRange;
        self.gyroRange = gyroRange;
        self.accLPF = accLPF;
        self.gyroLPF = gyroLPF;
    }
    
    /**
     * Constructs a configuration object from the bytes read from the device
     * @param charaterictic_data bytes read from the device
     */
    public init(charaterictic_data:[UInt8]){
        gyroLPF   = ESenseConfig.parseGyroLPF(charaterictic_data);
        accLPF    = ESenseConfig.parseAccLPF(charaterictic_data);
        gyroRange = ESenseConfig.parseGyroRange(charaterictic_data);
        accRange  = ESenseConfig.parseAccRange(charaterictic_data);
    }
    
    /**
     * Constructs a default configuration object
     * Acc range = +-4g
     * Gyro range = +-1000deg/s
     * Acc LPF = bandwith 5Hz
     * Gyro LPf = bandwith 5Hz
     */
    public convenience override init(){
        self.init(accRange: AccRange.G_4, gyroRange: GyroRange.DEG_1000, accLPF: AccLPF.BW_5, gyroLPF: GyroLPF.BW_5);
    }
    
    /**
     * Extracts gyroscope low pass filter configuration from bytes read from the device
     * @param data bytes read from the device
     * @return Gyro LPF configuration
     */
    public static func parseGyroLPF(_ data:[UInt8] ) -> GyroLPF {
        let lpf_enabled = data[4] & 0x3;
        if(lpf_enabled == 1 || lpf_enabled == 2){
            return(GyroLPF.DISABLED);
        } else {
            let lpf:GyroLPF = GyroLPF.values[(Int)(data[3] & 0x7)]; //TODO
            return(lpf);
        }
    }
    
    /**
     * Extracts accelerometer low pass filter configuration from bytes read from the device
     * @param data bytes read from the device
     * @return accelerometer LPF configuration
     */
    public static func parseAccLPF(_ data:[UInt8] ) -> AccLPF{
        let lpf_enabled = (data[6] & 0x8) >> 3;
        if(lpf_enabled == 1){
            return(AccLPF.DISABLED);
        } else {
            let lpf:AccLPF = AccLPF.values[(Int)(data[6] & 0x7)]; //TODO
            return(lpf);
        }
    }
    
    /**
     * Extracts gyroscope full scale range configuration from bytes read from the device
     * @param data bytes read from the device
     * @return Gyro range configuration
     */
    public static func parseGyroRange(_ data:[UInt8]) -> GyroRange{
        return(ESenseConfig.GyroRange.values[(Int)((data[4] & 0x18) >> 3)]); // TODO
        // return(GyroRange.DEG_1000)
    }
    
    /**
     * Extracts accelerometer full scale range configuration from bytes read from the device
     * @param data bytes read from the device
     * @return accelerometer range configuration
     */
    public static func parseAccRange(_ data:[UInt8]) -> AccRange {
        return(ESenseConfig.AccRange.values[(Int)((data[5] & 0x18) >> 3)]); // TODO
        // return(AccRange.G_4)
    }
    
    /**
     * Convert current configuration objects in bytes to write on the configuration characteristic of the device
     * @return bytes to write on the characteristic
     */
    public func prepareCharacteristicData() -> [UInt8] {
        var data:[UInt8] = [0x59, 0x00, 0x04, 0x06, 0x08, 0x08, 0x06];
        data = setGyroLPFInBytes(data);
        data = setAccLPFInBytes(data);
        data = setAccRangeInBytes(data);
        data = setGyroRangeInBytes(data);
        return(data);
    }
    
    private func setGyroLPFInBytes( _ data:[UInt8]) -> [UInt8]{
        var data = data
        if(self.gyroLPF == GyroLPF.DISABLED){
            data[4] = ((data[4] & 0xfc) | 0x1);
        } else {
            data[4] = ((data[4] & 0xfc));
            data[3] = ((data[3] & 0xf8) | UInt8(self.gyroLPF.ordinal())); // TODO : Need Check
        }
        
        return(data);
    }
    
    private func setAccLPFInBytes( _ data:[UInt8]) -> [UInt8]{
        var data = data
        if(self.accLPF == AccLPF.DISABLED){
            data[6] = ((data[6] & 0xf7) | (0x1 << 3));
        } else {
            data[6] = ((data[6] & 0xf7));
            data[6] = ((data[6] & 0xf8) | UInt8(self.accLPF.ordinal()));
        }
        
        return(data);
    }
    
    private func setGyroRangeInBytes(_ data:[UInt8]) -> [UInt8]{
        var data = data
        data[4] = ((data[4] & 0xe7) | UInt8(self.gyroRange.ordinal() << 3));
        return(data);
    }
    
    private func setAccRangeInBytes(_ data:[UInt8]) -> [UInt8] {
        var data = data
        data[5] = ((data[5] & 0xe7) | UInt8(self.accRange.ordinal() << 3));
        return(data);
    }
    
    /**
     * Get accelerometer sensitivity factor for the current configuration
     * @return accelerometer sensitivity factor
     */
    public func getAccSensitivityFactor() -> Double{
        switch accRange {
        case AccRange.G_2:
            return 16384;
        case AccRange.G_4:
            return 8192;
        case AccRange.G_8:
            return 4096;
        case AccRange.G_16:
            return 2048;
        }
    }
    
    /**
     * Get gyroscope sensitivity factor for the current configuration
     * @return gyroscope sensitivity factor
     */
    public func getGyroSensitivityFactor() -> Double{
        switch gyroRange {
        case GyroRange.DEG_250:
            return 131;
        case GyroRange.DEG_500:
            return 65.5;
        case GyroRange.DEG_1000:
            return 32.8;
        case GyroRange.DEG_2000:
            return 16.4;
        }
    }
    
    public func getGyroRange() -> GyroRange {
        return gyroRange;
    }
    
    public func setGyroRange(_ gyroRange:GyroRange ) {
        self.gyroRange = gyroRange;
    }
    
    public func getAccRange() -> AccRange {
        return accRange;
    }
    
    public func setAccRange(_ accRange:AccRange) {
        self.accRange = accRange;
    }
    
    public func getGyroLPF() -> GyroLPF{
        return gyroLPF;
    }
    
    public func setGyroLPF(_ gyroLPF:GyroLPF) {
        self.gyroLPF = gyroLPF;
    }
    
    public func getAccLPF() -> AccLPF {
        return accLPF;
    }
    
    public func setAccLPF(_ accLPF:AccLPF) {
        self.accLPF = accLPF;
    }
}
