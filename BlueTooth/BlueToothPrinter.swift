//
//  BlueToothPrinter.swift
//
//  Created by Karsa wang on 7/10/15.
//  Copyright (c) 2015 Karsa wang. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import CoreGraphics

let CR = 0x0d
let ESC = 0x1B

class BlueToothPrinter {
    static let instance = BlueToothPrinter()
    var printCharacteristic: CBCharacteristic?
    var currentConnect: CBPeripheral?
    
    func testPrint() {
        let encoding = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        self.enlargeFont(0x22)
        self.writeData(NSString(string: "商户名称").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.enlargeFont(0x00)
        self.writeData(NSString(string: "=========================").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.writeData(NSString(string: "圣女果x1   2.00").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.writeData(NSString(string: "圣女果x1   2.00").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.writeData(NSString(string: "圣女果x1   2.00").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.writeData(NSString(string: "圣女果x1   2.00").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.writeData(NSString(string: "=========================").dataUsingEncoding(encoding)!)
        self.printAndGoNLine(1)
        self.printCode("")
        self.printAndGoNLine(5)
    }
    
    
    /*
    //    [解释]:清除打印缓冲区中的数据,复位打印机打印参数到打印机缺省参数。
    //    [注意]:不是完全恢复到出厂设置,系统参数设置不会被更改。
    */
    
    func resetPrinter() {
        self.writeData(NSData(bytes: [0x1B, 0x40], length: 2))
    }
    /*
    //    用该命令唤醒打印机后,至少需要延迟20毫秒后才能向打印机发送数据,否则 可能导致打印机打印乱码。
    //    如果打印机在没有休眠时接收到此命令,打印机将忽略此命令。
    //    建议开发者在任何时候打印数据前先发送此命令。
    //    打印机从休眠状态被唤醒时,打印参数与休眠前的参数保持一致。
    */
    func wakeUpPrinter() {
        self.writeData(NSData(bytes: [0x00], length: 1))
    }
    /*
    //    将打印缓冲区中的数据全部打印出来并返回标准模式。 打印后,删除打印缓冲区中的数据。
    //    该命令设置打印位置为行的起始点。 如果打印机设置在黑标检测状态,则打印缓冲区中的数据后,走纸到黑标处, 如果黑标不存在,则走纸30cm后停止,预印刷黑标的规范请见附录C.预印刷黑 标说明。
    //    如果在非黑标检测状态,则仅打印缓冲区的内容,不走纸。
    */
    func printAndGoToNextPage() {
        self.writeData(NSData(bytes: [0x0C], length: 1))
    }
    func printAndGoToNextLine() {
        self.writeData(NSData(bytes: [0x0A], length: 1))
    }
    
    func printAndEnter() {
        self.writeData(NSData(bytes: [0x0D], length: 1))
    }
    /*
    打印缓冲区数据并进纸n个垂直点距。
    0 ≤ n ≤ 255,一个垂直点距为0.125mm,以下同。
    */
    func printAndGoForNPoint(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x4A, n], length: 3))
    }
    
    func printAndGoNLine(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x64, n], length: 3))
    }
    
    func printTAB() {
        self.writeData(NSData(bytes: [0x09], length: 1))
    }
    func printTAB2(nL:Int8, nH:Int8) {
        self.writeData(NSData(bytes: [0x1C, 0x55, nL, nH], length: 4))
    }
    
