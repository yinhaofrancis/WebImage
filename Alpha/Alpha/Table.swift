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
    init()
}
public protocol Value{
    static var type:Database.ResultSet.DBDataType { get }
}
extension Value{
    public func value<T:Value>(type:T.Type)->T?{
        return Self.type == T.type ? self as? T : nil
    }
}

extension Int:Value{
    public static var type: Database.ResultSet.DBDataType{
        .Integer
    }
}
extension String:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Text
    }
}
extension Double:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Float
    }
}
extension Data:Value{
    public static  var type: Database.ResultSet.DBDataType{
        .Blob
    }
}

@dynamicMemberLookup
public struct SQLResult:CustomDebugStringConvertible{
    
    public var debugDescription: String{
        return self.value.debugDescription
    }
    public var value:[String:Value] = [:]
    
    public subscript(dynamicMember dynamicMember:String)->Value?{
        self.value[dynamicMember]
    }
}

extension SQLResult{
    public static func query(db:Database,sql:String)throws ->[SQLResult]{
        let result = try db.query(sql: sql)
        var array:[SQLResult] = []
        while (try result.step()){
            var dic:[String:Value] = [:]
            for i in 0 ..< result.columnCount {
                let name = result.columnName(index: i)
                switch result.type(index: Int32(i)) {
                
                case .Integer:
                    let str = result.column(index: Int32(i), type: Int.self).value()
                    dic[name] = str
                    break
                case .Float:
                    let str = result.column(index: Int32(i), type: Double.self).value()
                    dic[name] = str
                    break
                case .Text:
                    let str = result.column(index: Int32(i), type: String.self).value()
                    dic[name] = str
                    break
                case .Blob:
                    let str = result.column(index: Int32(i), type: Data.self).value()
                    dic[name] = str
                    break
                case .Null:
                    break
                }
            }
            array.append(SQLResult(value: dic))
        }
        return array
    }
}
