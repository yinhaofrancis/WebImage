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
public class FetchRequest<T:SQLCode>{
    public var sql:String
    public var keyMap:[String:SqlType] = [:]
    public init(table:T.Type,condition:Condition? = nil ,page:Page? = nil,order:[Order] = []){
        self.sql = "select * from `\(T.tableName)`" + ((condition?.conditionCode.count ?? 0) > 0 ? ("where" + condition!.conditionCode) : "") + (order.count > 0 ? "order by" + order.map({$0.code}).joined(separator: ",") : "") + (page == nil ? "" : "OFFSET \(page!.offset) LIMIT \(page!.limit)")
    }
    public func loadKeyMap(map:[String:SqlType]){
        self.keyMap = map
    }
    func doSelectBind(result:Database.ResultSet){
        for i in keyMap {
            if i.value is Int{
                result.bind(name: i.key)?.bind(value: i.value as! Int)
            }
            if i.value is Int8{
                result.bind(name: i.key)?.bind(value: i.value as! Int8)
            }
            if i.value is Int32{
                result.bind(name: i.key)?.bind(value: i.value as! Int32)
            }
            if i.value is Int64{
                result.bind(name: i.key)?.bind(value: i.value as! Int64)
            }
            if i.value is Int{
                result.bind(name: i.key)?.bind(value: i.value as! Int)
            }
            if i.value is Double{
                result.bind(name: i.key)?.bind(value: i.value as! Double)
            }
            if i.value is Float{
                result.bind(name: i.key)?.bind(value: i.value as! Float)
            }
            if i.value is Data{
                result.bind(name: i.key)?.bind(value: i.value as! Data)
            }
            if i.value is String{
                result.bind(name: i.key)?.bind(value: i.value as! String)
            }
        }
    }
    static public func readData(resultset:Database.ResultSet) throws ->[T]{
        var result:[T] = []
        while try resultset.step() {
            result.append(self.load(result: resultset))
        }
        return result
    }
    static public func load(result:Database.ResultSet)->T{
        var sql = T.init()
        let nk = sql.normalKey
        let nkm = sql.normalKey.reduce(into: [:]) { r, i in
            r[i.1.keyName ?? i.0] = i
        }
        let c = nk.count
        for i in 0 ..< c{
            
            guard let sqlv = nkm[result.columnName(index: i)]?.1 else { continue }
            let vt = sqlv.value
 
            guard let kp = sqlv.path else { continue }
            
            if vt is Int{
                let v = result.column(index:Int32(i), type: Int.self).value()

                if let keyPath = kp as? WritableKeyPath<T,Int?>{
                    sql[keyPath: keyPath] = v
                }
                if let keyPath = kp as? WritableKeyPath<T,Int>{
                    sql[keyPath: keyPath] = v

                }
                
            }
            if vt is Int32{
                let v = result.column(index:Int32(i), type: Int32.self).value()

                if let keyPath = kp as? WritableKeyPath<T,Int32?>{
                    sql[keyPath: keyPath] = v
                }
                if let keyPath = kp as? WritableKeyPath<T,Int32>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Int64{
                let v = result.column(index:Int32(i), type: Int64.self).value()
     
                if let keyPath = kp as? WritableKeyPath<T,Int64?>{
                    sql[keyPath: keyPath] = v
          
                }
                if let keyPath = kp as? WritableKeyPath<T,Int64>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Data{
                let v = result.column(index:Int32(i), type: Data.self).value()
   
                if let keyPath = kp as? ReferenceWritableKeyPath<T,Data?>{
                    sql[keyPath: keyPath] = v
     
                }
                if let keyPath = kp as? ReferenceWritableKeyPath<T,Data>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is String{
                let v = result.column(index:Int32(i), type: String.self).value()

                if let keyPath = kp as? ReferenceWritableKeyPath<T,String?>{
                    sql[keyPath: keyPath] = v

                }
                if let keyPath = kp as? ReferenceWritableKeyPath<T,String>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Double{
                let v = result.column(index:Int32(i), type: Double.self).value()

                if let keyPath = kp as? WritableKeyPath<T,Double?>{
                    sql[keyPath: keyPath] = v
  
                }
                if let keyPath = kp as? WritableKeyPath<T,Double>{
                    sql[keyPath: keyPath] = v
           
                }
            }
            if vt is Float{
                let v = result.column(index:Int32(i), type: Float.self).value()

                if let keyPath = kp as? WritableKeyPath<T,Float?>{
                    sql[keyPath: keyPath] = v

                }
                if let keyPath = kp as? WritableKeyPath<T,Float>{
                    sql[keyPath: keyPath] = v

                }
            }
            if vt is Int8{
                let v = result.column(index:Int32(i), type: Int8.self).value()
         
                if let keyPath = kp as? WritableKeyPath<T,Int8?>{
                    sql[keyPath: keyPath] = v
      
                }
                if let keyPath = kp as? WritableKeyPath<T,Int8>{
                    sql[keyPath: keyPath] = v
    
                }
            }
        }
        return sql
    }
}
