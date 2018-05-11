//
//  InterfaceController.swift
//  BCoinWatch Extension
//
//  Created by Navneet Singh on 06/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    //MAR: IBOutlets
    @IBOutlet var euroBtn: WKInterfaceButton!
    @IBOutlet var dollarBtn: WKInterfaceButton!
    @IBOutlet var dateLbl: WKInterfaceLabel!
    
    @IBOutlet var rateLbl: WKInterfaceLabel!
    @IBOutlet var poundBtn: WKInterfaceButton!
    
    private  var viewModal : BCViewModel = BCViewModel()
    private var session = WCSession.default
    private  var messages = [String: String]() {
        didSet {
            DispatchQueue.main.async  { [weak self] in
                self?.updateMessages()
            }
        }
    }
    //MARK: Life CYCLe
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let delegate = (WKExtension.shared().delegate as! ExtensionDelegate).session {
        session = delegate
        session.delegate = self
        session.activate()
        NSLog("%@", "Paired Watch: \(session.isReachable), Watch App Installed:")
        }
        loadUIFromBindingResponse()
        // Configure interface objects here.
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

    }
    override func willDisappear() {
       
        super.willDisappear()
     }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        
        super.didDeactivate()
      }
    //MARK: Navigation
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == SegueIdentifiers.last2Weeks.rawValue{
            return (viewModal.previousDaysRateCoin?.value,viewModal.currencyCode.value)
        }
        return nil
    }
    
    //MARK: Load UI Methonds
    func loadUIFromBindingResponse(){
        viewModal.currencyCode.bind { (code) in
            
            self.updateCurrencyCodeBtns(code)
        }
        
        viewModal.currentRateCoin?.bind { (coinData) in
            
            guard let coin = coinData?.0,let lastUpdateTime = coinData?.1 else{
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.dateLbl.setText(lastUpdateTime)
                self.rateLbl.setText(coin.code.rawValue.convertCurrencyCodeToSymbol()! + coin.rate)
            }
            self.notigyForTodayData()
            
        }
    }
    
    //MARK: IBActions
  
    @IBAction func euroBtnAction() {
        viewModal.changeCurrencyCode(CurrencyCodes.EUR.rawValue)
        
            self.notifyCurrencyChange(CurrencyCodes.EUR.rawValue)
      }
    @IBAction func dollarBtnAction() {
        viewModal.changeCurrencyCode(CurrencyCodes.USD.rawValue)
    
            self.notifyCurrencyChange(CurrencyCodes.USD.rawValue)
    }
    @IBAction func poundBtnAction() {
        viewModal.changeCurrencyCode(CurrencyCodes.GBP.rawValue)
                    self.notifyCurrencyChange(CurrencyCodes.GBP.rawValue)
    }
    // Change Button colors
    func updateCurrencyCodeBtns(_ code: CurrencyCodes){
        DispatchQueue.main.async { [unowned self] in
            
            let coded = code
            switch  coded  {
            case .EUR:
                self.euroBtn.setBackgroundColor(UIColor().bCoinOrangeColor)
                self.dollarBtn.setBackgroundColor(.white)
                self.poundBtn.setBackgroundColor(.white)
                
                self.euroBtn.changeTitlColorToWhite(coded.rawValue)
                self.dollarBtn.changeTitlColorToOrange(CurrencyCodes.USD.rawValue)
                self.poundBtn.changeTitlColorToOrange(CurrencyCodes.GBP.rawValue)
            case .USD:
                self.dollarBtn.setBackgroundColor(UIColor().bCoinOrangeColor)
                self.euroBtn.setBackgroundColor(.white)
                self.poundBtn.setBackgroundColor(.white)
                self.dollarBtn.changeTitlColorToWhite(coded.rawValue)
                self.euroBtn.changeTitlColorToOrange(CurrencyCodes.EUR.rawValue)
                self.poundBtn.changeTitlColorToOrange(CurrencyCodes.GBP.rawValue)
                
            case .GBP:
                self.poundBtn.setBackgroundColor(UIColor().bCoinOrangeColor)
                self.dollarBtn.setBackgroundColor(.white)
                self.euroBtn.setBackgroundColor(.white)
                
                self.poundBtn.changeTitlColorToWhite(coded.rawValue)
                self.dollarBtn.changeTitlColorToOrange(CurrencyCodes.USD.rawValue)
                self.euroBtn.changeTitlColorToOrange(CurrencyCodes.EUR.rawValue)
                }
            
        }}
}
// Handle sessions
extension InterfaceController{
   
    
    func updateMessages() {
        for  messge in messages {
            let msg = (messge.key, messge.value)
            
            if  ConnectivityMessageIdentifiers.currency.rawValue == msg.0 {
                self.becomeCurrentPage()
                updateCurrencyCodeBtns(CurrencyCodes(rawValue: msg.1)!)
            }
            else   if  ConnectivityMessageIdentifiers.date.rawValue == msg.0 {
                self.becomeCurrentPage()
                dateLbl.setText(msg.1)
            }
            else   if  ConnectivityMessageIdentifiers.todayRate.rawValue == msg.0 {
                rateLbl.setText(msg.1)
            }
            else if ConnectivityMessageIdentifiers.lastTwoWeeks.rawValue == msg.0{
                
                self.pushController(withName: SegueIdentifiers.last2Weeks.rawValue, context: (viewModal.previousDaysRateCoin?.value,viewModal.currencyCode.value))
            }
        }
    }
    private func sendMessageForUpdate(_ key: ConnectivityMessageIdentifiers, _ value: String){
        if self.session.isReachable{
            
        session.sendMessage([key.rawValue : value], replyHandler: nil) { (error) in
            NSLog("%@", "Error sending message: \(error)")
        }
        }
    }
    func notifyCurrencyChange(_ code: String){
        print(code)
        sendMessageForUpdate( ConnectivityMessageIdentifiers.currency,code )
        notigyForTodayData()
        notigyForOldData()
        
        
    }
    func notigyForTodayData(){
        if  let data =    viewModal.currentRateCoin?.value {
            print(data.1)
            print(ConnectivityMessageIdentifiers.todayRate, (data.0.code.rawValue.convertCurrencyCodeToSymbol()!) + (data.0.rate))
            sendMessageForUpdate( ConnectivityMessageIdentifiers.date,(data.1) )
            sendMessageForUpdate( ConnectivityMessageIdentifiers.todayRate, (data.0.code.rawValue.convertCurrencyCodeToSymbol()!) + (data.0.rate)  )
        
        }
    }
    func notigyForOldData(){
        sendMessageForUpdate( ConnectivityMessageIdentifiers.lastTwoWeeks,"")
    }
    func notifyTableInteraction(){
        
    }
    
}

extension InterfaceController : WCSessionDelegate{
        func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NotificationCenter.default.post(name: .msgCame, object: nil)
            self.messages = (message as! [String : String])
            
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Yes")
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
   
    
    

}
