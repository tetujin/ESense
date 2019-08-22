//
//  ViewController.swift
//  ESense
//
//  Created by tetujin on 08/15/2019.
//  Copyright (c) 2019 tetujin. All rights reserved.
//

import UIKit
import ESense
import CSV
import Charts

class ViewController: UIViewController{

    @IBOutlet weak var accView: LineChartView!
    @IBOutlet weak var gyroView: LineChartView!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    
    var manager:ESenseManager? = nil
    var sensorConfig:ESenseConfig?
    var connectionTimeout = 60
    var sensingFrequency:UInt8 = 1 // hz
    var sensorName = ""
    var label = ""
    var fileName = "eSense.csv"
    var isSaveCSV:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "INIT_STATUS") {
            userDefaults.set(true, forKey: "INIT_STATUS")
            userDefaults.setAccRange(.G_4,        forKey: SettingKeys.accG.rawValue)
            userDefaults.setGyroRange(.DEG_1000,  forKey: SettingKeys.gyroDEG.rawValue)
            userDefaults.setAccLPF(.BW_5,         forKey: SettingKeys.accLPF.rawValue)
            userDefaults.setGyroLPF(.BW_5,        forKey: SettingKeys.gyroLPF.rawValue)
            userDefaults.set(5,             forKey: SettingKeys.sensingFrequency.rawValue)
            userDefaults.set("eSense-0063", forKey: SettingKeys.name.rawValue)
            userDefaults.set("",            forKey: SettingKeys.label.rawValue)
            userDefaults.set("eSense.csv",  forKey: SettingKeys.csvFileName.rawValue)
        }
        
        // Set a chart contents
        setupLineChart(accView,  data: generateLineDataWithCount(300, labels: ["Acc-X","Acc-Y","Acc-Z"]))
        setupLineChart(gyroView, data: generateLineDataWithCount(300, labels: ["Gyro-X","Gyro-Y","Gyro-Z"]))
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPushConnectButton(_ sender: UIButton) {
        if let m = self.manager {
            if m.isConnected() {
                _ = m.disconnect()
            }else{
                self.startConnection()
            }
        }else{
            self.startConnection()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toSettings"{
                if let vc = segue.destination as? SettingsViewController {
                    vc.eSensrManager = self.manager
                }
            }
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if let label = UserDefaults.standard.string(forKey: SettingKeys.label.rawValue),
            let name = UserDefaults.standard.string(forKey: SettingKeys.name.rawValue),
            let fileName = UserDefaults.standard.string(forKey: SettingKeys.csvFileName.rawValue){
            
            self.label = label
            self.sensorName = name
            self.fileName = fileName
            self.isSaveCSV = UserDefaults.standard.bool(forKey: SettingKeys.saveCSV.rawValue)
        }
    }
}

extension ViewController{
    
    func startConnection(){
        if let name = UserDefaults.standard.string(forKey: SettingKeys.name.rawValue){
            self.debugLabel.text = "Start Scanning: \(name)"
            
            self.manager = ESenseManager(deviceName: name, listener: self)
            if let m = self.manager {
                print(m.connect(timeout: self.connectionTimeout ))
            }
        }
    }
}

