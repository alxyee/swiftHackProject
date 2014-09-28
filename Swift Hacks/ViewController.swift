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
    lazy var baselineAdder = 0
    lazy var exertionAdder = Float()
    lazy var realTimeExertion=Float()
    lazy var baselineFlag = 0
    lazy var firstThirty = 0
    
    
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
        //println("bleDidReceiveData")
        
        // parse data, all commands are in 2 bytes
        for var index = 0; index < length; index+=3{
            
            
           // println(data[index])
            //println(data[index+1])
            //println(data[index+2])
            var gX=((3.3*(Float(data[0]))/255)-1.65)/0.8
            var gY=((3.3*(Float(data[1]))/255)-1.65)/0.8
            var gZ=((3.3*(Float(data[2]))/255)-1.65)/0.8
            
            var R = sqrt(pow(gX, 2) + pow(gY, 2) + pow(gZ,2))
            
            var thetaX=round(acos(gX/R)*100/3)
            var thetaY=round(acos(gY/R)*100/3)
            var thetaZ=round(acos(gZ/R)*100/3)
            if(firstThirty<300){
            if(thetaX>60){
                print("<- leaning left")
            }
            if(thetaX<40){
                print("-> leaning right")
            }
            if(thetaZ<55){
                print("V leaning backward")
            }
            if(thetaZ>65){
                print("^ leaning forward")
            }
                println()
            }
            firstThirty++
            //
            baselineAdder++
            realTimeExertion = realTimeExertion + R
            if(baselineFlag<1){
                exertionAdder = exertionAdder + R
               // println(exertionAdder)
            }
            if(baselineAdder>20){
                baselineFlag=1
                println(abs(round(realTimeExertion-exertionAdder)))
                realTimeExertion=0
                baselineAdder=0
            }

            //println(thetaX)
            //println(thetaY)
            //println(thetaZ)
            
            
        }
    }
}


