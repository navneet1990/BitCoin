//
//  NetworkHandler.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//

import UIKit
import WatchKit

class NetworkHandler {
    private static let API = "https://api.coindesk.com/v1/bpi/"
    class func callWebServicefor(_ parmString: String, completion : @escaping(Response)->Void){
        
        guard let url = URL(string: API + parmString) else{
            completion(Response.invalid)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let responseData = data , error == nil else{
                return  completion(Response.failure(error!))
            }
            completion(Response.success(responseData))
            }.resume()
    }
    
    
}