extension ViewController:ESenseConnectionListener{
    func onDeviceFound(_ manager: ESenseManager) {
        print(#function)
        debugLabel.text = #function
    }
    
    func onDeviceNotFound(_ manager: ESenseManager) {
        print(#function)
        debugLabel.text = #function
    }
    
    func onConnected(_ manager: ESenseManager) {
        print(#function)
        debugLabel.text = #function
        manager.setDeviceReadyHandler { peripheral in
            manager.removeDeviceReadyHandler()
            
            self.connectButton.setTitle("Disconnect", for: .normal)
            self.debugLabel.text = "The connected eSense is ready"
            
            // Get sensor configuration from UserDefaults
            let userDefaults = UserDefaults.standard
            if let accRange  = userDefaults.getAccRange(forKey:  SettingKeys.accG.rawValue),
               let gyroRange = userDefaults.getGyroRange(forKey: SettingKeys.gyroDEG.rawValue),
               let accLPF    = userDefaults.getAccLPF(forKey:    SettingKeys.accLPF.rawValue),
               let gyroLPF   = userDefaults.getGyroLPF(forKey:   SettingKeys.gyroLPF.rawValue){
                // Instance a sensor config
                self.sensorConfig = ESenseConfig.init(accRange: accRange,
                                                      gyroRange: gyroRange,
                                                      accLPF: accLPF,
                                                      gyroLPF: gyroLPF)
                if let config = self.sensorConfig{
                    // set the sensor config to eSense via ESenseManager
                    print(manager.setSensorConfig(config))
                }
            }
            
            // Set eSense event listener
            print(manager.registerEventListener(self))
            
            // Set eSense sensor event listener
            let frequency = userDefaults.integer(forKey: SettingKeys.sensingFrequency.rawValue)
            print(manager.registerSensorListener(self, hz: UInt8(frequency)))
            
            // print(manager.getBatteryVoltage())
            // print(manager.getAdvertisementAndConnectionInterval())
            // print(manager.getAccelerometerOffset())
            // print(manager.getSensorConfig())
            // print(manager.setSensorConfig(ESenseConfig()))
            // print(manager.setDeviceName("eSense-0063"))
        }
    }
    
    func onDisconnected(_ manager: ESenseManager) {
        print(#function)
        self.connectButton.setTitle("Connect", for: .normal)
        self.debugLabel.text = #function
        self.sensorConfig = nil
    }
}

extension ViewController:ESenseEventListener{
    func onBatteryRead(_ voltage: Double) {
        print(#function, voltage)
    }
    
    func onButtonEventChanged(_ pressed: Bool) {
        print(#function, pressed)
        self.debugLabel.text = "\(#function): \(pressed)"
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
        if let config = self.sensorConfig {
            
            let acc  = evt.convertAccToG(config: config)
            let gyro = evt.convertGyroToDegPerSecond(config: config)

            if UIApplication.shared.applicationState == .active {
                // show acc and gyro data
                updateLineChart(self.accView, acc)
                updateLineChart(self.gyroView, gyro)
            }
        
            if isSaveCSV {
                // save acceleromeoter and gyroscope data
                var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentPath.appendPathComponent(self.fileName)

                if let stream = OutputStream(url: documentPath, append: true) {
                    do{
                        let csv = try CSVWriter(stream: stream)
            
//                        if !exists {
//                            try csv.write(row: ["timestamp", "name",
//                                                 "acc-x",  "acc-y",  "acc-z",
//                                                 "gyro-x", "gyro-y", "gyro-z",
//                                                 "label"])
//                            let data = [UInt8](csv.configuration.newline.utf8)
//                            csv.stream.write(data, maxLength: data.count)
//                        }
                        
                        try csv.write(row: [String(evt.getTimestamp()), self.sensorName,
                                            String(acc[0]), String(acc[1]), String(acc[2]),
                                            String(gyro[0]), String(gyro[1]), String(gyro[2]),
                                            self.label])
                        let data = [UInt8](csv.configuration.newline.utf8)
                        csv.stream.write(data, maxLength: data.count)
                        csv.stream.close()
                    } catch CSVError.cannotOpenFile {
                        print(CSVError.cannotOpenFile)
                    } catch CSVError.cannotWriteStream{
                        print(CSVError.cannotWriteStream)
                    } catch {
                        print("Error at \(#function)")
                    }
                }
            }
        }
    }
}

extension ViewController:ChartViewDelegate {
    
    func generateLineDataWithCount(_ count: Int, labels:[String]) -> LineChartData {
        let yVals = (0..<count).map { i -> ChartDataEntry in
            return ChartDataEntry(x: Double(i), y: 0)
        }
        var dataSets = [LineChartDataSet]()
        
        for (i, label) in zip(labels.indices, labels){
            let set = LineChartDataSet(entries: yVals, label: label)
            set.drawValuesEnabled = false
            set.drawCirclesEnabled = false
            if i == 0 {
                set.setColor(NSUIColor.blue)
            }else if i == 1{
                set.setColor(NSUIColor.green)
            }else if i == 2{
                set.setColor(NSUIColor.red)
            }
            dataSets.append(set)
        }
        
        return LineChartData(dataSets: dataSets)
    }
    
    func setupLineChart(_ chart:LineChartView, data:LineChartData){
        chart.delegate = self
        chart.chartDescription?.enabled = true
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.setViewPortOffsets(left: 30, top: 0, right: 0, bottom: 30)
        
        chart.legend.enabled = true
        
        chart.leftAxis.enabled = true
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = true
        chart.data = data
    }
    
    func updateLineChart(_ chart:LineChartView, _ data:Array<Double>){
        if let lineData = chart.lineData{
            if let xPoint = lineData.dataSets.last{
                
                for (i, v) in data.enumerated() {
                    lineData.removeEntry(xValue: 0, dataSetIndex: i)
                    lineData.addEntry(ChartDataEntry(x: xPoint.xMax + 1, y: v), dataSetIndex: i)
                }
                chart.data = lineData
                chart.updateConstraints()
            }
        }
    }
}
