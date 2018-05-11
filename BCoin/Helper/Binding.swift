//
//  Binding.swift
//  BCoin
//
//  Created by Navneet Singh on 04/05/18.
//  Copyright © 2018 Navneet. All rights reserved.
//
import WatchKit
import Foundation
//Two Phase Binding
class Binding<T>{
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    var value: T{
        didSet{
            listener?(value)
        }
    }
    init(_ value : T) {
        self.value = value
    }
    func bind(listener: @escaping Listener){
        self.listener = listener
        listener(value)
        
    }
}
