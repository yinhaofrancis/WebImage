//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3

 
public protocol SQLCode {
    static var tableName:String { get }
    static var explictKey:Bool { get }
}



public class DatabaseModel{
    var pool:DataPool
    public init(pool:DataPool){
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
        
    }
}

