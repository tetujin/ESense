//
//  SettingsViewController.swift
//  ESense_Example
//
//  Created by Yuuki Nishiyama on 2019/08/21.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ESense

struct SettingContent {
    let title:String
    let description:String
    let key:SettingKeys
    
    init(key:SettingKeys, title:String, description:String) {
        self.key = key
        self.title = title
        self.description = description
    }
}

enum SettingKeys:String {
    case name    = "ESENSE_NAME"
    case label   = "ESENSE_LABLE"
    case sensingFrequency = "ESENSE_SENSING_FREQUENCY"
    case accG    = "ESENSE_ACC_G"
    case gyroDEG = "ESENSE_GYRO_G"
    case accLPF  = "ESENSE_ACC_LPF"
    case gyroLPF = "ESENSE_GYRO_LPF"
    case advertisementInterval = "ESENSE_ADV_INTERVAL"
    case battery     = "ESENSE_BATTERY"
    case saveCSV     = "ESENSE_SAVE_CSV"
    case csvFileName = "ESENSE_CSV_FILE_NAME"
    case exportCSV   = "ESENSE_EXPORT_CSV"
}

class SettingsViewController: UITableViewController {
    
    public var eSensrManager:ESenseManager?

    let rows = [SettingContent(key: .name,
                               title: "eSense Name",
                               description: ""),
                SettingContent(key: .label,
                               title: "Label",
                               description: ""),
                SettingContent(key: .sensingFrequency,
                               title: "Sensing Frequency",
                               description: "Hz"),
                SettingContent(key: .accG,
                               title: "Accelerometer G",
                               description: "G"),
                SettingContent(key: .gyroDEG,
                               title: "Gyroscope DEG",
                               description: "DEG"),
                SettingContent(key: .accLPF,
                               title: "Low-Pass Filter (Accelerometer)",
                               description: "BW"),
                SettingContent(key: .gyroLPF,
                               title: "Low-Pass Filter (Gyroscope)",
                               description: "BW"),
                SettingContent(key: .saveCSV,
                             title: "Data Save (CSV)",
                             description: "No"),
                SettingContent(key: .csvFileName,
                               title: "CSV File Name",
                               description: "eSense.csv"),
                SettingContent(key: .exportCSV,
                               title: "CSV File Control",
                               description: "")
                ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        
        if indexPath.row < rows.count {
            let row = rows[indexPath.row]
            
            // set title
            cell.textLabel?.text = row.title
            
            // set description
            switch row.key {
            case .label:
                if let text = UserDefaults.standard.string(forKey: SettingKeys.label.rawValue ){
                    cell.detailTextLabel?.text = text
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .accG:
                if let range = UserDefaults.standard.getAccRange(forKey: SettingKeys.accG.rawValue ){
                    cell.detailTextLabel?.text = range.label
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .gyroDEG:
                if let range = UserDefaults.standard.getGyroRange(forKey: SettingKeys.gyroDEG.rawValue ){
                    cell.detailTextLabel?.text = range.label
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .accLPF:
                if let lpf = UserDefaults.standard.getAccLPF(forKey: SettingKeys.accLPF.rawValue ){
                    cell.detailTextLabel?.text = lpf.label
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .gyroLPF:
                if let lpf = UserDefaults.standard.getGyroLPF(forKey: SettingKeys.gyroLPF.rawValue ){
                    cell.detailTextLabel?.text = lpf.label
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .sensingFrequency:
                let hz = UserDefaults.standard.integer(forKey: SettingKeys.sensingFrequency.rawValue )
                cell.detailTextLabel?.text = String(hz)
                break
            case .advertisementInterval: break
            case .battery: break
            case .name:
                if let text = UserDefaults.standard.string(forKey: SettingKeys.name.rawValue ){
                    cell.detailTextLabel?.text = text
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .saveCSV:
                if UserDefaults.standard.bool(forKey: SettingKeys.saveCSV.rawValue ){
                    cell.detailTextLabel?.text = "Yes"
                }else{
                    cell.detailTextLabel?.text = "No"
                }
                break
            case .csvFileName:
                if let fileName = UserDefaults.standard.string(forKey: SettingKeys.csvFileName.rawValue ){
                    cell.detailTextLabel?.text = fileName
                }else{
                    cell.detailTextLabel?.text = row.description
                }
                break
            case .exportCSV:
                cell.textLabel?.text = row.title
                break
            }
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(indexPath.row)
        if rows.count > indexPath.row {
            let row = rows[indexPath.row]
            switch row.key {
            case .label, .name:
                let rawKey = row.key.rawValue
                let alert = UIAlertController(title: "Please set a \(row.title)",
                                              message: nil,
                                              preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.text = UserDefaults.standard.string(forKey: rawKey ) ?? ""
                }
                alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { (action) in
                                                if let textFields = alert.textFields {
                                                    if let textField = textFields.first {
                                                        if let text = textField.text{
                                                            UserDefaults.standard.setValue(text, forKey: rawKey)
                                                        }
                                                    }
                                                }
                                                self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .accG, .gyroDEG, .accLPF, .gyroLPF:
                let alert = UIAlertController(title: "Please select your required configuration",
                                              message: nil,
                                              preferredStyle: .actionSheet)
                switch row.key {
                case .accG:
                    for option in ESenseConfig.AccRange.values {
                        alert.addAction(UIAlertAction(title: option.label , style: .default, handler: { (action) in
                            UserDefaults.standard.setAccRange(option, forKey: row.key.rawValue)
                            self.tableView.reloadData()
                        }))
                    }
                    break
                case .accLPF:
                    for option in ESenseConfig.AccLPF.values {
                        alert.addAction(UIAlertAction(title: option.label , style: .default, handler: { (action) in
                            UserDefaults.standard.setAccLPF(option, forKey: row.key.rawValue)
                            self.tableView.reloadData()
                        }))
                    }
                    break
                case .gyroDEG:
                    for option in ESenseConfig.GyroRange.values {
                        alert.addAction(UIAlertAction(title: option.label , style: .default, handler: { (action) in
                            UserDefaults.standard.setGyroRange(option, forKey: row.key.rawValue)
                            self.tableView.reloadData()
                        }))
                    }
                    break
                case .gyroLPF:
                    for option in ESenseConfig.GyroLPF.values {
                        alert.addAction(UIAlertAction(title: option.label , style: .default, handler: { (action) in
                            UserDefaults.standard.setGyroLPF(option, forKey: row.key.rawValue)
                            self.tableView.reloadData()
                        }))
                    }
                    break
                case .advertisementInterval, .battery, .label, .name, .sensingFrequency, .saveCSV, .csvFileName, .exportCSV:
                    break
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .sensingFrequency:
                let rawKey = row.key.rawValue
                let alert = UIAlertController(title: "Please set a sensing frequency (Hz)",
                    message: nil,
                    preferredStyle: .alert)
                alert.addTextField { (textField) in
                    let hz = UserDefaults.standard.integer(forKey: rawKey)
                    textField.text = String(hz)
                }
                alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { (action) in
                    if let textFields = alert.textFields {
                        if let textField = textFields.first {
                            if let hzStr = textField.text{
                                if let hz = Int8.init(hzStr) {
                                    if hz > 0 && hz <= 100{
                                        UserDefaults.standard.setValue(hz, forKey: rawKey)
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .advertisementInterval: break
            case .battery: break
            case .saveCSV:
                let rawKey = row.key.rawValue
                let alert = UIAlertController(title: "Do you save sensor data into a CSV file?",
                                              message: nil,
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    UserDefaults.standard.setValue(true, forKey: rawKey)
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                    UserDefaults.standard.setValue(false, forKey: rawKey)
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .csvFileName:
                let rawKey = row.key.rawValue
                let alert = UIAlertController(title: "Please set a sensing frequency (Hz)",
                                              message: nil,
                                              preferredStyle: .alert)
                alert.addTextField { (textField) in
                    if let fileName = UserDefaults.standard.string(forKey: rawKey) {
                        textField.text = fileName
                    }else{
                        textField.text = "eSense.csv"
                    }
                }
                alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { (action) in
                    if let textFields = alert.textFields {
                        if let textField = textFields.first {
                            if let fileName = textField.text{
                                UserDefaults.standard.set(fileName, forKey: rawKey)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            case .exportCSV:
                
                let alert = UIAlertController(title: "CSV File", message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Export CSV Files", style: .default, handler: { (action) in
                    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    print(self.getFileInfoListInDir(documentDirectory))
                    let activityItems = self.getFileInfoListInDir(documentDirectory)
                    let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
                    self.present(activityVC, animated: true, completion: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "Delete CSV Files", style: .destructive, handler: {(action) in
                    let finalCheck = UIAlertController(title: "Do you delete all CSV files?", message: nil, preferredStyle: .alert)
                    finalCheck.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        for item in self.getFileInfoListInDir(documentDirectory){
                            do{
                                try FileManager.default.removeItem(at: item)
                            }catch{
                                print(#function, "error")
                            }
                        }
                    }))
                    finalCheck.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(finalCheck, animated: true, completion: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func getFileInfoListInDir(_ dirName: URL) -> [URL] {
        let fileManager = FileManager.default
        var files: [URL] = []
        do {
            files = try fileManager.contentsOfDirectory(at: dirName, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            return files
        }
        return files
    }
    
}


extension UserDefaults {
    
    /// Acc Range ///
    func setAccRange(_ value: ESenseConfig.AccRange?, forKey key: String) {
        if let value = value {
            set(value.rawValue, forKey: key)
        } else {
            removeSuite(named: key)
        }
    }
    
    func getAccRange(forKey key: String) -> ESenseConfig.AccRange? {
        return ESenseConfig.AccRange(rawValue: Int8(integer(forKey: key)))
    }
    
    
    /// Gyro Range ///
    func setGyroRange(_ value: ESenseConfig.GyroRange?, forKey key: String) {
        if let value = value {
            set(value.rawValue, forKey: key)
        } else {
            removeSuite(named: key)
        }
    }
    
    func getGyroRange(forKey key: String) -> ESenseConfig.GyroRange? {
        return ESenseConfig.GyroRange(rawValue: Int8(integer(forKey: key)))
    }
    
    /// Acc LPF ///
    func setAccLPF(_ value: ESenseConfig.AccLPF?, forKey key: String) {
        if let value = value {
            set(value.rawValue, forKey: key)
        } else {
            removeSuite(named: key)
        }
    }
    
    func getAccLPF(forKey key: String) -> ESenseConfig.AccLPF? {
        return ESenseConfig.AccLPF(rawValue: Int8(integer(forKey: key)))
    }
    
    /// Gyro LPF ///
    func setGyroLPF(_ value: ESenseConfig.GyroLPF?, forKey key: String) {
        if let value = value {
            set(value.rawValue, forKey: key)
        } else {
            removeSuite(named: key)
        }
    }
    
    func getGyroLPF(forKey key: String) -> ESenseConfig.GyroLPF? {
        return ESenseConfig.GyroLPF(rawValue: Int8(integer(forKey: key)))
    }
    
}