    func chosePrintMode(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x21, n], length: 3))
    }
    /*
    [描述]: n 值用为表示响应的倍高、倍宽信息
    */
    func enlargeFont(n: Int8) {
        self.writeData(NSData(bytes: [0x1D, 0x21, n], length: 3))
    }
    func chooseFont(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x4D, n], length: 3))
    }
    func underLineSwitch() {
        self.writeData(NSData(bytes: [0x1B, 0x2D], length: 2))
    }
    func setReversePrint(enabled: Bool) {
        if enabled {
            self.writeData(NSData(bytes: [0x1D, 0x42, 0x00], length: 3))
        } else {
            self.writeData(NSData(bytes: [0x1D, 0x42, 0x01], length: 3))
        }
    }
    /*
    //字体旋转N个90度,N为0就取消旋转
    */
    func rotateFont(n: Int8) {
        if n <= 3 && n >= 0 {
            self.writeData(NSData(bytes: [0x1B, 0x56, n], length: 3))
        }
    }
    
    func setTAB() {
    }
    
    func setAbsoulutePosition(nL: Int8, nH: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x24, nL, nH], length: 4))
    }
    
    func setRelationPosition(nL: Int8, nH: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x5C, nL, nH], length: 4))
    }
    
    func resetDefaultLineSpace() {
        self.writeData(NSData(bytes: [0x1B, 0x32], length: 2))
    }
    
    func setLineSpace(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x33, n], length: 3))
    }
    
    func setCharacterSpace(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x20, n], length: 3))
    }
    
    func setLeftPrintSpace(nL: Int8, nH: Int8) {
        self.writeData(NSData(bytes: [0x1D, 0x4C, nL, nH], length: 4))
    }
    
    func setAlignment(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x61, n], length: 3))
    }
    
    func setDotMatrix(mode: Int8, n1: Int8, n2: Int8, dotsContent: [Int8]) {
        self.writeData(NSData(bytes: [0x1B, 0x33, mode], length: 3))
        self.writeData(NSData(bytes: [n1,n2], length: 2))
        self.writeData(NSData(bytes: dotsContent, length: dotsContent.count))
    }
    
    func defineDownLoadBitmap(x: Int8, y: Int8, content: [Int8]) {
        self.writeData(NSData(bytes: [0x1D, 0x2A, x, y], length: 4))
        self.writeData(NSData(bytes: content, length: content.count))
    }
    func printDownLoadBitmap(n: Int8) {
        self.writeData(NSData(bytes: [0x1D, 0x2F, n], length: 3))
    }
    func printPreSavedBitMap(n: Int8) {
        self.writeData(NSData(bytes: [0x1C, 0x50, n], length: 3))
    }
    
    func printCurve(content: [Int8]) {
        if content.count > 4 {
            let count = content.count/4
            self.writeData(NSData(bytes: [0x1D, 0x27, count], length: 3))
            self.writeData(NSData(bytes: content, length: content.count))
        }
    }
    func printCurveText() {
    }
    
    func setUserCharactics(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x25, n], length: 3))
    }
    
    func setUserCharactics2(n: Int8) {
        self.writeData(NSData(bytes: [0x1B, 0x3f, n], length: 3))
    }
    
    func defineUserCharactics() {
    }
    
    func enterHANZIMode() {
        self.writeData(NSData(bytes: [0x1C, 0x26], length: 2))
    }
    
    func exitHANZIMode() {
        self.writeData(NSData(bytes: [0x1C, 0x2E], length: 2))
    }
    
    func defineUserHANZI(nL: Int8, nH: Int8, content: [Int8]) {
        self.writeData(NSData(bytes: [0x1C, 0x32], length: 2))
        self.writeData(NSData(bytes: [nL,nH], length: 2))
        self.writeData(NSData(bytes: content, length: content.count))
    }
    
    func writeData(data: NSData) {
        if self.setUp() {
            self.currentConnect?.writeValue(data, forCharacteristic: self.printCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }
    
    
    
    func setUp() -> Bool {
        if nil == self.currentConnect || self.printCharacteristic == nil {
            if let connect = BlueToothManager.shareInstance().currentConnect {
                self.currentConnect = connect
                if connect.state == CBPeripheralState.Connected {
                    for ser in connect.services {
                        if let service = ser as? CBService {
                            if service.characteristics != nil && service.characteristics.count > 0  {
                                for cha in service.characteristics {
                                    if let characteristic = cha as? CBCharacteristic {
                                        if characteristic.UUID.UUIDString == print_service_uuid || service.UUID.UUIDString == print_service_uuid {
                                            self.printCharacteristic = characteristic
                                            return true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
        return true
    }
    func printCode(str: String) {
        if self.setUp() {
            self.writeData(NSData(bytes:[0x1d] , length: 1))
            self.writeData(NSData(bytes:[0x68] , length: 1))
            self.writeData(NSData(bytes:[120] , length: 1))
            self.writeData(NSData(bytes:[0x1d] , length: 1))
            self.writeData(NSData(bytes:[0x48] , length: 1))
            self.writeData(NSData(bytes:[0x01] , length: 1))
            self.writeData(NSData(bytes:[0x1d] , length: 1))
            self.writeData(NSData(bytes:[0x6B] , length: 1))
            self.writeData(NSData(bytes:[0x02] , length: 1))
            self.writeData(NSString(string: "091955826335").dataUsingEncoding(NSUTF8StringEncoding)!)
            self.writeData(NSData(bytes:[0x00] , length: 1))
        }
    }
}