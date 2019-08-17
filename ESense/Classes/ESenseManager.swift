//
//  ESenseManager.swift
//  ESense
//
//  Created by Yuuki Nishiyama on 2019/08/15.
//

import UIKit
import CoreBluetooth

public class ESenseManager: NSObject{

    
    private let TAG:String = "ESenseManager";
    
    private var mDeviceName:String?
    private var mConnectionListener:ESenseConnectionListener?
    private var mEventListener:ESenseEventListener?
    private var mSensorListener:ESenseSensorListener?
    private var mDevice:CBPeripheral?
    private var mBluetoothManager:CBCentralManager?
    private var mGattCallback:ESenseBGattCallback?
    private var mCharacteristicMap = Dictionary<CBUUID,CBCharacteristic>();
    private var scanner:ESenseScanner?
    private var timeoutTimer:Timer?
    
    public static let ESENSE_SENSOR_SERVICE = CBUUID(string:"0xFF06")
    public static let ESENSE_DEVICE_NAME_SERVICE = CBUUID(string: "0x1800")
    
    private let CONFIG_CHARACTERISTIC   = CBUUID(string:"0000ff07-0000-1000-8000-00805f9b34fb");
    private let SENSOR_CHARACTERISTIC   = CBUUID(string:"0000ff08-0000-1000-8000-00805f9b34fb");
    private let BUTTON_CHARACTERISTIC   = CBUUID(string:"0000ff09-0000-1000-8000-00805f9b34fb");
    private let BATTERY_CHARACTERISTIC  = CBUUID(string:"0000ff0a-0000-1000-8000-00805f9b34fb");
    private let ADV_CONN_CHARACTERISTIC = CBUUID(string:"0000ff0b-0000-1000-8000-00805f9b34fb");
    private let NAME_WRITE_CHARACTERISTIC   = CBUUID(string:"0000ff0c-0000-1000-8000-00805f9b34fb");
    private let DEVICE_NAME_CHARACTERISTIC  = CBUUID(string:"00002a00-0000-1000-8000-00805f9b34fb");
    private let SENSOR_CONFIG_CHARACTERISTIC    = CBUUID(string:"0000ff0e-0000-1000-8000-00805f9b34fb");
    private let ACCELEROMETER_OFFSET_CHARACTERISTIC = CBUUID(string:"0000ff0d-0000-1000-8000-00805f9b34fb");
    private let NOTIFICATION_DESCRIPTOR = UUID.init(uuidString: "00002902-0000-1000-8000-00805f9b34fb")

    public var mDeviceReadyHandler:((CBPeripheral?)->Void)? = nil
    
    /**
     * Constructs an eSense manager for a given device
     * @param deviceName name of the eSense device to look for during a scan
     */
    public init(deviceName:String) {
        mDeviceName = deviceName;
        mGattCallback = ESenseBGattCallback();
    }
    
    /**
     * Constructs an eSense manager for a given device with the connection listener
     * @param deviceName name of the eSense device to look for during a scan
     * @param listener connection listener
     */
    public convenience init(deviceName:String, listener:ESenseConnectionListener?){
        self.init(deviceName:deviceName);
        mConnectionListener = listener;
    }
    
    public func setDeviceReadyHandler(_ handler:((CBPeripheral?)->Void)?){
        self.mDeviceReadyHandler = handler
    }
    
    public func removeDeviceReadyHandler(){
        self.mDeviceReadyHandler = nil
    }
    
    /**
     * Calculates the checksum of the bytes from position (checkSumIndex + 1) until the end of the array
     * @param bytes array of bytes
     * @param checkSumIndex index where checksum will be placed. Checksum computation starts from next byte
     * @return value of checksum
     */
    private func getCheckSum(_ bytes:[UInt8], _ checkSumIndex:Int) -> UInt8{
        let length = bytes.count;
        var sum:Int = 0;
        for i in (checkSumIndex+1) ..< length {
            sum += Int(bytes[i] & 0xff);
        }
        let chekcsum = sum % 256
        return UInt8(chekcsum);
    }
    
