//
//  Database.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/22.
//

import Foundation
import SQLite3

public class Database{
    public let group:DispatchGroup
    public let queue:DispatchQueue
    public let url:URL
    public var sqlite:OpaquePointer?
    public init(group:DispatchGroup,queue:DispatchQueue,name:String) throws{
        self.group = group
        self.queue = queue
        let url = try Database.checkCacheDir().appendingPathComponent(name)
        self.url = url
        sqlite3_open_v2(url.path, &self.sqlite, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
    }
    public func exec(sql:String) throws {
        var error:UnsafeMutablePointer<CChar>?
        sqlite3_exec(self.sqlite, sql, nil, Unmanaged.passUnretained(self).toOpaque(), &error)
        if let e = error{
            let data = Data(bytes: e, count: strlen(e))
            throw NSError(domain: String(data: data, encoding: .utf8) ?? "unknow error", code: 0, userInfo: nil)
        }
    }
    public func query(sql:String) throws ->ResultSet{
        var stmt:OpaquePointer?
        let rc = sqlite3_prepare(self.sqlite, sql, -1, &stmt, nil)
        if rc != SQLITE_OK{
            throw NSError(domain:"query fail" , code: Int(rc), userInfo: nil)
        }
        guard let s = stmt else { throw NSError(domain: "query error", code: 0, userInfo: nil)}
        return ResultSet(stmt: s)
    }
    static public func checkCacheDir() throws->URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".Database"
        let url = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    deinit {
        sqlite3_close(self.sqlite)
    }
    
    public class ResultSet{
        
        public enum DBDataType{
            case Integer
            case Float
            case Text
            case Blob
            case Null
        }
        public enum DBModelType{
            case int32
            case int64
            case string
            case double
            case data
        }
        
        public var stmt:OpaquePointer
        public init(stmt:OpaquePointer) {
            self.stmt = stmt
        }
        public func next() throws ->Bool{
            let rc = sqlite3_step(self.stmt)
            if rc == SQLITE_ROW{
                return true
            }
            if rc == SQLITE_DONE{
                return false
            }
            throw NSError(domain: "query error", code: Int(rc), userInfo: nil)
        }
        public func close(){
            sqlite3_finalize(self.stmt)
        }
        public var columnCount:Int{
            Int(sqlite3_column_count(self.stmt))
        }
        public func index(paramName:String)->Int32{
            sqlite3_bind_parameter_index(self.stmt, paramName)
        }
        public func bind<T>(index:Int32)->Bind<T>{
            Bind<T>.init(stmt: self.stmt, index: index)
        }
        public func bind<T>(index:Int32,value:T){
            
        }
        public func column<T>(index:Int32)->Column<T>{
            Column.init(stmt: self.stmt, index: index)
        }
        
        public var paramCount:Int32{
            sqlite3_bind_parameter_count(self.stmt)
        }
        public struct Bind<T>{
            public var stmt:OpaquePointer
            public var index:Int32
            public func bind(value:T) where T == Int32{
                sqlite3_bind_int(self.stmt, index, value)
            }
            public func bind(value:T) where T == Int{
                if MemoryLayout.size(ofValue: value) == 4{
                    sqlite3_bind_int(self.stmt, index, Int32(value))
                }else{
                    sqlite3_bind_int64(self.stmt, index, Int64(value))
                }
            }
            public func bind(value:T) where T == Int64{
                sqlite3_bind_int64(self.stmt, index, value)
            }
            public func bind(value:T) where T == Double{
                sqlite3_bind_double(self.stmt, index, value)
            }
            public func bind(value:T) where T == Float{
                sqlite3_bind_double(self.stmt, index, Double(value))
            }
            public func bind(value:T) where T == String{
                guard let d = value.data(using: .utf8) else { return }
                let poiner = UnsafeMutablePointer<CChar>.allocate(capacity: d.count)
                sqlite3_bind_text(self.stmt, index, poiner, Int32(d.count)) { p in
                    p?.deallocate()
                }
            }
            public func bind(value:T) where T == Data{
                let pointer = sqlite3_malloc(Int32(value.count))
                sqlite3_bind_blob64(self.stmt, index, pointer, sqlite3_uint64(value.count)) { po in
                    sqlite3_free(po)
                }
            }
            public func bind(){
                sqlite3_bind_null(self.stmt, self.index)
            }
            public var name:String{
                String(cString: sqlite3_bind_parameter_name(self.stmt, self.index))
            }
        }
        public struct Column<T>{
            public var stmt:OpaquePointer
            public var index:Int32
            public func value()->T where T == Int32{
                sqlite3_column_int(self.stmt, index)
            }
            public func value()->T where T == Int64{
                sqlite3_column_int64(self.stmt, index)
            }
            public func value()->T where T == String{
                let len = sqlite3_column_bytes(self.stmt, index)
                guard let byte = sqlite3_column_text(self.stmt, index) else { return "" }
                return String(data: Data(bytes: byte, count: Int(len)), encoding: .utf8) ?? ""
            }
            public func value()->T where T == Double{
                sqlite3_column_double(self.stmt,index)
            }
            public func value()->T where T == Float{
                Float(sqlite3_column_double(self.stmt,index))
            }
            public func value()->T where T == Int{
                if MemoryLayout<T>.size == 4{
                    return Int(sqlite3_column_int(self.stmt, index))
                }else{
                    return Int(sqlite3_column_int64(self.stmt, index))
                }
            }
            public func value()->T where T == Data{
                let len = sqlite3_column_bytes(self.stmt, index)
                guard let byte = sqlite3_column_blob(self.stmt, index) else { return Data() }
                return Data(bytes: byte, count: Int(len))
            }
            public var name:String{
                String(cString: sqlite3_column_name(self.stmt, index))
            }
            public var type:DBDataType{
                let a = sqlite3_column_type(self.stmt, index)
                switch a {
                case SQLITE_INTEGER:
                    return .Integer
                case SQLITE_FLOAT:
                    return .Float
                case SQLITE_TEXT:
                    return .Text
                case SQLITE_BLOB:
                    return .Blob
                default:
                    return .Null
                }
            }
            
        }
    }
    
}
