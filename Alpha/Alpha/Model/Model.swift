//
//  Model.swift
//  Alpha
//
//  Created by hao yin on 2021/8/31.
//

import Foundation


@propertyWrapper
public struct Col<T>{
    public var wrappedValue:T{
        get{
            self.property.get()
        }
        set{
            self.property.set(newValue)
        }
    }
    
    public init(wrappedValue:T){
        var w:T = wrappedValue
        self.property = (get:{
            return w
        },set:{ i in w = i})
    }
    
    private var property:(get:()->T,set:(T)->Void)
}