    /**
     * Checks the checksum at the given index from position (checkSumIndex + 1) until the end of the array
     * @param bytes array of bytes
     * @param checkSumIndex index of checksum
     * @return <code>true</code> if the value of checksum is correct,
     *         <code>false</code> otherwise
     */
    private func checkCheckSum(_ bytes:[UInt8], _ checkSumIndex:Int) -> Bool{
        return getCheckSum(bytes, checkSumIndex) == bytes[checkSumIndex] ? true : false
    }
    
    
    /**
     * Initiates a characteristic read on the connected device
     * @param charName name of the characteristic to read
     * @return <code>true</code> if the read operation has been successfully initiated,
     *         <code>false</code> otherwise
     */
    private func readCharacteristic(_ charUUID:CBUUID) -> Bool{
        if isConnected(){
            let char = mCharacteristicMap[charUUID]
            if let c = char, let device = self.mDevice{
                device.readValue(for: c)
                return true
            }
        }
        return false;
    }
    
    /**
     * Enables or disables notifications on the given characteristic
     * @param characteristic_uuid Characteristic's UUID
     * @param enable <code>true</code> to enable notifications,
     *               <code>false</code> to disable notifications
     */
    private func enableNotification(_ characteristic_uuid:CBUUID, _ enable:Bool){
        if let characteristic = mCharacteristicMap[characteristic_uuid], let device = mDevice{
            device.setNotifyValue(enable, for: characteristic)
        }
    }
    
