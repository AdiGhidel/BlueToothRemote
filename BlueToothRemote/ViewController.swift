//
//  ViewController.swift
//  BlueToothRemote
//
//  Created by Ghidel, Marius-adrian on 2/25/19.
//  Copyright © 2019 Ghidel, Marius-adrian. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate, BluetoothSerialDelegate {
    
    func serialDidChangeState() {
        <#code#>
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        <#code#>
    }
    
   
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral updated sth")
    }
    
    let debug = true
    var robotBT: CBPeripheral?
    var CBManager : CBCentralManager?
    var PFManager : CBPeripheralManager?
    
    /// UUID of the service to look for.
//    var serviceUUID = CBUUID(string: "FFE0")
//    /// UUID of the characteristic to look for.
//    var characteristicUUID = CBUUID(string: "FFE1")
//    /// Write characteristic
//    var writeType: CBCharacteristicWriteType = .withoutResponse
//    var characteristicBT: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CBManager = CBCentralManager(delegate: self, queue: nil)
        serial.delegate = self
    }
    //Bluetooth
    //CBCentralManager code
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let p = peripheral.name {
            if p == "SH-M08" {
                robotBT = peripheral
                print("periferal name \(peripheral.name ?? "")")
                print("periferal uuid \(peripheral.identifier.uuidString)")
                print("RSSI\(RSSI)")
                print("advertisment data \(advertisementData)")
                print("*****************")
            }
        }
    
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            let alert = UIAlertController(title: "Bluetooth isn't working", message: "Make sure your Bluetooth is on", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    //Commands
    @IBAction func forward(_ sender: Any) {
        let data: Data = "AAA".data(using: .utf8)!
//        let ch : CBCharacteristic
//        ch.value = "OxFFE1".data(using: .utf8)!
//        robotBT?.writeValue(data, ch, .withoutResponse)
    }
    @IBAction func stop(_ sender: Any) {
    }
    @IBAction func back(_ sender: Any) {
    }
    @IBAction func left90(_ sender: Any) {
    }
    @IBAction func right90(_ sender: Any) {
    }
    @IBAction func spin(_ sender: Any) {
    }
    @IBAction func speed(_ sender: Any) {
    }
    @IBOutlet var speedOutlet: UISlider!
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if debug {
            print("connected")
            print(peripheral)
            
        }
        peripheral.delegate = self as! CBPeripheralDelegate
        peripheral.discoverServices([serviceUUID])
        connectedOutlet.alpha = 1
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let alert = UIAlertController(title: "Could not connect", message: "Stella should reset the device", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func connectToDevice(_ sender: Any) {
        if debug {
            print("press connect")
        }
        if let robotBT = robotBT {
            if debug {
                print("if \(robotBT)")
            }
            CBManager?.connect(robotBT, options: nil)
        } else {
            let alert = UIAlertController(title: "Device not found", message: "Stella should turn on the device", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover the 0xFFE1 characteristic for all services (though there should only be one)
        print("discovering services")
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // check whether the characteristic we're looking for (0xFFE1) is present - just to be sure
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                // subscribe to this value (so we'll get notified when there is serial data for us..)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // keep a reference to this characteristic so we can write to it
                characteristicBT = characteristic
                
                // find out writeType
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
                print("ch: \(characteristic) wt: \(writeType)")
            }
        }
    }
    @IBOutlet var connectedOutlet: UIButton!
}

