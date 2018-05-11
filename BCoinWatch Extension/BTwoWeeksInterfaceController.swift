//
//  BTwoWeeksInterfaceController.swift
//  BCoinWatch Extension
//
//  Created by Navneet Singh on 05/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import WatchKit
import Foundation


class BTwoWeeksInterfaceController: WKInterfaceController {
    //MARK: IBOutlet
    @IBOutlet var coinsTable: WKInterfaceTable!
    //MARK: Variables
    var coins : Coins? {
        didSet{
            guard let rates = coins   else {
                return
            }
            coinsTable.setNumberOfRows(rates.list.count , withRowType: "oldRateCoin")
            for index in 0 ..< rates.list.count {
                guard let controller = coinsTable.rowController(at: index) as? TwoWeeksRowController else { return }
                let dict = rates.list
                let coinData = dict[rates.dates[index]]!
                controller.rateLbl.setText((code!.rawValue.convertCurrencyCodeToSymbol()!) + "\(String(describing: coinData))")
                controller.dateLbl.setText(rates.dates[index])
            }
        }
    }
    var code : CurrencyCodes? = nil
    //MARK: LifeCycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if let data = context as? (Coins,CurrencyCodes) {
            self.code = data.1
            self.coins = data.0
        }
        NotificationCenter.default.addObserver(self, selector: #selector(msgCameFromIphone(notification:)), name: .msgCame, object: nil)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        NotificationCenter.default.removeObserver(self)
    }
    @objc func msgCameFromIphone(notification: NSNotification) {
        DispatchQueue.main.async {[weak self] in

            self?.popToRootController()
            
        }
        }
}