    /**
     * Requests a read of the device name.
     * The event {@link ESenseEventListener#onDeviceNameRead(String)} is fired when the name has been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func getDeviceName() -> Bool {
        return readCharacteristic(DEVICE_NAME_CHARACTERISTIC);
    }
    
    /**
     * Requests a change of the device name.
     * @param deviceName new name for the device (maximum size is 22 characters)
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func setDeviceName(_ deviceName:String) -> Bool{
        let length = deviceName.count;
        if (1 <= length && length <= 22) {
            if let c = mCharacteristicMap[NAME_WRITE_CHARACTERISTIC], let device = mDevice{
                if let dataName = deviceName.data(using: .utf8){
                    device.writeValue( dataName , for: c, type: .withResponse) //
                }
                return true
            }
            return false
        } else {
            return false;
        }
    }
    
    /**
     * Requests a read of the factory accelerometer offset values on the connected device.
     * The event {@link ESenseEventListener#onAccelerometerOffsetRead(int, int, int)} is fired when the values have been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func getAccelerometerOffset() -> Bool{
        return readCharacteristic(ACCELEROMETER_OFFSET_CHARACTERISTIC);
    }
    
    /**
     * Requests a read of the sensor configuration on the connected device.
     * The event {@link ESenseEventListener#onSensorConfigRead(ESenseConfig)} is fired when the configuration has been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func getSensorConfig() -> Bool{
        return readCharacteristic(SENSOR_CONFIG_CHARACTERISTIC);
    }
    
    /**
     * Requests a change of the sensor configuration on the connected device.
     * @param config new configuration to be written on the device
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func setSensorConfig(_ config:ESenseConfig) -> Bool {
        if let c = mCharacteristicMap[SENSOR_CONFIG_CHARACTERISTIC], let device = mDevice{
            var bytes = config.prepareCharacteristicData();
            bytes[1] = getCheckSum(bytes,1);
            device.writeValue(Data(bytes: bytes), for: c, type: .withResponse)
            return true;
        }
        return false;
    }
    
    /**
     * Requests a read of the parameter values of advertisement and connection interval on the connected device
     * The event {@link ESenseEventListener#onAdvertisementAndConnectionIntervalRead(int, int, int, int)} is fired when the parameter values have been read from the connected device.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func getAdvertisementAndConnectionInterval() -> Bool{
        return readCharacteristic(ADV_CONN_CHARACTERISTIC);
    }
    
    
    /**
     * Requests a change of the advertisement and connection intervals.
     *
     * <p>
     *     Condition for advertisement interval: 1) the minimum interval should be greater than or equal to 100, 2) the maximum interval should be less than or equal to 2000, 3) the maximum interval should be greater than or equal to the minimum interval.
     * </p>
     * <p>
     *     Condition for connection interval: 1) the minimum interval should be greater than or equal to 20. 2) the maximum interval should be less than or equal to 2000, 3) the difference between the maximum and minimum intervals should be greater than or equal to 20.
     * </p>
     * @param advMinInterval minimum advertisement interval (unit: milliseconds)
     * @param advMaxInterval maximum advertisement interval (unit: milliseconds)
     * @param connMinInterval minimum connection interval (unit: milliseconds)
     * @param connMaxInterval maximum connection interval (unit: mlliseconds)
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func setAdvertisementAndConnectiontInterval(_ advMinInterval:Int,
                                                       _ advMaxInterval:Int,
                                                       _ connMinInterval:Int,
                                                       _ connMaxInterval:Int) -> Bool{
        var adv_min_interval:Int16
        var adv_max_interval:Int16
        var conn_min_interval:Int16
        var conn_max_interval:Int16

        if (100 <= advMinInterval && advMinInterval <= advMaxInterval && advMaxInterval <= 2000) {
            adv_min_interval = (Int16) (Double(advMinInterval) / 0.625)
            adv_max_interval = (Int16) (Double(advMaxInterval) / 0.625)
        } else {
            if (advMinInterval < 100) {
                print(TAG, "In setAdvertisementAndConnectionInterval(), advMinInterval should be greater than or equal to 100, but is set to \(advMinInterval)");
            }
            if (advMaxInterval > 2000){
                print(TAG, "In setAdvertisementAndConnectionInterval(), advMaxInterval should be less than or equal to 2000, but is set to \(advMaxInterval)");
            }
            if (advMinInterval > advMaxInterval){
                print(TAG, "In setAdvertisementAndConnectionInterval(), advMaxInterval should be greater than or equal to advMinInterval, but advMinInterval is set to \(advMinInterval) and advMaxInterval is set to \(advMaxInterval)");
            }
            return false;
        }

        if (20 <= connMinInterval && connMaxInterval <= 2000 && (connMaxInterval-connMinInterval) >= 20) {
            conn_min_interval = (Int16) ( Double(connMinInterval) / 1.25);
            conn_max_interval = (Int16) ( Double(connMaxInterval) / 1.25);
        } else {
            if (connMinInterval < 20){
                print(TAG, "In setAdvertisementAndConnectionInterval(), connMinInterval should be greater than or equal to 20, but is set to \(connMinInterval)")
            }
            if (connMaxInterval > 2000){
                print(TAG, "In setAdvertisementAndConnectionInterval(), connMaxInterval should be less than or equal to 2000, but is set to \(connMaxInterval)")
            }
            if ((connMinInterval-connMaxInterval) < 20){
                print(TAG, "In setAdvertisementAndConnectionInterval(), the difference between connMaxInterval and connMinInterval should be greater than or equal to 20, but connMinInterval is set to \(connMinInterval) and connMaxInterval is set to \(connMaxInterval)")
            }

            return false;
        }

        var bytes:[UInt8] = [0x57,
                             0x00,
                             0x08,
                             (UInt8) (adv_min_interval / 256),
                             (UInt8) (adv_min_interval % 256),
                             (UInt8) (adv_max_interval / 256),
                             (UInt8) (adv_max_interval % 256),
                             (UInt8) (conn_min_interval / 256),
                             (UInt8) (conn_min_interval % 256),
                             (UInt8) (conn_max_interval / 256),
                             (UInt8)(conn_max_interval % 256)]

        bytes[1] = getCheckSum(bytes,1);
        if let device = self.mDevice,
            let c = mCharacteristicMap[CONFIG_CHARACTERISTIC]{
            device.writeValue(Data(bytes: bytes), for: c, type: .withResponse)
            return true;
        }
        return false
    }

    /**
     * Requests a read of the battery voltage of the connected device.
     * The event {@link ESenseEventListener#onBatteryRead(double)} is fired when the voltage has been read.
     * @return <code>true</code> if the request was successfully made,
     *         <code>false</code> otherwise
     */
    public func getBatteryVoltage() -> Bool {
        return readCharacteristic(BATTERY_CHARACTERISTIC);
    }

