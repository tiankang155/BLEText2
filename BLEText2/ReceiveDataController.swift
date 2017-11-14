//
//  ReceiveDataController.swift
//  BLEText2
//
//  Created by yarui on 2017/11/7.
//  Copyright © 2017年 Tiankang. All rights reserved.
//

let Notify = NotificationCenter.default
import UIKit
import CoreBluetooth
enum GestureProtocol:Int {
    case up = 0
    case down = 3
    case left = 5
    case right = 2
    //    case forward =
    case clockwise = 6 //顺时针
    case anticlockwise =  9// 逆时针
}
class ReceiveDataController: UIViewController {
    

    
    @IBOutlet weak var upBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var downBtn: UIButton!
    
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    var peripheral:CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "手势识别"
        self.view.backgroundColor = UIColor.white
        contentLabel.layer.cornerRadius = 50
        contentLabel.layer.masksToBounds = true
      
        Notify.addObserver(self, selector: #selector(receiveData), name: NSNotification.Name.init("receive_data"), object: nil)
     
    }
  
    
    @objc func receiveData(noti:Notification){
        guard let userInfo = noti.userInfo else {
            return
        }
        guard  let data = userInfo["receive_data"] as? Int else {return}
        guard  let per = userInfo["peripheral"] as? CBPeripheral else {return}
        PRINT(per)
        PRINT(data)
        
      
        if per.name == peripheral?.name {

            let receiveData =  GestureProtocol(rawValue: data)
            switch receiveData{
            case .some(.up):
                DispatchQueue.main.async {
                    self.contentLabel.text = "向上"
                    self.upBtn.titleLabel?.textColor = .red
                    self.downBtn.titleLabel?.textColor = .gray
                    self.leftBtn.titleLabel?.textColor = .gray
                    self.rightBtn.titleLabel?.textColor = .gray
                }
               
            case .some(.down):
                DispatchQueue.main.async {
                    self.contentLabel.text = "向下"
                    self.downBtn.titleLabel?.textColor = .red
                    self.upBtn.titleLabel?.textColor = .gray
                    self.leftBtn.titleLabel?.textColor = .gray
                    self.rightBtn.titleLabel?.textColor = .gray
                    
                }
                
            case .some(.left):
                DispatchQueue.main.async {
                    self.contentLabel.text = "向左"
                    self.leftBtn.titleLabel?.textColor = .red
                    self.downBtn.titleLabel?.textColor = .gray
                    self.upBtn.titleLabel?.textColor = .gray
                    self.rightBtn.titleLabel?.textColor = .gray
                }
               
            case .some(.right):
                DispatchQueue.main.async {
                    self.contentLabel.text = "向右"
                    self.rightBtn.titleLabel?.textColor = .red
                    self.leftBtn.titleLabel?.textColor = .gray
                    self.downBtn.titleLabel?.textColor = .gray
                    self.upBtn.titleLabel?.textColor = .gray
                }
               
                
            case .some(.clockwise):
                DispatchQueue.main.async {
                    self.contentLabel.text = "顺时针"
                    self.rightBtn.titleLabel?.textColor = .red
                    self.leftBtn.titleLabel?.textColor = .gray
                    self.downBtn.titleLabel?.textColor = .red
                    self.upBtn.titleLabel?.textColor = .red
                }
                
                
            case .some(.anticlockwise):
                DispatchQueue.main.async {
                     self.contentLabel.text = "逆时针"
                     self.rightBtn.titleLabel?.textColor = .gray
                     self.leftBtn.titleLabel?.textColor = .red
                     self.downBtn.titleLabel?.textColor = .red
                    self.upBtn.titleLabel?.textColor = .red
                    
                }
               
            case .none: break
                
            }
            
           
        }else{
            DispatchQueue.main.async {
               self.view.showError("设备不一致")
                
            }
            
        }
        
        
    }
    
    @IBAction func click(_ sender: Any) {
     
    }
    
}
func PRINT<T>(_ message: T, fileName: String = #file, lineNum: Int = #line, funcName: String = #function)
{
    #if DEBUG
        print("\((fileName as NSString).lastPathComponent)[\(lineNum)] \(funcName): \(message)")
    #endif
}
