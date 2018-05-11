//
//  WExtensions.swift
//  BCoinWatch Extension
//
//  Created by Navneet Singh on 06/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import Foundation
import WatchKit
//Color extension
extension UIColor{
    
    var bCoinOrangeColor : UIColor {
        return UIColor.init(red: 217/255, green: 63/255, blue: 31/255, alpha: 1.0)
    }
}
extension WKInterfaceButton{
    
    func changeTitlColorToWhite(_ title: String){
        let titleColor = [NSAttributedStringKey.foregroundColor : UIColor.white ]
        let attString = NSMutableAttributedString.init(string: title, attributes: titleColor)
        self.setAttributedTitle(attString)
    }
    func changeTitlColorToOrange(_ title: String){
        let titleColor = [ NSAttributedStringKey.foregroundColor: UIColor().bCoinOrangeColor ]
        let attString = NSMutableAttributedString.init(string: title, attributes: titleColor)
        self.setAttributedTitle(attString)
    }
}

extension Notification.Name {
    static let msgCame = Notification.Name("MessgeCame")

}
