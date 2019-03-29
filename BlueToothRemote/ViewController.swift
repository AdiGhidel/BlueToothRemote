//
//  ViewController.swift
//  BlueToothRemote
//
//  Created by Ghidel, Marius-adrian on 2/25/19.
//  Copyright © 2019 Ghidel, Marius-adrian. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    //Vars
    var central: CBCentralManager?
    var peripheralR: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    var writeType: CBCharacteristicWriteType?
    var connected = false;
    var debug = true;
    
    /// UUID of the service to look for.
    var serviceUUID = CBUUID(string: "FFE0")
    
    /// UUID of the characteristic to look for.
    var characteristicUUID = CBUUID(string: "FFE1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //1 create a central manager
        central = CBCentralManager(delegate: self, queue: nil)
    }
    

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            //2 if on scan for device
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            let alert = UIAlertController(title: "Bluetooth isn't working", message: "Make sure your Bluetooth is on", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    //3 if discovered connect
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name!)
        
        peripheralR = peripheral
        peripheralR?.delegate = self
    }
    //5 did connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if debug {
            print("connected")
            print(peripheral)
        }
        connected = true
        peripheral.discoverServices([serviceUUID])
        connectedOutlet.alpha = 1
    }
    //6 did discover service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    //7 did discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print(characteristic)
            // keep a reference to this characteristic so we can write to it
            writeCharacteristic = characteristic

            // find out writeType
            writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let alert = UIAlertController(title: "Stella ran away", message: "Porky stole the bluetooth", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        connected = false
        connectedOutlet.alpha = 0;
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        let alert = UIAlertController(title: "Could not connect", message: "Stella should reset the device", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        connected = false
    }

    //Commands
    @IBAction func forward(_ sender: Any) {
        sendMessageToDevice("forward");
    }
    @IBAction func stop(_ sender: Any) {
        sendMessageToDevice("stop");
    }
    @IBAction func back(_ sender: Any) {
        sendMessageToDevice("back");
    }
    @IBAction func left90(_ sender: Any) {
        sendMessageToDevice("left90");
    }
    @IBAction func right90(_ sender: Any) {
        sendMessageToDevice("right90");
    }
    @IBAction func spin(_ sender: Any) {
        sendMessageToDevice("spin");
    }
    @IBAction func left(_ sender: Any) {
        sendMessageToDevice("left");
    }
    @IBAction func right(_ sender: Any) {
        sendMessageToDevice("right");
    }

    @IBAction func speed(_ sender: Any) {
        sendMessageToDevice("\(speedOutlet!.value)");
    }
    @IBOutlet var speedOutlet: UISlider!
    //4 manually connect
    @IBAction func connectToDevice(_ sender: Any) {
        if debug {
            print("press connect")
        }
        if let peripheralR = peripheralR {
            if debug {
                print("if \(peripheralR)")
            }
            print("trying to connect")
            central?.connect(peripheralR)
        } else {
            let alert = UIAlertController(title: "Device not found", message: "Stella should turn on the device", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet var connectedOutlet: UIButton!
    //Aux func
    func sendMessageToDevice(_ message: String) {
        if connected == true {
            if let data = message.data(using: String.Encoding.utf8) {
                print(data)
                peripheralR!.writeValue(data, for: writeCharacteristic!, type: writeType!)
            }
        }
    }
}
extension UIView {
    func roundCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
    
}
