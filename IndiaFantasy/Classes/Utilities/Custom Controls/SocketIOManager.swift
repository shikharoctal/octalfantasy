//
//  SocketManager.swift
//  Drafters
//
//  Created by Aryan tak on 11/06/18.
//  Copyright © 2018 kipl. All rights reserved.
//

import UIKit
import SocketIO

var ActiveDraft_Reconnect:Int = 1

@objc protocol SocketHandlerDelegate {
    @objc optional func handleDraftSocketRoom(data:[Any], ack:SocketAckEmitter)
    @objc optional func handleActiveDraftSocketListners(data:[Any], ack:SocketAckEmitter)
}

class SocketIOManager: NSObject {
    
    public static var instance: SocketIOManager!
    public var socket: SocketIOClient!
    var manager: SocketManager!
    weak var delegateToHandleSocketConnection:SocketHandlerDelegate! = nil
    
    var isMessageSent = true
    var messageDict:[String:Any]? = nil
    
    //initializer of shared object of socket(SocketIOManager) only once in application ...
    internal static var sharedInstance: SocketIOManager {
        if(instance == nil) {
            instance = SocketIOManager()
        }
        return instance;
    }
    
    //MARK:- Initialization of NSObject super class
    override init() {
        super.init()
    }
    
    func reconnect() {
        if socket != nil {
            if socket.status == .notConnected || socket.status == .disconnected {
                socket.connect()
            }
            debugPrint("****** Socket Staus = \(socket.status) *******")
        }
    }
    
    func closeConnection() {
        guard socket != nil else { return }
        socket.disconnect()
    }
    
    //MARK:- Destroy from every where in application
    static func destroy () {
        if(instance != nil) {
            if( instance.socket != nil) {
                instance.socket.removeAllHandlers()
                instance.socket.disconnect()
                ActiveDraft_Reconnect = 1
                print("Socket Disconnect & removeAllHandlers")
            }
            instance = nil
            isSocketConnected = "Disconnect"
           // self.showSocketStatus()
        }
    }
    
    //MARK:- connect /disconnect
    func establishConnection() {
        if manager != nil{
            manager = nil
        }
        manager  = SocketManager(socketURL: URL(string: URLMethods.SocketDomainURL)!, config: [.log(false), .compress, .reconnects(true), .reconnectWait(1)])
        socket = manager.defaultSocket
        socket.connect()
        addHandler()
    }
    

    
    //MARK:- Socket Handler
    func addHandler() {
        delegateToHandleSocketConnection = UIApplication.getTopViewController() as? SocketHandlerDelegate
        socket.on(clientEvent: .statusChange) { (data, ack) in
            print("\n =========== SOCKET ========== \n status changed \n ============================= \n")
            
            let socketConnectionStatus = self.socket.status
             
            switch socketConnectionStatus {
            case SocketIOStatus.connected:
                isSocketConnected = "Connect"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSocketConnected), object: nil, userInfo: nil)
                print("socket connected")
            case SocketIOStatus.connecting:
                print("socket connecting")
                isSocketConnected = "Connecting"
            case SocketIOStatus.disconnected:
                print("socket disconnected")
                isSocketConnected = "Disconnected"
            case SocketIOStatus.notConnected:
                print("socket not connected")
                isSocketConnected = "notConnected"
                SocketIOManager.destroy()
                SocketIOManager.sharedInstance.socket.removeAllHandlers()
                Constants.kAppDelegate.startSocketConnection()
            }
            
        }
        
        //MARK:- Listeners
        
        //Check
        socket.on(clientEvent: .reconnectAttempt ) { data, ack in
            print("\n reconnectAttempt \n")
            ActiveDraft_Reconnect = 1
            isSocketConnected = "reconnectAttempt"
        }
        
        socket.on(clientEvent: .disconnect ) { data, ack in
            print("\n Disconnect \n")
            isSocketConnected = "Disconnect"
            ActiveDraft_Reconnect = 1
            Constants.kAppDelegate.startSocketConnection()
        }
        
        //Reconnect Success
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print("\n reconnect \n")
            if SocketIOManager.instance.socket.status != .connected {
                isSocketReconnected = true
                ActiveDraft_Reconnect = 1
                isSocketConnected = "Reconnect"
                //SocketIOManager.destroy()
                SocketIOManager.sharedInstance.socket.removeAllHandlers()
                SocketIOManager.sharedInstance.establishConnection()
            }
        }
        
        socket.on(clientEvent: .connect) { data, ack in
           // print("\n =========== SOCKET ========== \n Socket Connected \n ============================= \n")
            isSocketConnected = "Connect"
            //self.draftSocketEmit()
            self.initSocketEvents()
        
            //** used to rejoin draft room
            if(self.delegateToHandleSocketConnection !=  nil){
                self.delegateToHandleSocketConnection.handleDraftSocketRoom?(data: data, ack: ack)
            }
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("\n error \n \(data)")
            isSocketConnected = "Error"
            ActiveDraft_Reconnect = 1
            SocketIOManager.sharedInstance.socket.connect()
        }
    }
    
    func initSocketEvents(){
        socket.on(SocketEventNames.KSocket_EVENT_REFRESH, callback: { data, ack in
            print("Called - Refresh")
            if(self.delegateToHandleSocketConnection !=  nil){
                self.delegateToHandleSocketConnection.handleActiveDraftSocketListners?(data: data, ack: ack)
            }
        })
        
        socket.on(SocketEventNames.KSocket_EVENT_START_GAME, callback: { data, ack in
            print("Called - EVENT_START_GAME")
            if(self.delegateToHandleSocketConnection !=  nil){
                self.delegateToHandleSocketConnection.handleActiveDraftSocketListners?(data: data, ack: ack)
            }
        })
        
        socket.on(SocketEventNames.KSocket_EVENT_LIVE_SCORE, callback: { data, ack in
            print("Called - EVENT_LIVE_SCORE")
            if(self.delegateToHandleSocketConnection !=  nil){
                self.delegateToHandleSocketConnection.handleActiveDraftSocketListners?(data: data, ack: ack)
            }
        })
        
        socket.on(SocketEventNames.KSocket_EVENT_PAYMENT_SUCCESS, callback: { data, ack in
            print("Called - KSocket_EVENT_PAYMENT_SUCCESS")
            if(self.delegateToHandleSocketConnection !=  nil){
                self.delegateToHandleSocketConnection.handleActiveDraftSocketListners?(data: data, ack: ack)
            }
        })
        
        socket.on(SocketEventNames.KSocket_EVENT_DEBUFF, callback: { data, ack in
            print("Called - KSocket_EVENT_DEBUFF")
            GDP.showDebuffAppliedPopUp(data: data)
        })
        
        socket.on(SocketEventNames.KSocket_EVENT_GIFT_BOOSTER, callback: { data, ack in
            print("Called - KSocket_EVENT_GIFT_BOOSTER")
            GDP.showBoosterGiftPopUp(data: data)
        })
    }
    
}