    /**
     * Registers a sensor listener and starts sensor sampling on the connected device.
     * The event {@link ESenseSensorListener#onSensorChanged(ESenseEvent)} is fired every time a new sample is available from the connected device.
     * @param listener sensor listener
     * @param samplingRate sensor sampling rate in Hz (min: 1 - max: 100)
     * @return {@link SamplingStatus#STARTED} if the sampling was started successfully,
     *         {@link SamplingStatus#ERROR} if the parameter is incorrect,
     *         {@link SamplingStatus#DEVICE_DISCONNECTED} if the device is disconnected
     */
    public func registerSensorListener(_ listener:ESenseSensorListener, hz samplingRate :UInt8) -> SamplingStatus{
        if !isConnected() {
            print(TAG, "eSense device is not connected");
            return SamplingStatus.DEVICE_DISCONNECTED;
        }
        if(samplingRate < 1 || 100 < samplingRate){
            print(TAG, "In registerSensorListener(), samplingRate should be set between 1 and 100, but is set to \(samplingRate)" );
            return SamplingStatus.ERROR;
        }
        
        if let device = self.mDevice,
            let c = mCharacteristicMap[CONFIG_CHARACTERISTIC]{
            var bytes:[UInt8] = [0x53, 0x00, 0x02, 0x01, samplingRate];
            bytes[1] = getCheckSum(bytes ,1);
            device.writeValue(Data(bytes: bytes), for: c, type: .withResponse)

            mSensorListener = listener;
            enableNotification(SENSOR_CHARACTERISTIC,true);
            return SamplingStatus.STARTED;
        }
        
        return SamplingStatus.ERROR
        
    }

    /**
     * Unregisters a sensor listener and stops sensor sampling on the connected device
     */
    public func unregisterSensorListener(){
        if let device = self.mDevice,
            let c = mCharacteristicMap[CONFIG_CHARACTERISTIC]{
            let IMU_STOP_CMD:[UInt8] = [0x53, 0x02, 0x02, 0x00, 0x00];
            
            device.writeValue(Data(bytes: IMU_STOP_CMD), for: c, type: .withResponse)
            
            enableNotification(SENSOR_CHARACTERISTIC, false);
            mSensorListener = nil
        }
    }

    /**
     * Registers an event listener and enables notifications on button events.
     * @param listener event listener
     * @return <code>true</code> if the listener was registered correctly
     *         <code>false</code> otherwise
     */
    public func registerEventListener(_ listener:ESenseEventListener ) -> Bool {
        if !isConnected() {
            return false
        }

        mEventListener = listener
        enableNotification(BUTTON_CHARACTERISTIC,true)
        return true
    }

    /**
     * Unregisters a sensor listener and stops notifications on button events
     */
    public func unregisterEventListener(){
        enableNotification(BUTTON_CHARACTERISTIC,false)
        mEventListener = nil
    }
    
    
    
