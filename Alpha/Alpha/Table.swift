//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3

 
public protocol SQLCode{
    static var tableName:String { get }
    static var explictKey:Bool { get }
    init()
}



public class DatabaseModel{
    var pool:DataBasePool
    public init(pool:DataBasePool){
        self.pool = pool
    }
    public func create<T:SQLCode>(obj:T){
        self.pool.write { db in
            try db.exec(sql: obj.create)
        }
    }
    public func exist<T:SQLCode>(type:T.Type)->Bool{
        var state = false
        self.pool.readSync { db in
            let r = try db.query(sql: "select count(*) from sqlite_master where type='table' and name = '\(type.tableName)'")
            while try r.step(){
                state = r.column(index: 0, type: Int32.self).value() > 0
            }
        }
        return state
    }
    public func update<T:SQLCode>(model:T){
        self.pool.write { db in
            try model.doUpdate(db: db)
        }
    }
    public func update<T:SQLCode>(model:[String:SqlType],table:T.Type,condition:Condition,bind:[String:SqlType]){
        self.pool.write { db in
            let kv = model.map { i in
                T.updateSetKeyCode((i.key,i.value))
            }.joined(separator: ",")
            let c = "UPDATE \(T.tableName) SET \(kv) where \(condition.conditionCode)"
            let rs = try db.query(sql: c)
            for i in model{
                if i.value is Data{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
                }else if i.value is String{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
                }
            }
            for i in bind{
                if i.value is Data{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
                }else if i.value is String{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
                }
            }
            try rs.step()
        }
    }
    public func delete<T:SQLCode>(table:T.Type,condition:Condition,bind:[String:SqlType]){
        self.pool.write { db in

            let c = "DELETE FROM \(T.tableName) where \(condition.conditionCode)"
            let rs = try db.query(sql: c)
            for i in bind{
                if i.value is Data{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
                }else if i.value is String{
                    rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
                }
            }
            try rs.step()
        }
    }
    public func select<T:SQLCode>(request:FetchRequest<T>,callback:@escaping ([T])->Void){
        self.pool.read { db in
            let s = try db.fetch(request: request)
            let re = try FetchRequest<T>.readData(resultset: s)
            callback(re)
        }
    }
    public func delete<T:SQLCode>(model:T){
        self.pool.write { db in
            try model.doDelete(db: db)
        }
    }
    public func insert<T:SQLCode>(model:T){
        self.pool.write { db in
            try model.doInsert(db: db)
        }
    }
}

