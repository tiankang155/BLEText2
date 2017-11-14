//
//  ViewController.swift
//  BLEText2
//
//  Created by yarui on 2017/11/6.
//  Copyright © 2017年 Tiankang. All rights reserved.
//
let dfuServiceUUIDString  = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
let ANCSServiceUUIDString = "00001530-1212-EFDE-1523-785FEABCD123"
let dfuServiceUUID = CBUUID(string: dfuServiceUUIDString)
let ancsServiceUUID   = CBUUID(string: ANCSServiceUUIDString)
let cellID = "cellid"


import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate {
     
    var isOpenBLE : Bool?
    var bluetoothManager : CBCentralManager?
    var filterUUID       : CBUUID?
    var peripherals      : [ScannedPeripheral] = []
    var timer            : Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(devicesTable)
        devicesTable.delegate = self
        devicesTable.dataSource = self
        if #available(iOS 11.0, *) {
            devicesTable.contentInsetAdjustmentBehavior = .never
            devicesTable.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
            devicesTable.scrollIndicatorInsets = devicesTable.contentInset
        } else {
        }
        
        let barBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPeripheral))
        
        self.navigationItem.rightBarButtonItem = barBtn
        
        let centralQueue = DispatchQueue(label: "no.nordicsemi.nRFToolBox", attributes: [])
        bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
        searchPeripheral()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        let success = self.scanForPeripherals(false)
        if !success {
            print("Bluetooth is powered off!")
        }
        
       // UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    lazy var devicesTable:UITableView = {
        let tab = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        tab.rowHeight = 70
        tab.tableFooterView = UIView()
        return tab
    }()
    @objc func searchPeripheral() {
        peripherals.removeAll()
        
        let connectedPeripherals = self.getConnectedPeripherals()
        var newScannedPeripherals: [ScannedPeripheral] = []
        connectedPeripherals.forEach { (connectedPeripheral: CBPeripheral) in
            let connected = connectedPeripheral.state == .connected
            let scannedPeripheral = ScannedPeripheral(withPeripheral: connectedPeripheral, andIsConnected: connected )
            newScannedPeripherals.append(scannedPeripheral)
        }
        peripherals = newScannedPeripherals
        let success = self.scanForPeripherals(true)
        if !success {
 
            DispatchQueue.main.async {
                self.view.showError("蓝牙已关闭，请前往系统设置中开启蓝牙功能")
            }
        }
    }
    
    @objc func timerFire() {
        if peripherals.count > 0 {
           devicesTable.reloadData()
        }
    }
    func getRSSIImage(RSSI anRSSIValue: Int32) -> UIImage {
        var image: UIImage
        
        if  anRSSIValue < -90 || anRSSIValue == 0 {
            image = UIImage(named: "Signal_0")!
        } else if  anRSSIValue < -70  {
            image = UIImage(named: "Signal_1")!
        } else if  anRSSIValue < -50  {
            image = UIImage(named: "Signal_2")!
        } else {
            image = UIImage(named: "Signal_3")!
        }
        
        return image
    }
    
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        
        var retreivedPeripherals : [CBPeripheral]
        
        if filterUUID == nil {
            let dfuServiceUUID       = CBUUID(string: dfuServiceUUIDString)
            let ancsServiceUUID      = CBUUID(string: ANCSServiceUUIDString)
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [dfuServiceUUID, ancsServiceUUID])
        } else {
            retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices: [filterUUID!])
        }
        
        return retreivedPeripherals
    }
    func scanForPeripherals(_ enable:Bool) -> Bool {
        guard bluetoothManager?.state == .poweredOn else {
            return false
        }
        
        DispatchQueue.main.async {
            if enable == true {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                if self.filterUUID != nil {
                    self.bluetoothManager?.scanForPeripherals(withServices: [self.filterUUID!], options: options as? [String : AnyObject])
                } else {
                    self.bluetoothManager?.scanForPeripherals(withServices: nil, options: options as? [String : AnyObject])
                }
              self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: true)
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.bluetoothManager?.stopScan()
            }
        }
        
        return true
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
             return peripherals.count
       
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var aCell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if  aCell == nil {
            aCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        }
        aCell?.textLabel?.font = UIFont.systemFont(ofSize: 20)

        //Update cell content
        let scannedPeripheral = peripherals[indexPath.row]
        aCell?.textLabel?.text = "\(indexPath.row+1)-\(scannedPeripheral.name())"
        aCell?.detailTextLabel?.text = "\(scannedPeripheral.RSSI)"
        if scannedPeripheral.isConnected == true {
            aCell?.imageView!.image = UIImage(named: "Connected")
            aCell?.textLabel?.textColor = .red
            aCell?.detailTextLabel?.textColor = .red
            
        } else {
            let RSSIImage = self.getRSSIImage(RSSI: scannedPeripheral.RSSI)
            aCell?.imageView!.image = RSSIImage
            aCell?.textLabel?.textColor = .gray
            aCell?.detailTextLabel?.textColor = .gray
        }
        
        return aCell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //bluetoothManager!.stopScan()
        let peripheral = peripherals[indexPath.row].peripheral
        if peripheral.state == .connected {

            let ReceiveData = ReceiveDataController()
                ReceiveData.peripheral = peripheral
            self.navigationController?.pushViewController(ReceiveData, animated: true)
            
        }else{
            if isOpenBLE == false{
                DispatchQueue.main.async {
                    self.view.showError("蓝牙已关闭，请前往系统设置中开启蓝牙功能")
                    
                }
               return
            }
           let time: TimeInterval = 1.0
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                
              self.view.showTitle("正在连接...")
             self.bluetoothManager?.connect(peripheral, options: nil)
           }
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    //MARK: - CBCentralManagerDelgate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
           isOpenBLE = true
