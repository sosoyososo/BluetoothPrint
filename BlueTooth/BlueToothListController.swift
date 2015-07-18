
//
//  File.swift
//
//  Created by Karsa wang on 7/9/15.
//  Copyright (c) 2015 Karsa wang. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueToothListController :UITableViewController, UIActionSheetDelegate, CBPeripheralDelegate {
    var list = [CBPeripheral]()
    var operatingPeripheral : CBPeripheral?
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.frame = CGRectMake(0, 0, 100, 20)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = "蓝牙列表"
        self.navigationItem.titleView = label;
        
        self.list = BlueToothManager.shareInstance().peripheralList
        
        BlueToothManager.shareInstance().startScan()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralListUpdate:", name: Notify_BlueTooth_update, object: nil)
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        BlueToothManager.shareInstance().stopScan()
    }
    func peripheralListUpdate(notify: NSNotification?) {
        self.list = BlueToothManager.shareInstance().peripheralList
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var ret: AnyObject? = tableView.dequeueReusableCellWithIdentifier("")
        if nil == ret {
            ret = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "")
        }
        let cell = ret as! UITableViewCell
        let peripheral = self.list[indexPath.row]
        cell.textLabel?.text = peripheral.name
        var stateStr = "未连接"
        switch peripheral.state {
        case CBPeripheralState.Connected:
                stateStr = "已连接"
        case CBPeripheralState.Connecting:
                stateStr = "正在连接..."
        case CBPeripheralState.Disconnected:
                stateStr = "已断开"
        }
        cell.detailTextLabel?.text = stateStr
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let peripheral = self.list[indexPath.row]
        self.operatingPeripheral = peripheral
        if peripheral.state != CBPeripheralState.Connecting {
            if peripheral.state==CBPeripheralState.Connected {
                let action = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "断开", otherButtonTitles: "打印测试")
                action.showInView(self.tableView)
            } else {
                let action = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle:"连接")
                action.showInView(self.tableView)
            }
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            if self.operatingPeripheral?.state == CBPeripheralState.Connected {
                if actionSheet.destructiveButtonIndex == buttonIndex {
                    BlueToothManager.shareInstance().disConnectPeripheral(self.operatingPeripheral!)
                } else {
                    BlueToothPrinter.instance.testPrint()
                }
            } else {
                BlueToothManager.shareInstance().conectPeripheral(self.operatingPeripheral!)
            }
        }
    }
}
