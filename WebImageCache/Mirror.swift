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
}

extension Int:SqlType {
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
    public static var sqlType: String{
        T.sqlType
    }
    
    public var sqlType: String{
        wrappedValue.sqlType + "  DEFAULT \"\(self.defaultvalue)\""
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
            return Mirror(reflecting: self).children.filter({$0.value is SqlType}).map { i in
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
            "\"\(i.value.keyName ?? i.label)\" \(i.value.sqlType)"
        }
        if item.count == 0{
            return ""
        }
        let fitem = columnMap.filter { i in
            i.value.remoteTable != nil && i.value.remoteKey != nil
        }.map { i -> String in
            var code = "FOREIGN KEY(\"\(i.value.keyName ?? i.label)\") REFERENCES \"\(i.value.remoteTable!)\"(\"\(i.value.remoteKey!)\")"
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
            "\"\(i.value.keyName ?? i.label)\""
        }.compactMap({$0})
        if(pkItem.count > 0){
            let pk = "PRIMARY KEY(" + pkItem.joined(separator: ",") + ")"
            
            item.append(pk)
        }
        if(fitem.count > 0){
            item.append(contentsOf: fitem)
        }

        return "CREATE TABLE \"\(Self.tableName)\" (" + item.joined(separator: ",") + ")"
    }
}