    /**
     * Checks if the device is connected or not
     * @return <code>true</code> if device is connected
     *         <code>false</code> otherwise
     */
    public func isConnected() -> Bool {
        
        guard let device = mDevice else {
            return false
        }
        
        switch device.state {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    /**
     * Disconnects device.
     * The event {@link ESenseConnectionListener#onDisconnected(ESenseManager manager)} is fired after the disconnection has taken place.
     * @return <code>true</code> if the disconnection was successfully made
     *         <code>false</code> otherwise
     */
    public func disconnect() -> Bool {
        if(isConnected()) {
            if let device = mDevice, let manager = mBluetoothManager{
                manager.cancelPeripheralConnection(device)
                return true
            }
        }
        return false;
        
    }
    
    /**
     * Initiates a connection procedure. The phone will first scan for the device with a given name and. Then, if found, it will try to connect.
     * The events {@link ESenseConnectionListener#onDeviceFound(ESenseManager manager)}, {@link ESenseConnectionListener#onDeviceNotFound(ESenseManager manager)} or {@link ESenseConnectionListener#onConnected(ESenseManager manager)} are fired at different stages of the procedure.
     * @param timeout scan timeout in milli seconds
     * @return <code>true</code> if the procedure started successfully
     *         <code>false</code> otherwise
     */
    public func connect(timeout:Int) -> Bool{
        do {
            try findDevice(timeout)
            return true
        } catch {
            print("Error at connect method in ESenseManager")
            return false
        }
    }
    
    /**
     * Scans for the device with the name specified when the manager was constructed.
     * The events {@link ESenseConnectionListener#onDeviceFound(ESenseManager manager)}, {@link ESenseConnectionListener#onDeviceNotFound(ESenseManager manager)} are fired if the device has been found or if it was not found.
     * @param timeout in milliseconds
     */
    private func findDevice(_ timeout:Int) throws {

        guard let deviceName = mDeviceName else {
            print(TAG, "Error at findDevice method in ESenseManager: The target device name is NULL.")
            return
        }
        
        if self.timeoutTimer != nil {
            print(TAG, "Error at findDevice method in ESenseManager: A device scanner is already running.")
            return
        }
        
        scanner = ESenseScanner(name: deviceName)
        if let scanner = self.scanner {
            
            // connection listener
            scanner.connectHandler = {(mDevice) in
                if let connectionListener = self.mConnectionListener {
                    connectionListener.onConnected(self)
                }
                
                self.mDevice = mDevice
                if let bleDevice = self.mDevice {
                    bleDevice.delegate = self
                    bleDevice.discoverServices(nil)
                }
            }
            
            // disconnect listener
            scanner.disconnectHandler = {(mDevice) in
                if let connectionListener = self.mConnectionListener {
                    connectionListener.onDisconnected(self)
                }
            }
            
            // timeout timer
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeout), repeats: false, block: { (timer) in
                if let connectionListener = self.mConnectionListener {
                    connectionListener.onDeviceNotFound(self)
                }
                timer.invalidate()
                self.timeoutTimer = nil
                if let scanner = self.scanner {
                    scanner.stopScan()
                }
            })
            
            // scan listener
            scanner.scan{ (mDevice) in
                // invalidate a timeout timer
                if let timer = self.timeoutTimer {
                    timer.invalidate()
                    self.timeoutTimer = nil
                }
                
                if let connectionListener = self.mConnectionListener {
                    connectionListener.onDeviceFound(self)
                }
            }
        }
    }
    
    private class ESenseBGattCallback{
        
    }
    
}

