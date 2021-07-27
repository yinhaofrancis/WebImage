//
//  Sql.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3


public class Condition{
    var relate:String
    var left:ConditionKey
    var right:ConditionKey
    var next:Condition?
    var nextOp:String?
    public init(l:ConditionKey,relate:String,r:ConditionKey){
        self.left = l
        self.right = r
        self.relate = relate
    }
    public static func || (lc:Condition,rc:Condition)->Condition{
        var c = lc
        while c.next != nil {
            c = lc.next!
        }
        c.next = rc
        rc.nextOp = "OR"
        return lc
    }
    public static func && (lc:Condition,rc:Condition)->Condition{
        var c = lc
        while c.next != nil {
            c = lc.next!
        }
        c.next = rc
        rc.nextOp = "AND"
        return lc
    }
    public static func glob(lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " GLOB ", r: rk)
    }
    public static func like(lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " LIKE ", r: rk)
    }
    public static func regexp(lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " REGEXP ", r: rk)
    }
    public static func match(lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " MATCH ", r: rk)
    }
    public static func exist(lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " EXIST ", r: rk)
    }
    public static func between(lk:ConditionKey,s:ConditionKey,e:ConditionKey)->Condition{
        Condition(l: lk, relate: " BETWEEN ", r: ConditionKey(key: s.key + " and " + e.key))
    }
    public static func notBetween(lk:ConditionKey,s:ConditionKey,e:ConditionKey)->Condition{
        Condition(l: lk, relate: " NOT BETWEEN ", r: ConditionKey(key: s.key + " and " + e.key))
    }
    public static func isNull(lk:ConditionKey)->Condition{
        Condition(l: lk, relate: " IS Null ", r: ConditionKey(key:""))
    }
    public static func isNotNull(lk:ConditionKey)->Condition{
        Condition(l: lk, relate: " IS Not Null ", r: ConditionKey(key:""))
    }
    public var conditionCode:String{
        if let n = self.next , let o = n.nextOp{
            return "\(left.key)\(self.relate)\(right.key) \(o) \(n.conditionCode)".replacingOccurrences(of: "\\", with: "")
        }else{
            return "\(left.key)\(self.relate)\(right.key)".replacingOccurrences(of: "\\", with: "")
        }
    }
}

infix operator <> : ComparisonPrecedence



public struct ConditionKey:ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    var key:String
    public init(key:String) {
        self.key = key
    }    
    public init(stringLiteral string:String) {
        self.key = "\(string)"
    }
    public static func == (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " = ", r: rk)
    }
    public static func >= (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " >= ", r: rk)
    }
    public static func <= (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " <= ", r: rk)
    }
    public static func < (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " < ", r: rk)
    }
    public static func > (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " > ", r: rk)
    }
    public static func + (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " + ", r: rk)
    }
    public static func - (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " - ", r: rk)
    }
    public static func * (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " * ", r: rk)
    }
    public static func / (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " / ", r: rk)
    }
    public static func % (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: " % ", r: rk)
    }
}
