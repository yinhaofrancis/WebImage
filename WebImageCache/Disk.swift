//
//  Disk.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/17.
//

import Foundation

public enum LoadType:Int{
    case data
    case file
}

public struct FileInfo{
    public var total:UInt64
    public var length:UInt64
    public var loadType:LoadType
    public var acceptRange:Bool
    public init() {
        total = 0
        length = 0
        loadType = .data
        acceptRange = false
    }
}

public class CacheFile{
    let rw = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
    public let group = DispatchGroup()
    public let name:String
    public var data:Data?
    public init(name:String){
        self.name = name
        pthread_rwlock_init(self.rw, nil)
        CacheFile.checkFileDictionary()
        if !fileExist{
            FileManager.default.createFile(atPath: self.fileUrl.path,
                                           contents: nil, attributes: nil)
            self.writeFileInfo(info: self.fileInfo)
        }
        self.fileInfo = self.readFileInfo()
    }
    public private(set) var fileInfo:FileInfo = FileInfo()
    func readFileInfo()->FileInfo{
        do {
            pthread_rwlock_rdlock(self.rw)
            let file = try FileHandle(forReadingFrom: self.fileUrl)
            defer{
                try! file.close()
                pthread_rwlock_unlock(self.rw)
            }
            return self.readFileInfo(file: file)
        } catch {
            return FileInfo()
        }
    }
    func readFileInfo(file:FileHandle)->FileInfo{
        let data = file.readData(ofLength: MemoryLayout<FileInfo>.size)
        let p = UnsafeMutableBufferPointer<FileInfo>.allocate(capacity: 1)
        let cpLen = data.copyBytes(to: p)
        if(cpLen < MemoryLayout<FileInfo>.size){
            p.deallocate()
            return FileInfo()
        }else{
            let filelen = p.baseAddress?.pointee ?? FileInfo()
            p.deallocate()
            return filelen
        }
    }
    func writeFileInfo(info:FileInfo){
        
        pthread_rwlock_wrlock(self.rw)
        self.fileInfo = info
        let file = try! FileHandle(forWritingTo: self.fileUrl)
        defer{
            try! file.close()
            pthread_rwlock_unlock(self.rw)
        }
        self.writeCount(info: self.fileInfo, file: file)
    }
    func writeCount(info:FileInfo,file:FileHandle){
        var c = info
        if #available(iOS 13.0, *) {
            try! file.seek(toOffset: 0)
        } else {
            file.seek(toFileOffset: 0)
        }
        file.write(Data(bytes: &c, count: MemoryLayout<FileInfo>.size))
    }
    public var fileExist:Bool{
        FileManager.default.fileExists(atPath: self.fileUrl.path)
    }
    
    public var fileUrl:URL{
        return CacheFile.createFileUrl(name: self.name)
    }
    class func createFileUrl(name:String)->URL{
        return CacheFile.cacheDir.appendingPathComponent(name)
    }
    
    class func checkFileDictionary(){
        var flag:ObjCBool = false
        
        let exist = FileManager.default.fileExists(atPath:cacheDir.path , isDirectory: &flag)
        if !exist || !flag.boolValue {
            try! FileManager.default.createDirectory(at: self.cacheDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    static public var cacheDir:URL{
        let name = Bundle.main.bundleIdentifier ?? "main" + ".CacheFile"
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name)
    }
    func read(_ call: @escaping (FileHandle)->Void){
        CacheFile.queue.async {
            do{
                pthread_rwlock_rdlock(self.rw)
                let file = try FileHandle(forReadingFrom: self.fileUrl)
                defer{
                    try! file.close()
                    pthread_rwlock_unlock(self.rw)
                }
                if #available(iOS 13.0, *) {
                    do {
                        try file.seek(toOffset: UInt64(MemoryLayout<FileInfo>.size))
                    } catch {
                        return
                    }
                } else {
                    file.seek(toFileOffset: UInt64(MemoryLayout<FileInfo>.size))
                }
                call(file)
            }catch{
                return
            }
        }
    }
    func write(_ call: @escaping (FileHandle)->Void){
        self.group.enter()
        CacheFile.queue.async {
            
            do{
                pthread_rwlock_wrlock(self.rw)
                let file = try FileHandle(forWritingTo: self.fileUrl)
                defer{
                    try? file.close()
                    pthread_rwlock_unlock(self.rw)
                    self.group.leave()
                }
                
                if #available(iOS 13.4, *) {
                    do {
                        try file.seekToEnd()
                    } catch {
                        return
                    }
                } else {
                    file.seekToEndOfFile()
                }
                call(file)
            }catch{
                self.group.leave()
                return
            }
        }
    }
    public func writeData(data:Data){
        self.data?.append(data)
        self.write { f in
            f.write(data)
            self.fileInfo.length += UInt64(data.count)
            self.writeCount(info: self.fileInfo, file: f)
        }
    }
    public func readData(_ dataCall:@escaping (Data)->Void){
        if let d = self.data{
            CacheFile.queue.async {
                dataCall(d)
            }
            return
        }
        self.read { f in
            
            if #available(iOS 13.4, *) {
                self.data = (try? f.readToEnd()) ?? Data()
                CacheFile.queue.async {
                    dataCall(self.data!)
                }
            } else {
                self.data = f.readDataToEndOfFile()
                CacheFile.queue.async {
                    dataCall(self.data!)
                }
            }
        }
    }
    public func releaseMemory(){
        self.data = nil
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        self.rw.deallocate()
    }
    public static var queue = DispatchQueue(label: "Francis.CacheFile", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
}