extension ESenseManager:CBPeripheralDelegate{
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for s in services {
                peripheral.discoverCharacteristics(nil, for: s)
                // print(s)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for c in characteristics {
                mCharacteristicMap.updateValue(c, forKey: c.uuid)
                // print(c)
            }
            if let handler = self.mDeviceReadyHandler{
                handler(peripheral)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor c: CBCharacteristic, error: Error?) {
        if c.uuid == DEVICE_NAME_CHARACTERISTIC {
            if let listener = self.mEventListener, let data = c.value{
                if let name = String(data: data, encoding: .utf8) {
                    listener.onDeviceNameRead(name)
                }
            }
        }else if c.uuid == BATTERY_CHARACTERISTIC {
            if let data = c.value {
                var bytes = [UInt8](data)
                if let listener = self.mEventListener{
                    if (checkCheckSum(bytes, 1)) {
                        let vol:Double = Double(Int(bytes[3] & 0xff) * 256 + Int(bytes[4] & 0xff)) / 1000.0
                        listener.onBatteryRead(vol);
                    }
                }
            }
        }else if c.uuid == SENSOR_CHARACTERISTIC{
            if let data = c.value {
                var bytes = [UInt8](data)
                // print(bytes)
                if(checkCheckSum(bytes, 2)) {
                    var acc:[Int16]  = [0,0,0]
                    var gyro:[Int16] = [0,0,0]
                    for i in 0..<acc.count {
                        let accVal  = Int16(bitPattern: ((UInt16(bytes[i*2+10]) << 8) | (UInt16(bytes[i*2+11]))))
                        let gyroVal = Int16(bitPattern: ((UInt16(bytes[i*2+4]) << 8) | (UInt16(bytes[i*2+5]))))
                        acc[i]  = accVal
                        gyro[i] = gyroVal
                    }
                    
                    let eSenseEvent:ESenseEvent = ESenseEvent(accel: acc, gyro: gyro);
                    eSenseEvent.setTimestamp(Int64(Date().timeIntervalSince1970 * 1000.0));
                    // eSenseEvent.setPacketIndex(bytes[1] < 0 ? Int(bytes[1]) + 256 : Int(bytes[1]));
                    eSenseEvent.setPacketIndex(Int(bytes[1]) + 256);
                    
                    if let listener = self.mSensorListener {
                        listener.onSensorChanged(eSenseEvent);
                    }
                }
            }
        } else if c.uuid == BUTTON_CHARACTERISTIC {
            if let listener = self.mEventListener {
                if let data = c.value {
                    var bytes = [UInt8](data)
                    if(checkCheckSum(bytes,1)) {
                        let value:UInt8 = bytes[3];
                        listener.onButtonEventChanged(value == 1);
                    }
                }
            }
        } else if c.uuid == SENSOR_CONFIG_CHARACTERISTIC{
            if let listener = self.mEventListener {
                if let data = c.value {
                    let bytes = [UInt8](data)
                    if(checkCheckSum(bytes,1)) {
                        let config = ESenseConfig(charaterictic_data:bytes);
                        listener.onSensorConfigRead(config);
                    }
                }
            }
        } else if c.uuid == ACCELEROMETER_OFFSET_CHARACTERISTIC {
            if let listener = self.mEventListener {
                if let data = c.value {
                    let bytes = [UInt8](data)
                    if(checkCheckSum(bytes,1)) {
                        // Format is in +-16G in which 1g = 2048
                        let offsetX = Int16(bitPattern: ((UInt16) (bytes[9]) << 8) | (UInt16)(bytes[10] & 0xff));
                        let offsetY = Int16(bitPattern: ((UInt16) (bytes[11]) << 8) | (UInt16)(bytes[12] & 0xff));
                        let offsetZ = Int16(bitPattern: ((UInt16) (bytes[13]) << 8) | (UInt16)(bytes[14] & 0xff));
                        listener.onAccelerometerOffsetRead(Int(offsetX), Int(offsetY), Int(offsetZ));
                    }
                }
            }
        } else if c.uuid == ADV_CONN_CHARACTERISTIC {
            if let listener = self.mEventListener {
                if let data = c.value {
                    let bytes = [UInt8](data)
                    if (checkCheckSum(bytes, 1)) {
                        
                        
                        let minAdvertisementInterval = (Double)(Int16(bitPattern:((UInt16(bytes[3] & 0xff) << 8) | UInt16(bytes[4] & 0xff)))) * 0.625
                        let maxAdvertisementInterval = (Double)(Int16(bitPattern:((UInt16(bytes[5] & 0xff) << 8) | UInt16(bytes[6] & 0xff)))) * 0.625
                        let minConnectionInterval = (Double)(Int16(bitPattern:((UInt16(bytes[7] & 0xff) << 8) | UInt16(bytes[8] & 0xff)))) * 1.25
                        let maxConnectionInterval = (Double)(Int16(bitPattern:((UInt16(bytes[9] & 0xff) << 8) | UInt16(bytes[10] & 0xff)))) * 1.25
                        
                        listener.onAdvertisementAndConnectionIntervalRead(
                            Int(minAdvertisementInterval),
                            Int(maxAdvertisementInterval),
                            Int(minConnectionInterval),
                            Int(maxConnectionInterval)
                        )
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // print(#function, characteristic)
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor c: CBCharacteristic, error: Error?) {
        if c.uuid == NAME_WRITE_CHARACTERISTIC {
            if let data = c.value {
                if let name = String(data: data, encoding: .utf8) {
                    mDeviceName = name
                }
            }
        }
    }
}
