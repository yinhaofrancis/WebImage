//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3


public enum ColumeType:String{
    case integer
    case double
    case text
    case blob
}

public protocol TableKey{
    var foreignKeyCode:String { get }
    var keyCode:String { get }
    var name:String { get }
    var primary:Bool { get }
}

public struct ColumnKey<T,K>:TableKey{
    
    
    public var name: String
    public let type:ColumeType
    public var notnull,unique,primary,autoincreament:Bool
    public var `default`:String?
    public let mapPair:WritableKeyPath<T,K>
    
    public var remoteTable:String?
    
    public var remoteKey:String?
    
    public var onDelete:Action?
    
    public var onUpdate:Action?
    
    public enum Action{
        case NO_ACTION
        case RESTRICT
        case SET_NULL
        case SET_DEFAULT
        case CASCADE
        func toString() -> String {
            switch self {
            
            case .NO_ACTION:
                return "NO ACTION"
            case .RESTRICT:
                return "RESTRICT"
            case .SET_NULL:
                return "SET NULL"
            case .SET_DEFAULT:
                return "SET DEFAULT"
            case .CASCADE:
                return "CASCADE"
            }
        }
    }
    
    public init(name:String,
                type:ColumeType,
                map:WritableKeyPath<T,K>,
                notnull:Bool = false,
                unique:Bool = false,
                primary:Bool = false,
                autoincreament:Bool = false,
                defaultValue:String? = nil){
        self.name = name
        self.type = type
        self.mapPair = map
        self.notnull = notnull
        self.unique = unique
        self.primary = primary
        self.autoincreament = autoincreament
        self.default = defaultValue
    }
    public func foreignKey<T:SQLCode>(remoteTable:T.Type,
                           remoteKey:String,
                           onDelete:Action? = nil,
                           onUpdate:Action? = nil)->ColumnKey{
        var new = self
        new.remoteTable = T.tableName
        new.remoteKey = remoteKey
        new.onUpdate = onUpdate
        new.onDelete = onDelete
        return new
    }
    public var keyCode:String{
        var code = name + " " + type.rawValue
        if notnull{
            code += " NOT NULL"
        }
        if unique{
            code += " UNIQUE"
        }
        if autoincreament{
            code += " AUTOINCREMENT"
        }
        if let df = self.default{
            code += " DEFAULT '\(df)'"
        }
        return code
    }
    public var foreignKeyCode: String{
        guard let rt = remoteTable else { return "" }
        guard let rk = remoteKey else { return "" }
        
        let od = self.onDelete != nil ? " ON DELETE \(self.onDelete!.toString())" : ""
        let ou = self.onUpdate != nil ? " ON UPDATE \(self.onUpdate!.toString())" : ""
        return ("FOREIGN KEY(\(self.name)) REFERENCES \(rt)(\(rk))" + od + ou).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public struct TableBody{
    let colume:[TableKey]
}
public protocol SQLCode {
    static var tableName:String { get }
    @BuildTable static var table:TableBody { get }
}
extension SQLCode{
    static var pk:String?{
        let k = self.table.colume.filter({$0.primary}).map({$0.name.trimmingCharacters(in: .whitespaces)}).joined(separator: ",")
        if k.count == 0{
            return nil
        }else{
            return "PRIMARY KEY(\(k))"
        }
    }
    public static var create:String{
        var a = self.table.colume.map({$0.keyCode})
        if let pk = self.pk{
            a.append(pk)
        }
        let f = Self.table.colume.map({$0.foreignKeyCode})
        a.append(contentsOf: f)
        a = a.filter({$0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0})
        return "CREATE TABLE IF NOT EXISTS \(self.tableName)(" + a.joined(separator: ",") + ")"
    }
}

@resultBuilder
public enum BuildTable{
    public static func buildBlock(_ components: TableKey...) -> TableBody {
        return TableBody(colume: components)
    }
}

public class DatabaseModel{
    var pool:DataPool
    public init(pool:DataPool){
        self.pool = pool
    }
    public func create<T:SQLCode>(type:T.Type){
        self.pool.write { db in
            try db.exec(sql: T.create)
        }
    }
    public func update(model:SQLCode){
        
    }
}
