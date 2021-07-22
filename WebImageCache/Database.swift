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
    public var functions:Array<ScalarFunction> = Array()
    public init(group:DispatchGroup,queue:DispatchQueue,name:String) throws{
        self.group = group
        self.queue = queue
        let url = try Database.checkCacheDir().appendingPathComponent(name)
        self.url = url
        sqlite3_open_v2(url.path, &self.sqlite, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        if(self.sqlite == nil){
            throw NSError(domain: "create sqlite3 fail", code: 0, userInfo: nil)
        }
    }
    public func exec(sql:String) throws {
        var error:UnsafeMutablePointer<CChar>?
//        sqlite3_exec(self.sqlite, sql, nil, nil, &error)

        sqlite3_exec(self.sqlite, sql, { arg, len, v,col in
            for i in 0 ..< len{
                let vstr = v?[Int(i)] == nil ? "NULL" : String(cString: v![Int(i)]!)
                let cStr = col?[Int(i)] == nil ? "NULL" : String(cString: col![Int(i)]!)
                print("\(cStr):\(vstr)")
            }
            return 0
        }, nil, &error)
        if let e = error{
            let data = Data(bytes: e, count: strlen(e))
            sqlite3_free(error)
            throw NSError(domain: String(data: data, encoding: .utf8) ?? "unknow error", code: 0, userInfo: nil)
        }
    }
    public func query(sql:String) throws ->ResultSet{
        var stmt:OpaquePointer?
        let nextSql:UnsafeMutablePointer<UnsafePointer<CChar>?> = .allocate(capacity: 1)
        let rc = sqlite3_prepare(self.sqlite, sql, Int32(sql.utf8.count), &stmt, nextSql)
        if rc != SQLITE_OK{
            throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite!)), code: Int(rc), userInfo: nil)
        }
        guard let s = stmt else { throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite!)), code: 0, userInfo: nil)}
        if let cs = nextSql.pointee{
            let nsql = String(cString: cs)
            nextSql.deallocate()
            return ResultSet(stmt: s, db: self,nextSql: nsql)
        }else{
            return ResultSet(stmt: s, db: self)
        }
    }
    public func addScalarFunction(function:ScalarFunction){
    
        self.functions.append(function)
        sqlite3_create_function(self.sqlite!, function.name, function.nArg, SQLITE_UTF8, Unmanaged.passUnretained(function).toOpaque(), { ctx, i, ret in
            let call = Unmanaged<ScalarFunction>.fromOpaque(sqlite3_user_data(ctx)).takeUnretainedValue()
            call.call(call,i,ret)
        }, nil, nil)
    }
    static public func checkCacheDir() throws->URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".Database"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    public func close(){
        sqlite3_close(self.sqlite)
    }
    deinit {
        sqlite3_close(self.sqlite)
    }
    public class ScalarFunction{
        public let name:String
        public let nArg:Int32
        public var ctx:OpaquePointer?
        public let call:(ScalarFunction,Int32,UnsafeMutablePointer<OpaquePointer?>?)->Void
        public init(name:String,nArg:Int32,handle:@escaping (ScalarFunction,Int32,UnsafeMutablePointer<OpaquePointer?>?)->Void) {
            self.name = name
            self.nArg = nArg
            self.call = handle
        }
        public func ret(v:Int){
            guard let c = ctx else {
                return
            }
            if MemoryLayout.size(ofValue: v) == 4{
                sqlite3_result_int(c, Int32(v))
            }else{
                sqlite3_result_int64(c, Int64(v))
            }
            
        }
        public func ret(v:Int32){
            guard let c = ctx else {
                return
            }
            sqlite3_result_int(c, Int32(v))
        }
        public func ret(v:Int64){
            guard let c = ctx else {
                return
            }
            sqlite3_result_int64(c, Int64(v))
        }
        public func ret(v:String){
            guard let sc = ctx else {
                return
            }
            guard let c = v.cString(using: .utf8) else {
                sqlite3_result_null(sc)
                return
            }
            let p = UnsafeMutablePointer<CChar>.allocate(capacity: v.utf8.count)
            memcpy(p, c, v.utf8.count)
            sqlite3_result_text(sc, v.cString(using: .utf8), Int32(v.utf8.count)) { p in
                p?.deallocate()
            }
        }
        public func ret(v:Data){
            guard let sc = ctx else {
                return
            }
            let pointer = sqlite3_malloc(Int32(v.count))
            let buffer = UnsafeMutableRawBufferPointer(start: pointer, count: v.count)
            v.copyBytes(to: buffer, count: v.count)
            sqlite3_result_blob(sc, pointer, Int32(v.count)) { p in
                sqlite3_free(p)
            }
        }
        public func ret(v:Float){
            guard let sc = ctx else {
                return
            }
            sqlite3_result_double(sc, Double(v))
        }
        public func ret(v:Double){
            guard let sc = ctx else {
                return
            }
            sqlite3_result_double(sc, v)
        }
        public func ret(){
            guard let sc = ctx else {
                return
            }
            sqlite3_result_null(sc)
        }
        public func ret(error:String,code:Int32){
            guard let sc = ctx else {
                return
            }
            sqlite3_result_error(sc, error, Int32(error.utf8.count))
            sqlite3_result_error_code(sc, code)
        }
//        public func h
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
        
        private var stmt:OpaquePointer
        private var nextSql:String?
        private unowned var db:Database
        public init(stmt:OpaquePointer,db:Database,nextSql:String? = nil) {
            self.stmt = stmt
            self.db = db
            self.nextSql = nextSql
        }
        @discardableResult
        public func step() throws ->Bool{
            let rc = sqlite3_step(self.stmt)
            if rc == SQLITE_ROW{
                return true
            }
            if rc == SQLITE_DONE{
                return false
            }
            throw NSError(domain: String(cString: sqlite3_errmsg(self.db.sqlite!)), code: Int(rc), userInfo: nil)
        }
        public func next() throws ->ResultSet?{
            guard let sql = self.nextSql else {
                return nil
            }
            return try self.db.query(sql: sql)
        }
        @discardableResult
        public func finish()->ResultSet{
            do {
                try self.step()
            } catch {
                
            }
            self.close()
            return self
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
        public func bind<T>(name:String)->Bind<T>?{
            let index = self.index(paramName: name)
            if(index == 0){
                return nil
            }
            return Bind<T>.init(stmt: self.stmt, index: index)
        }
        public func column<T>(index:Int32,type:T.Type)->Column<T>{
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
                guard let c = value.cString(using: .utf8) else {
                    sqlite3_bind_null(self.stmt, index)
                    return
                }
                let p = UnsafeMutablePointer<CChar>.allocate(capacity: value.utf8.count)
                memcpy(p, c, value.utf8.count)
                sqlite3_bind_text(self.stmt, index, p, Int32(value.utf8.count)) { p in
                    p?.deallocate()
                }
            }
            public func bind(value:T) where T == Data{
                let pointer = sqlite3_malloc(Int32(value.count))
                let buffer = UnsafeMutableRawBufferPointer(start: pointer, count: value.count)
                value.copyBytes(to: buffer, count: value.count)
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
            public var tableName:String{
                String(cString: sqlite3_column_table_name(self.stmt, index))
            }
            public var databaseName:String{
                String(cString: sqlite3_column_database_name(self.stmt, index))
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
