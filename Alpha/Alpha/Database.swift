//
//  Database.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/22.
//

import Foundation
import SQLite3

public class Database:Hashable{
    public static func == (lhs: Database, rhs: Database) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    private var uuid = UUID().uuidString
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    public let url:URL
    public var sqlite:OpaquePointer?
    public var functions:Array<ScalarFunction> = Array()
    public init(url:URL,readOnly:Bool = false) throws{
        self.url = url
        let r = readOnly ? SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX  : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX)
        sqlite3_open_v2(url.path, &self.sqlite, r , nil)
        if(self.sqlite == nil){
            throw NSError(domain: "create sqlite3 fail", code: 0, userInfo: ["url":url])
        }
    }
    deinit {
        sqlite3_close(self.sqlite)
    }
    public class ScalarFunction{
        public let name:String
        public let nArg:Int32
        public var ctx:OpaquePointer?
        public let call:(ScalarFunction,Int32,OpaquePointer?)->Void
        public init(name:String,nArg:Int32,handle:@escaping (ScalarFunction,Int32,OpaquePointer?)->Void) {
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
        public func value(value:OpaquePointer)->Int{
            if MemoryLayout<Int>.size == 4{
                return Int(sqlite3_value_int(value))
            }else{
                return Int(sqlite3_value_int64(value))
            }
        }
        @available(iOS 12.0, *)
        public func valueNoChange(value:OpaquePointer){
            sqlite3_value_nochange(value)
        }
        public func value(value:OpaquePointer)->Int32{
            return sqlite3_value_int(value)
        }
        public func value(value:OpaquePointer)->Int64{
            return sqlite3_value_int64(value)
        }
        public func value(value:OpaquePointer)->Double{
            return sqlite3_value_double(value)
        }
        public func value(value:OpaquePointer)->Float{
            return Float(sqlite3_value_double(value))
        }
        public func value(value:OpaquePointer)->String{
            return String(cString: sqlite3_value_text(value))
        }
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
            
            throw NSError(domain: String(cString: sqlite3_errmsg(self.db.sqlite!)), code: Int(rc), userInfo: ["sql":String(cString: sqlite3_sql(self.stmt))])
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
        public func columnName(index:Int)->String{
            String(cString: sqlite3_column_name(self.stmt, Int32(index)))
        }
        public func close(){
            sqlite3_finalize(self.stmt)
        }
        public var columnCount:Int{
            Int(sqlite3_column_count(self.stmt))
        }
        public func index(paramName:String)->Int32{
            let index = sqlite3_bind_parameter_index(self.stmt, paramName)
            return index
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
            public func bind(value:T) where T == Int8{
                sqlite3_bind_int(self.stmt, index, Int32(value))
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
            public func value()->T where T == Int8{
                Int8(sqlite3_column_int(self.stmt,index))
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
public class DataBasePool{
    static public func checkDir() throws->URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".Database"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    static public func checkBackUpDir() throws->URL{
        let name = (Bundle.main.bundleIdentifier ?? "main" + ".Database") + ".back"
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
        var b:ObjCBool = false
        let a = FileManager.default.fileExists(atPath: url.path, isDirectory: &b)
        if !(b.boolValue && a){
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    public let queue:DispatchQueue = DispatchQueue(label: "database", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    public private(set) var url:URL
    private var read:List<Database> = List()
    private var wdb:Database
    private var semphone = DispatchSemaphore(value: 3)
    private var dbName:String
    private var thread:Thread?
    private var timer:Timer?
    public init(name:String) throws {
        let url = try DataBasePool.checkDir().appendingPathComponent(name)
        self.dbName = name
        if(!FileManager.default.fileExists(atPath: url.path)){
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        self.wdb = try Database(url: url)
        self.url = url
        self.thread = Thread(block: {
            self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { t in
                self.backup()
            })
            RunLoop.current.run()
        })
        self.thread?.start()
    }

    public func read(callback:@escaping (Database) throws->Void){
        self.queue.async {
            do {
                self.semphone.wait()
                defer{
                    
                    self.semphone.signal()
                }
                
                let db = try self.createReadOnly()
                try callback(db)
                self.read.append(element: db)
            }catch{
                print(error)
            }
        }
    }
    public func readSync(callback:@escaping (Database) throws->Void){
        self.queue.sync {
            do {
                self.semphone.wait()
                defer{
                    
                    self.semphone.signal()
                }
                
                let db = try self.createReadOnly()
                try callback(db)
                self.read.append(element: db)
            }catch{
                print(error)
            }
        }
    }
    public func writeSync(callback:@escaping (Database) throws ->Void){
        self.queue.sync(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do {
                try callback(db)
                db.commit()
            }catch{
                print(error)
                db.rollback()
            }
        }))
    }
    private func createReadOnly() throws ->Database{
        if let db = self.read.removeFirst(){
            return db
        }
        let db = try Database(url: self.url, readOnly: true)
        return db
    }
    public func write(callback:@escaping (Database) throws ->Void){
        self.queue.async(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do {
                try callback(db)
                db.commit()
            }catch{
                print(error)
                db.rollback()
            }
        }))
    }
    public func backup(){
        self.read { db in
            let u = try DataBasePool.checkBackUpDir().appendingPathComponent(self.dbName)
            try BackupDatabase(url: u, source: db).backup()
        }
    }
    public static func restore(name:String) throws {
        let u = try DataBasePool.checkBackUpDir().appendingPathComponent(name)
        let ur = try DataBasePool.checkDir().appendingPathComponent(name)
        DispatchQueue.global().sync {
            do{
                try FileManager.default.removeItem(at: ur)
                let source = try Database(url: u, readOnly: true)
                try BackupDatabase(url: ur, source: source).backup()
            }catch{
                print("restore fail")
            }
        }
    }
    deinit {
        self.wdb.close()
        for i in 0 ..< self.read.count {
            self.read[i]?.close()
        }
        self.thread?.cancel()
        self.timer?.invalidate()
    }
}

public struct TableInfo{
    public let cid:Int
    public let name:String
    public let type:String
    public let notnull:Int
    public let dlft_value:String
    public let pk:Int
}
public struct TableForeignKeyInfo{
    public let id:Int
    public let seq:Int
    public let table:String
    public let from:String
    public let to:String
    public let onUpdate:ForeignKeyAction
    public let onDelete:ForeignKeyAction
    public let match:String
}

extension Database{
    public func exec(sql:String) throws {
        #if DEBUG
        print("SQL:"+sql)
        #endif
        var error:UnsafeMutablePointer<CChar>?
        sqlite3_exec(self.sqlite, sql, { arg, len, v,col in
            print("<<<<<<<<<<<<")
            for i in 0 ..< len{
                let vstr = v?[Int(i)] == nil ? "NULL" : String(cString: v![Int(i)]!)
                let cStr = col?[Int(i)] == nil ? "NULL" : String(cString: col![Int(i)]!)
                print("\(cStr):\(vstr)")
            }
            print(">>>>>>>>>>>>>")
            return 0
        }, nil, &error)
        if let e = error{
            let data = Data(bytes: e, count: strlen(e))
            sqlite3_free(error)
            throw NSError(domain: String(data: data, encoding: .utf8) ?? "unknow error", code: 0, userInfo: ["sql":sql])
        }
    }
    public func query(sql:String) throws ->ResultSet{
        #if DEBUG
        print("SQL:"+sql)
        #endif
        var stmt:OpaquePointer?
        let nextSql:UnsafeMutablePointer<UnsafePointer<CChar>?> = .allocate(capacity: 1)
        let rc = sqlite3_prepare(self.sqlite, sql, Int32(sql.utf8.count), &stmt, nextSql)
        if rc != SQLITE_OK{
            throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite!)), code: Int(rc), userInfo: ["sql":sql])
        }
        guard let s = stmt else { throw NSError(domain: String(cString: sqlite3_errmsg(self.sqlite!)), code: 0, userInfo: ["sql":sql])}
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
            call.ctx = ctx
            call.call(call,i,ret?.pointee)
        }, nil, nil)
    }
    public func rollback(){
        sqlite3_rollback_hook(sqlite, nil, nil)
    }
    public func commit(){
        sqlite3_commit_hook(self.sqlite, nil, nil)
    }
    public func close(){
        sqlite3_close(self.sqlite)
    }
    public func fetch<T:SQLCode>(request:FetchRequest<T>) throws->ResultSet{
        let rs = try self.query(sql: request.sql)
        request.doSelectBind(result: rs)
        return rs
    }
    public static func errormsg(pointer:OpaquePointer?)->String{
        String(cString: sqlite3_errmsg(pointer))
    }
    public func tableInfo(name:String) throws ->[String:TableInfo]{
        let r = try self.query(sql: "PRAGMA table_info(\(name))")
        var map:[String:TableInfo] = [:]
        while try r.step() {
            
            let tav = TableInfo(cid: r.column(index: 0, type: Int.self).value(),
                                name: r.column(index: 1, type: String.self).value(),
                                type: r.column(index: 2, type: String.self).value(),
                                notnull: r.column(index: 3, type: Int.self).value(),
                                dlft_value: r.column(index: 4, type: String.self).value(),
                                pk: r.column(index: 5, type: Int.self).value())
            map[tav.name] = tav
            
        }
        return map
    }
    public func tableForeignKeyInfo(name:String) throws ->[String:TableForeignKeyInfo]{
        let r = try self.query(sql: "PRAGMA foreign_key_list(\(name));")
        var map:[String:TableForeignKeyInfo] = [:]
        while try r.step() {
            
            let tav = TableForeignKeyInfo(id: r.column(index: 0, type: Int.self).value(),
                                          seq: r.column(index: 1, type: Int.self).value(),
                                          table:r.column(index: 2, type: String.self).value(),
                                          from:r.column(index: 3, type: String.self).value(),
                                          to:r.column(index: 4, type: String.self).value(),
                                          onUpdate: ForeignKeyAction(action: r.column(index: 5, type: String.self).value()),
                                          onDelete: ForeignKeyAction(action: r.column(index: 6, type: String.self).value()),
                                          match: r.column(index: 7, type: String.self).value())
            map[tav.from] = tav
        }
        return map
    }
    public func integrityCheck(table:String) throws ->Bool{
        let r = try self.query(sql: "PRAGMA INTEGRITY_CHECK(\(table))")
        if try r.step(){
            return r.column(index: 0, type: String.self).value() == "ok"
        }
        return false
    }
    public var foreignKey:Bool{
        get{
            do{
                let r = try self.query(sql: "PRAGMA foreign_keys")
                try r.step()
                return r.column(index: 0, type: Int8.self).value() > 0
            }catch{
                return false
            }
            
        }
        set{
            try? self.exec(sql: "PRAGMA foreign_keys = \(newValue ? "ON" : "OFF")")
        }
    }
    public func create<T:SQLCode>(obj:T) throws{
        try self.exec(sql: obj.create)
    }
    public func exist<T:SQLCode>(type:T.Type) throws ->Bool{
        var state = false
        let r = try self.query(sql: "select count(*) from sqlite_master where type='table' and name = '\(type.tableName)'")
        while try r.step(){
            state = r.column(index: 0, type: Int32.self).value() > 0
        }
        return state
    }
    public func update<T:SQLCode>(model:T) throws {
        try model.doUpdate(db: self)
    }
    public func update<T:SQLCode>(model:[String:SqlType],table:T.Type,condition:Condition,bind:[String:SqlType]) throws {
        let kv = model.map { i in
            T.updateSetKeyCode((i.key,i.value))
        }.joined(separator: ",")
        let c = "UPDATE \(T.tableName) SET \(kv) where \(condition.conditionCode)"
        let rs = try self.query(sql: c)
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
        rs.close()
    }
    public func delete<T:SQLCode>(table:T.Type,condition:Condition,bind:[String:SqlType]) throws {
        let c = "DELETE FROM \(T.tableName) where \(condition.conditionCode)"
        let rs = try self.query(sql: c)
        for i in bind{
            if i.value is Data{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! Data)
            }else if i.value is String{
                rs.bind(name: "@"+i.key)?.bind(value: i.value as! String)
            }
        }
        try rs.step()
        rs.close()
    }
    public func select<T:SQLCode>(request:FetchRequest<T>) throws ->[T]{
        let s = try self.fetch(request: request)
        let re = try FetchRequest<T>.readData(resultset: s)
        return re
    }
    public func delete<T:SQLCode>(model:T) throws {
        try model.doDelete(db: self)
    }
    public func insert<T:SQLCode>(model:T) throws{
        try model.doInsert(db: self)
    }
    public func drop<T:SQLCode>(modelType:T.Type) throws{
        try self.exec(sql: "drop table \(T.tableName)")
    }
}