//          searchPeripheral()
            let success = self.scanForPeripherals(true)
            if !success {
                
                DispatchQueue.main.async {
                    self.view.showError("蓝牙已关闭，请前往系统设置中开启蓝牙功能")
                }
            }
         }else {
//
 
            DispatchQueue.main.async {
                self.view.showError("蓝牙已关闭，请前往系统设置中开启蓝牙功能")
            }
          isOpenBLE = false
          return
        }
        
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Scanner uses other queue to send events. We must edit UI in the main queue
        if let name = peripheral.name {
            if name.hasPrefix("WOOWI IK-1"){
                DispatchQueue.main.async(execute: {
                    
                    var sensor = ScannedPeripheral(withPeripheral: peripheral, andRSSI: RSSI.int32Value, andIsConnected: false)
                    if self.peripherals.contains(sensor) == false {
                        self.peripherals.append(sensor)
                    }else{
                        //                    如果扫描到的外设存在数组中 那么传入对象找出在对象中的索引 通过索引找出对象中原来的位置 修改新的rssi值
                        sensor = self.peripherals[self.peripherals.index(of: sensor)!]
                        sensor.RSSI = RSSI.int32Value
                    }
                    
                    
                })
            }
        }else{
            
        }
        
    }
    
//    已经连接
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已经连接")
        peripheral.delegate = self
        peripheral.readRSSI()
//        读取外设的所有服务
        peripheral.discoverServices(nil)
        
         guard let name = peripheral.name else { return }
        
        DispatchQueue.main.async {
             self.view.showTitle("\(name)已连接")
        }
    
        var sensor = ScannedPeripheral(withPeripheral: peripheral, andRSSI: 0, andIsConnected: true)
        sensor = self.peripherals[self.peripherals.index(of: sensor)!]
        sensor.isConnected = true
        devicesTable.reloadData()
        
    }
    
//    连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
        
    }
    
//   断开连接
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
      //  guard let name = peripheral.name else { return }
//      self.view.showTitle("\(name)已断开")
        var sensor = ScannedPeripheral(withPeripheral: peripheral, andRSSI: 0, andIsConnected: false)
        sensor = self.peripherals[self.peripherals.index(of: sensor)!]
        sensor.isConnected = false
        devicesTable.reloadData()
        bluetoothManager?.connect(peripheral, options: nil)
    }
}
extension ViewController:CBPeripheralDelegate{
    /*
     **这个是主动调用了 [peripheral readRSSI];方法回调的RSSI，你可以根据这个RSSI估算一下距离
     */
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
     
       let time: TimeInterval = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            peripheral.readRSSI()
            var sensor = ScannedPeripheral(withPeripheral: peripheral, andRSSI: 0, andIsConnected: true)
            sensor = self.peripherals[self.peripherals.index(of: sensor)!]
            sensor.isConnected = true
            sensor.RSSI = RSSI.int32Value
            self.devicesTable.reloadData()
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
//    发现特性
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristics in service.characteristics! {
            
            if characteristics.uuid.uuidString == "2A19"{
                
                peripheral.setNotifyValue(true, for: characteristics)
                peripheral.readValue(for: characteristics)
            }
            if characteristics.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"{
                peripheral.setNotifyValue(true, for: characteristics)
            }
            if characteristics.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"{
                
                peripheral.setNotifyValue(true, for: characteristics)
                peripheral.readValue(for: characteristics)
            }
            if characteristics.uuid.uuidString == "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"{
                
                peripheral.setNotifyValue(true, for: characteristics)
                peripheral.readValue(for: characteristics)
            }
        }
    }
    /*
     //获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let reportData = ReceiveData.receiceData(for: characteristic)
 
        PRINT(reportData);
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_data"), object: nil, userInfo: ["receive_data":reportData,"peripheral":peripheral])
        
    }
    
    
}
