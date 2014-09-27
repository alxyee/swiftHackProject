//
//  ViewController.swift
//  Swift Hacks
//
//  Created by Isaac Rosenberg on 9/27/14.
//  Copyright (c) 2014 irosenb. All rights reserved.
//
import Darwin
import UIKit

class ViewController: UIViewController, BLEDelegate {
    lazy var ble = BLE()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("loaded");
        
        //setup BLE
        ble.controlSetup()
        ble.delegate=self
        println(ble.CM.state.toRaw())
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBOutlet weak var connectButton: UIButton!
    @IBAction func connectButtonPressed(sender: UIButton) {
        println("pressed")
        
        //Check if there are active peripherals. If there are then disconnect
        if((ble.activePeripheral) != nil){
            if(ble.activePeripheral.state == CBPeripheralState.Connected)
            {
                ble.CM.cancelPeripheralConnection(ble.activePeripheral)
                println("connected");
                return
            }
        }
        
        if((ble.peripherals) != nil){
            ble.peripherals = nil;
        }
        
        //Scan for BLE peripherals
        ble.findBLEPeripherals(2);
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "connectionTimer:", userInfo: nil, repeats: false)
    }
    
    func connectionTimer(timer:NSTimer){
        if (ble.peripherals.count > 0)
        {
            ble.connectPeripheral(ble.peripherals.objectAtIndex(0) as CBPeripheral)
        }
    }
    
    func bleDidDisconnect(){
        println("->Disconnected")
    }
    
    func bleDidConnect() {
        println("->Connected")
        
        //send reset
        var data = NSData(bytes: [0x04, 0x00, 0x00] as [Byte], length: 3)
        ble.write(data)
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int) {
        println("bleDidReceiveData")
        
        // parse data, all commands are in 2 bytes
        for var index = 0; index < length; index+=3{
            
            
           // println(data[index])
            //println(data[index+1])
            //println(data[index+2])
            var gX=((3.3*(Float(data[0]))/255)-1.65)/0.8
            var gY=((3.3*(Float(data[1]))/255)-1.65)/0.8
            var gZ=((3.3*(Float(data[2]))/255)-1.65)/0.8
            
            var R = sqrt(pow(gX, 2) + pow(gY, 2) + pow(gZ,2))
            
            var thetaX=acos(gX/R)
            var thetaY=acos(gY/R)
            var thetaZ=acos(gZ/R)
            
            println(thetaX)
            println(thetaY)
            println(thetaZ)
            
            
        }
    }
}


