//
//  Fetch.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/26.
//

import Foundation
import SQLite3
public enum Order {
    case asc(String)
    case desc(String)
    public var code:String{
        switch self {
        
        case let .asc(a):
            return "`\(a)` ASC"
        case let .desc(a):
            return "`\(a)` DESC"
        }
    }
}
public struct Page{
    public let offset:Int32
    public let limit:Int32
}
public enum FetchKey{
    case count(String)
    case max(String)
    case min(String)
    case all
    
    public var keyString:String{
        switch self{
     
        case let .count(c):
            return "count(\(c))"
        case let .max(c):
            return "*,max(\(c))"
        case let .min(c):
            return "*,min(\(c))"
        case .all:
            return "*"
        }
    }
}
public class FetchRequest<T:SQLCode>{
    public var sql:String
    public var keyMap:[String:OriginValue] = [:]
    public init(table:T.Type,key:FetchKey = .all,condition:Condition? = nil ,page:Page? = nil,order:[Order] = []){
        self.sql = "select \(key.keyString) from `\(T.tableName)`" + ((condition?.conditionCode.count ?? 0) > 0 ? (" where " + condition!.conditionCode) : "") + (order.count > 0 ? " order by" + order.map({$0.code}).joined(separator: ",") : "") + (page == nil ? "" : " LIMIT \(page!.limit) OFFSET \(page!.offset)")
    }
    public init(obj:T,key:FetchKey = .all ,page:Page? = nil,order:[Order] = []){
        self.sql = "select \(key.keyString) from `\(T.tableName)` where " + obj.primaryCondition + (order.count > 0 ? " order by" + order.map({$0.code}).joined(separator: ",") : "") + (page == nil ? "" : " LIMIT \(page!.limit) OFFSET \(page!.offset)")
    }
    @discardableResult
    public func loadKeyMap(map:[String:OriginValue])->FetchRequest{
        self.keyMap = map
        return self
    }
    func doSelectBind(result:Database.ResultSet){
        for i in keyMap {
            if i.value is Int{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Int)
            }
            if i.value is Int32{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Int32)
            }
            if i.value is Int64{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Int64)
            }
            if i.value is Int{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Int)
            }
            if i.value is Double{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Double)
            }
            if i.value is Float{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Float)
            }
            if i.value is Data{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }
            if i.value is String{
                result.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }
        }
    }
    static public func readData(resultset:Database.ResultSet) throws ->[T]{
        var result:[T] = []
        while try resultset.step() {
            result.append(self.load(result: resultset))
        }
        resultset.close()
        return result
    }
    static public func load(result:Database.ResultSet)->T{
        var sql = T.init()
        let nkm = sql.fullKey.reduce(into: [:]) { r, i in
            r[i.1.keyName ?? i.0] = i
        }
        let c = result.columnCount
        for i in 0 ..< c{
            
            guard let sqlv = nkm[result.columnName(index: i)]?.1 else { continue }
            let vt = sqlv.value
            guard let kp = sqlv.path else { continue }
            
            if vt is Int || vt is Optional<Int>{
                let colume = result.column(index:Int32(i), type: Int.self)
                let v = colume.value()

                if let keyPath = kp as? WritableKeyPath<T,Int?>{
                    
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
                }
                if let keyPath = kp as? WritableKeyPath<T,Int>{
                    sql[keyPath: keyPath] = v
                }
            }
            if vt is Int32 || vt is Optional<Int32>{
                let colume = result.column(index:Int32(i), type: Int32.self)
                let v = colume.value()

                if let keyPath = kp as? WritableKeyPath<T,Int32?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
                }
                if let keyPath = kp as? WritableKeyPath<T,Int32>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Int64 || vt is Optional<Int64>{
                
                let colume = result.column(index:Int32(i), type: Int64.self)
                let v = colume.value()
     
                if let keyPath = kp as? WritableKeyPath<T,Int64?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
          
                }
                if let keyPath = kp as? WritableKeyPath<T,Int64>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Data || vt is Optional<Data> {
                let colume = result.column(index:Int32(i), type: Data.self)
                let v = colume.value()
   
                if let keyPath = kp as? ReferenceWritableKeyPath<T,Data?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
                }
                if let keyPath = kp as? ReferenceWritableKeyPath<T,Data>{
                    sql[keyPath: keyPath] = v

                }
                if let keyPath = kp as? WritableKeyPath<T,Data?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
     
                }
                if let keyPath = kp as? WritableKeyPath<T,Data>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is String || vt is Optional<String>{
                let colume = result.column(index:Int32(i), type: String.self)
                let v = colume.value()

                if let keyPath = kp as? ReferenceWritableKeyPath<T,String?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v

                }
                if let keyPath = kp as? ReferenceWritableKeyPath<T,String>{
                    sql[keyPath: keyPath] = v
                }
                if let keyPath = kp as? WritableKeyPath<T,String?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v

                }
                if let keyPath = kp as? WritableKeyPath<T,String>{
                    sql[keyPath: keyPath] = v
                }
            }

            if vt is Double || vt is Optional<Double>{
                let colume = result.column(index:Int32(i), type: Double.self)
                let v = colume.value()

                if let keyPath = kp as? WritableKeyPath<T,Double?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v
  
                }
                if let keyPath = kp as? WritableKeyPath<T,Double>{
                    sql[keyPath: keyPath] = v
           
                }
            }
            if vt is Float || vt is Optional<Float>{
                let colume = result.column(index:Int32(i), type: Float.self)
                let v = colume.value()

                if let keyPath = kp as? WritableKeyPath<T,Float?>{
                    sql[keyPath: keyPath] = colume.type == .Null ? nil : v

                }
                if let keyPath = kp as? WritableKeyPath<T,Float>{
                    sql[keyPath: keyPath] = v

                }
            }
        }
        return sql
    }
}
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
