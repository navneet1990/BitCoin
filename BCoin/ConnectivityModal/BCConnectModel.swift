//
//  BCConnectModel.swift
//  BCoin
//
//  Created by Navneet Singh on 06/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class BCConnectModel : NSObject{
    
    private var connectHandler : ConnectivityHandler?
    var updatePrice : Binding<String?>? = Binding(nil)
    var updateDate: Binding<String?>? = Binding(nil)
    var updateSegment: Binding<Int?>? = Binding(nil)
        var updateTable: Binding<Bool?>? = Binding(nil)
    
    override init() {
        super.init()
        self.connectHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        self.connectHandler?.addObserver(self, forKeyPath: "messages", options: [], context: nil)
        
    }
    deinit {
         connectHandler?.removeObserver(self, forKeyPath: "messages")
    }
}
//MARK: Handle sessions for watch interaction
extension BCConnectModel{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "messages" {
            OperationQueue.main.addOperation {
                self.updateMessages()
            }
        }
    }
    private   func updateMessages() {
        for  messge in (connectHandler!.messages) {
            let msg = (messge.key, messge.value)
            
            if  ConnectivityMessageIdentifiers.currency.rawValue == msg.0 {
                updateSegment?.value = (CurrencyCodes(rawValue: msg.1)?.hashValue)!
            }
            else   if  ConnectivityMessageIdentifiers.date.rawValue == msg.0 {
                updateDate?.value = msg.1
                
            }
            else   if  ConnectivityMessageIdentifiers.todayRate.rawValue == msg.0 {
                updatePrice?.value  = msg.1
            }
            else   if  ConnectivityMessageIdentifiers.lastTwoWeeks.rawValue == msg.0 {
                updateTable?.value  = true
            }
        }
    }
    private func sendMessageForUpdate(_ key: ConnectivityMessageIdentifiers, _ value: String){
        guard  connectHandler != nil && (connectHandler?.session.isReachable)! else {
            return
        }
        connectHandler?.session.sendMessage([key.rawValue : value], replyHandler: nil) { (error) in
            NSLog("%@", "Error sending message: \(error)")
    }
    }
    func notifyCurrencyChange(_ code: String){
        sendMessageForUpdate( ConnectivityMessageIdentifiers.currency,code )
    }
    func notigyForTodayData(_ date: String, _ rate:String, _ code: CurrencyCodes){
        sendMessageForUpdate( ConnectivityMessageIdentifiers.date, date )
        sendMessageForUpdate( ConnectivityMessageIdentifiers.todayRate, code.rawValue.convertCurrencyCodeToSymbol()! + rate  )
    }
    func notigyForOldData(){
        sendMessageForUpdate( ConnectivityMessageIdentifiers.lastTwoWeeks,"\(2)")
    }
    func notifyTableInteraction( forIndex: Int){
        sendMessageForUpdate(ConnectivityMessageIdentifiers.lastTwoWeeks, "\(forIndex)")
    }
    
}


