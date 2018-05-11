
 //  BCoin
 //
 //  Created by Navneet Singh on 07/05/18.
 //  Copyright © 2018 Navneet. All rights reserved.
 //

import Foundation
import WatchConnectivity
import WatchKit
class ConnectivityHandler : NSObject, WCSessionDelegate {

    var session = WCSession.default
    @objc dynamic var messages = [String: String]()

    override init() {
        super.init()
       session.delegate = self
        session.activate()
        NSLog("%@", "Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("%@", "sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        NSLog("%@", "sessionDidDeactivate: \(session)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        NSLog("%@", "sessionWatchStateDidChange: \(session)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("didReceiveMessage: %@", message)
        if message["request"] as? String == "date" {
            replyHandler(["date" : "\(Date())"])
        }
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let iPhoneContext = session.receivedApplicationContext as? [String : Bool] {
            
            if  iPhoneContext["modelObject"] == true {
                print("Yes")
                
            } else {
                print("Something wrong")
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.messages = (message as! [String : String] )
    }

    
}

