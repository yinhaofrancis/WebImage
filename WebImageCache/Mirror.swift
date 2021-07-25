//
//  Mirror.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/24.
//

import Foundation
public struct ForeignKeyAction{
    let action:String
    static public var CASCADE:ForeignKeyAction = ForeignKeyAction(action: "CASCADE")
    static public var NO_ACTION:ForeignKeyAction = ForeignKeyAction(action: "NO ACTION")
    static public var RESTRICT:ForeignKeyAction = ForeignKeyAction(action: "RESTRICT")
    static public var SET_NULL:ForeignKeyAction = ForeignKeyAction(action: "SET NULL")
    static public var SET_DEFAULT:ForeignKeyAction = ForeignKeyAction(action: "SET DEFAULT")
}

public protocol SqlType{
    static var sqlType:String { get }
    var sqlType:String { get }
    var primaryKey:Bool { get }
    var remoteTable:String? { get }
    var remoteKey:String? { get }
    var keyName:String? { get }
    var onDelete:ForeignKeyAction? { get }
    var onUpdate:ForeignKeyAction? { get }
    var value:Any? { get }
}

extension Int:SqlType {
    public var value: Any? {
        self
    }
    
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
    
    public var keyName: String? {
        return nil
    }
    
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    
    public var primaryKey: Bool {
        false
    }
    
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
}
extension Int32:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var remoteKey: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Int64:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Int8:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Bool:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public static var sqlType:String{
        return "INTEGER NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}

extension String:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "TEXT NOT NULL"
    }
    public static var sqlType:String{
        return "TEXT NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Data:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "BLOB NOT NULL"
    }
    public static var sqlType:String{
        return "BLOB NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}

extension Double:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "REAL NOT NULL"
    }
    public static var sqlType:String{
        return "REAL NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Float:SqlType {
    public var value: Any? {
        self
    }
    public var sqlType:String{
        return "REAL NOT NULL"
    }
    public static var sqlType:String{
        return "REAL NOT NULL"
    }
    public var primaryKey: Bool {
        false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}
extension Optional:SqlType where Wrapped:SqlType {
    public var value: Any? {
        self ?? nil
    }
    public static var sqlType: String {
        Wrapped.sqlType.components(separatedBy: " ").first!
    }
    
    public var sqlType: String {
        Wrapped.sqlType.components(separatedBy: " ").first!
    }
    public var primaryKey: Bool {
        return false
    }
    public var remoteTable: String? {
        return nil
    }
    
    public var remoteKey: String? {
        return nil
    }
    public var keyName: String? {
        return nil
    }
    public var onDelete: ForeignKeyAction? {
        nil
    }
    
    public var onUpdate: ForeignKeyAction? {
        nil
    }
}

@propertyWrapper
public struct Unique<T:SqlType>:SqlType{
    public var value: Any? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType + " UNIQUE"
    }
    
    public static var sqlType: String{
        T.sqlType + " UNIQUE"
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct PrimaryKey<T:SqlType>:SqlType{
    public var value: Any? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    
    public static var sqlType: String{
        T.sqlType
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T){
        self.wrappedValue = wrappedValue
    }
    public var primaryKey: Bool {
        true
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct Default<T:SqlType>:SqlType{
    public var value: Any? {
        wrappedValue.value
    }
    public static var sqlType: String{
        T.sqlType
    }
    
    public var sqlType: String{
        wrappedValue.sqlType + "  DEFAULT `\(self.defaultvalue)`"
    }
    public var wrappedValue:T
    public var defaultvalue:String
    public init(wrappedValue:T, _ value:String){
        self.wrappedValue = wrappedValue
        self.defaultvalue = value
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String? {
        return wrappedValue.keyName
    }
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}
@propertyWrapper
public struct Key<T:SqlType>:SqlType{
    public var value: Any? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    
    public static var sqlType: String{
        T.sqlType
    }
    
    public var wrappedValue:T
    public init(wrappedValue:T,_ name:String){
        self.wrappedValue = wrappedValue
        self.keyName = name
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    public var remoteTable: String? {
        return wrappedValue.remoteTable
    }
    
    public var remoteKey: String? {
        return wrappedValue.remoteKey
    }
    public var keyName: String?
    public var onDelete: ForeignKeyAction? {
        wrappedValue.onDelete
    }
    
    public var onUpdate: ForeignKeyAction? {
        wrappedValue.onUpdate
    }
}

@propertyWrapper
public struct ForeignKey<T:SqlType>:SqlType{
    public var value: Any? {
        wrappedValue.value
    }
    public var sqlType: String{
        wrappedValue.sqlType
    }
    
    public static var sqlType: String{
        T.sqlType
    }
    
    public var wrappedValue:T
    public var remoteTable: String?
    public var onDelete: ForeignKeyAction?
    public var onUpdate: ForeignKeyAction?
    public var remoteKey: String?
    public init(wrappedValue:T,
                remoteTable:String,
                remoteKey:String,
                onDelete:ForeignKeyAction? = nil,
                onUpdate:ForeignKeyAction? = nil){
        self.wrappedValue = wrappedValue
        self.remoteTable = remoteTable
        self.remoteKey = remoteKey
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    public var primaryKey: Bool {
        wrappedValue.primaryKey
    }
    
    public var keyName: String? {
        return wrappedValue.keyName
    }
    
}



extension SQLCode{
    
    private var columnMap:[(label:String,value:SqlType)]{
        if Self.explictKey{
            return Mirror(reflecting: self).children.filter({$0.value is SqlType && $0.label != nil}).map { i in
                (label:i.label!,value:i.value as! SqlType)
            }.filter { i in
                i.value.keyName != nil
            }
        }else{
            return Mirror(reflecting: self).children.filter({$0.value is SqlType}).map { i in
                (label:i.label!,value:i.value as! SqlType)
            }
        }
    }
    
    public var create:String{
        let columnMap = self.columnMap
        
        var item = columnMap.map { i in
            "`\(i.value.keyName ?? i.label)` \(i.value.sqlType)"
        }
        if item.count == 0{
            return ""
        }
        let fitem = columnMap.filter { i in
            i.value.remoteTable != nil && i.value.remoteKey != nil
        }.map { i -> String in
            var code = "FOREIGN KEY(`\(i.value.keyName ?? i.label)`) REFERENCES `\(i.value.remoteTable!)`(`\(i.value.remoteKey!)`)"
            if let action = i.value.onUpdate{
                code += " ON UPDATE \(action.action) "
            }
            if let action = i.value.onDelete{
                code += " ON DELETE \(action.action) "
            }
            return code
        }

        let pkItem = columnMap.filter { i in
            i.value.primaryKey
        }.map { i in
            "`\(i.value.keyName ?? i.label)`"
        }.compactMap({$0})
        if(pkItem.count > 0){
            let pk = "PRIMARY KEY(" + pkItem.joined(separator: ",") + ")"
            
            item.append(pk)
        }
        if(fitem.count > 0){
            item.append(contentsOf: fitem)
        }

        return "CREATE TABLE IF NOT EXISTS  `\(Self.tableName)` (" + item.joined(separator: ",") + ")"
    }
    public var primaryKey:[(String,SqlType)]{
        self.columnMap.filter { i in
            i.value.primaryKey
        }.filter { i in
            i.value.value != nil
        }
    }
    public var normalKey:[(String,SqlType)] {
        self.columnMap.filter({$0.value.value != nil})
    }
    public static func insertKeyCode(_ i: (String, SqlType)) -> String {
        if i.1.value is Data{
            return "@\(i.0)"
        }else if i.1.value is String{
            return "@\(i.0)"
        }else{
            return "\(i.1.value!)"
        }
    }
    
    var allValueKey:String{
        return self.normalKey.map { i -> String in
            return Self.insertKeyCode(i)
        }.joined(separator: ",")
    }
    var insert:String{
        let key = self.normalKey.map({$0.1.keyName ?? $0.0}).joined(separator: ",")
        
        return "INSERT INTO \(Self.tableName) (\(key)) values(\(self.allValueKey))"
    }
    var bindMap:[String:SqlType]{
        self.normalKey.filter { i in
            i.1.value != nil && (i.1.value is Data || i.1.value is String)
        }.reduce(into: [:]) { r, i in
            r[i.0] = i.1
        }
    }
    func doInsert(db:Database) throws{
        let result = try db.query(sql: self.insert)
        self.doBind(resultSet: result)
        try result.step()
    }
    public static func updateSetKeyCode(_ i: (String, SqlType)) -> String {
        let key = i.1.keyName ?? i.0
        if i.1.value is Data{
            return "\(key) = @\(i.0)"
        }else if i.1.value is String{
            return "\(key) = @\(i.0)"
        }else{
            return "\(key) = \(i.1.value!)"
        }
    }
    
    var update:String{
        let value = self.normalKey.filter({ i in
            i.1.primaryKey == false
        }).map { i -> String in
            return Self.updateSetKeyCode(i)
        }.joined(separator: ",")
        if self.primaryKey.count == 0{
            return ""
        }else{
            return "UPDATE \(Self.tableName) SET \(value) where \(self.primaryCondition)"
        }
    }
    
    func doUpdate(db:Database) throws{
        let result = try db.query(sql: self.update)
        self.doBind(resultSet: result)
        try result.step()
    }
    var delete:String{
        if self.primaryKey.count == 0{
            return ""
        }
        return "DELETE FROM \(Self.tableName) where \(self.primaryCondition)"
    }
    func doDelete(db:Database) throws{
        let result = try db.query(sql: self.delete)
        self.doBind(resultSet: result)
        try result.step()
    }
    
    public static func conditionCode(_ i: (String, SqlType)) -> String {
        let key = i.1.keyName ?? i.0
        if i.1.value is Data{
            return "\(key) == @\(i.0)"
        }else if i.1.value is String{
            return "\(key) == @\(i.0)"
        }else{
            return "\(key) == \(i.1.value!)"
        }
    }
    
    var primaryCondition:String{
        if(self.primaryKey.count > 0){
            return self.primaryKey.map { i in
                return Self.conditionCode(i)
            }.joined(separator: " AND ")
        }else{
            return ""
        }
    }
    var primaryConditionBindMap:[String:SqlType]{
        self.primaryKey.filter { i in
            i.1.value != nil && (i.1.value is Data || i.1.value is String)
        }.reduce(into: [:]) { r, k in
            r[k.0] = k.1
        }
    }
    func doBind(resultSet:Database.ResultSet){
        for i in self.bindMap {
            if i.value is String{
                resultSet.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }else if i.value is Data{
                resultSet.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }
        }
    }
}

