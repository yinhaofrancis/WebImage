//
//  Pool.swift
//  Alpha
//
//  Created by wenyang on 2021/7/29.
//

import Foundation
import SQLite3
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
        let back = try DataBasePool.checkBackUpDir().appendingPathComponent(name)
        self.dbName = name
        if !FileManager.default.fileExists(atPath: url.path) && !FileManager.default.fileExists(atPath: back.path){
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }else if !FileManager.default.fileExists(atPath: url.path){
            try? DataBasePool.restore(name: name)
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
                db.foreignKey = true
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
                db.foreignKey = true
                try callback(db)
                self.read.append(element: db)
            }catch{
                print(error)
            }
        }
    }
    public func writeSync(journal:JournalMode = .DELETE, callback:@escaping (Database) throws ->Void){
        self.queue.sync(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do{
                try db.setJournalMode(journal)
            }catch{
                print(error)
                return
            }
            do {
                db.foreignKey = true
                
                try db.begin()
                try callback(db)
                try db.commit()
            }catch{
                print(error)
                try? db.rollback()
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
    public func write(journal:JournalMode = .DELETE,callback:@escaping (Database) throws ->Void){
        self.queue.async(execute: DispatchWorkItem(flags: .barrier, block: {
            let db = self.wdb
            do{
                try db.setJournalMode(journal)
            }catch{
                print(error)
                return
            }
            do {
                db.foreignKey = true
                print(db.foreignKey)
                try db.begin()
                try callback(db)
                try db.commit()
            }catch{
                print(error)
                try? db.rollback()
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
