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
    var sensingFrequency:UInt8 = 30 // hz
    var sensorName = "eSense-0063"
    var connectionTimeout = 60
    var sensorConfig:ESenseConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let lineAccXYZ = lineDataWithCount(300, labels: ["Acc-X","Acc-Y","Acc-Z"])
        setupLineChart(accView, data: lineAccXYZ)
        
        let lineGyroXYZ = lineDataWithCount(300, labels: ["Gyro-X","Gyro-Y","Gyro-Z"])
        setupLineChart(gyroView, data: lineGyroXYZ)
        
        sensorConfig = ESenseConfig(accRange: .G_8, gyroRange: .DEG_1000, accLPF: .BW_10, gyroLPF: .BW_10)
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
    
}

extension ViewController{
    
    func startConnection(){
        let alert = UIAlertController.init(title: "Please set your eSense name",
                                           message: nil,
                                           preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.sensorName
        }
        alert.addAction(UIAlertAction(title: "Start Scanning", style: .default, handler: { (action) in
            if let textFileds = alert.textFields {
                if let nameField = textFileds.first {
                    if let name = nameField.text {
                        self.navigationController?.title = name
                        self.debugLabel.text = "Start Scanning: \(name)"
                        
                        //////////////////////////////
                        // e.g. name = eSense-0063
                        self.manager = ESenseManager(deviceName: name, listener: self)
                        if let m = self.manager {
                            print(m.connect(timeout: self.connectionTimeout ))
                        }
                        ///////////////////////////////
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
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
            if let config = self.sensorConfig{
                 print(manager.setSensorConfig(config))
            }
            print(manager.registerEventListener(self))
            print(manager.registerSensorListener(self, hz: self.sensingFrequency))
            
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
            let acc = evt.convertAccToG(config: config)
            updateLineChart(self.accView, acc)
            
            let gyro = evt.convertGyroToDegPerSecond(config: config)
            updateLineChart(self.gyroView, gyro)
        }
    }
}

extension ViewController:ChartViewDelegate {
    
    
    func lineDataWithCount(_ count: Int, labels:[String]) -> LineChartData {
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
