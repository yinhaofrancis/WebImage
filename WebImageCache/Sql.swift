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
    public var conditionCode:String{
        if let n = self.next , let o = n.nextOp{
            return "\(left.key)\(self.relate)\(right.key) \(o) \(n.conditionCode)"
        }else{
            return "\(left.key)\(self.relate)\(right.key)"
        }
    }
}

infix operator <> : ComparisonPrecedence

public struct ConditionKey {
    var key:String
    public init(key:String) {
        self.key = key
    }
    public static func == (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: "=", r: rk)
    }
    public static func >= (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: ">=", r: rk)
    }
    public static func <= (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: "<=", r: rk)
    }
    public static func < (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: "<", r: rk)
    }
    public static func > (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: ">", r: rk)
    }
    public static func <> (lk:ConditionKey,rk:ConditionKey)->Condition{
        Condition(l: lk, relate: "<>", r: rk)
    }
}
