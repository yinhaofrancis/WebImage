//
//  Downloader.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/18.
//

import Foundation
import CommonCrypto

extension Notification.Name{
    public static var dataUpdate:Notification.Name = .init("Downloader.dataUpdate")
    public static var downloaderReset:Notification.Name = .init("Downloader.Reset")
}

public class Downloader:NSObject,URLSessionDataDelegate,URLSessionDownloadDelegate{
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            let filehandle = try FileHandle(forReadingFrom: location)
            defer {
                if #available(iOS 13.0, *) {
                    try? filehandle.close()
                } else {
                    filehandle.closeFile()
                }
            }
            var data:Data = Data()
            if #available(iOS 13.4, *) {
                data = try filehandle.readToEnd() ?? Data()
            } else {
                data = filehandle.readDataToEndOfFile()
                // Fallback on earlier versions
            }
            if data.count == 0 {
                return
            }
            guard let url = downloadTask.originalRequest?.url else {
                return
            }
            guard let file = self.files[url] else {
                return
            }
            file.writeData(data: data)
            self.post(file: file)
            
        }catch{
            
        }
        
        
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        guard let u = downloadTask.originalRequest?.url else { return }
        self.tasks[u] = downloadTask
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let originUrl = dataTask.originalRequest?.url else {
            return
        }
        guard let file = self.files[originUrl] else { return }
        file.writeData(data: data)
        self.post(file: file)
        
    }
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let rep = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            return
        }
        if(rep.statusCode == 200 || rep.statusCode == 206){
            guard let originUrl = dataTask.originalRequest?.url else {
                completionHandler(.cancel)
                return
            }
            guard let file = self.files[originUrl] else {
                completionHandler(.cancel)
                return
            }
            
            if dataTask.originalRequest?.httpMethod?.lowercased() == "head"{
                self.configFile(file: file, resp: rep)
                completionHandler(.cancel)
                if file.fileInfo.length < file.fileInfo.total{
                    DispatchQueue.global().async {
                        self.get(url: originUrl)
                    }
                }
            }else{
                switch file.fileInfo.loadType {
                case .data:
                    completionHandler(.allow)
                case .file:
                    completionHandler(.becomeDownload)
                }
            }
            
        }else{
            completionHandler(.cancel)
        }
    }
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let u  = task.originalRequest?.url else { return }
        if let err = error as NSError?{
            if err.code == NSURLErrorTimedOut{
            }
        }else{
            if (error != nil){
                self.files[u]?.delete()
                self.files[u] = nil
            }
            
        }
        self.session?.getAllTasks(completionHandler: { i in
            let c = i.filter { t in
                t.state == .running
            }.count
            print("task num \(c)")
        })
    }
    
    
    public private(set) var session:URLSession?
    
    private lazy var notificationQueue:NotificationQueue = {
        NotificationQueue(notificationCenter: self.center)
    }()
    
    public var center:NotificationCenter = NotificationCenter()
    
    public var operationQueue = OperationQueue()
    public init(configuration:URLSessionConfiguration){
        super.init()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: self.operationQueue)
    }
    
    public func download(url:URL) {
        
        if self.files[url] == nil{
            do{
                let name = try fileName(url: url)
                self.files[url] = CacheFile(name: name)
            }catch{
                return
            }
            
        }
        guard let file = self.files[url] else {
            return
        }
        var info = file.fileInfo
        info.loadType = .file
        file.writeFileInfo(info: info)
        if file.fileInfo.total == 0{
            self.head(url: url)
        } else if file.fileInfo.length < file.fileInfo.total{
            if let task = self.tasks[url]{
                if task.state == .suspended{
                    task.resume()
                }else{
                    self.get(url: url)
                }
            }else{
                self.get(url: url)
            }
        }else{
            self.operationQueue.addOperation {
                self.post(file: file)
            }
        }
    }
    public func fileName(url:URL) throws ->String{
        return try Downloader.md5(str: url.absoluteString)
    }
    public func noUseUrl(url:URL){
        self.tasks[url]?.suspend()
    }
    func configFile(file:CacheFile,resp:HTTPURLResponse) {
        var f = file.fileInfo
        if let len = resp.allHeaderFields["Content-Length"] as? String{

            f.total = UInt64(len) ?? UInt64.max
        }else{
            f.total = UInt64.max
        }
        if let ac = resp.allHeaderFields["Accept-Ranges"] as? String{
            if ac == "bytes"{
                f.acceptRange = true
            }else{
                f.acceptRange = false
            }
        }else{
            f.acceptRange = false
        }
        file.writeFileInfo(info: f)
    }
    func get(url:URL){
        guard let file = self.files[url] else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = "get"
        if(file.fileInfo.acceptRange){
            req.addValue("bytes=\(file.fileInfo.length)-", forHTTPHeaderField: "Range")
        }
        let task = self.session?.dataTask(with: req)
        self.tasks[url] = task
        task?.resume()
    }
    func head(url:URL){
        var req = URLRequest(url: url)
        req.httpMethod = "head"

        let task = self.session?.dataTask(with: req)
        self.tasks[url] = task
        task?.resume()
    }
    
    public private(set) var files:Map<URL,CacheFile> = Map()
    public private(set) var tasks:Map<URL,URLSessionTask> = Map()
    public typealias CC = (_ data: UnsafeRawPointer, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>
    public static func md5(str:String) throws ->String{
        guard let data = str.data(using: .utf8) else {throw NSError(domain: "str fail", code: 0, userInfo: nil)}
        let call:CC = {
            CC_MD5($0, $1, $2)
        }
        return Hash(data: data, digest: Int(CC_MD5_DIGEST_LENGTH), cFunc: call).hex
    }
    public static func Hash(data:Data,digest:Int,cFunc:CC)->Data{
        let p:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: data.count)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(digest))
        data.copyBytes(to: p, count: data.count)
        _ = cFunc(p, CC_LONG(data.count), result)
        let rdata = Data(bytes: result, count: digest)
        p.deallocate()
        result.deallocate()
        return rdata
    }
    public func post(file:CacheFile){
        self.center.post(name: .dataUpdate, object: file)
    }
    public func addObserver(ob:Any,sel:Selector){
        self.center.addObserver(ob, selector: sel, name: .dataUpdate, object: nil)
    }
    public static var shared:Downloader = Downloader(configuration: .default)
    
    public static func clean(){
        Downloader.shared.files.clean()
        Downloader.shared.tasks.clean()
        Downloader.shared.resetSession(configuration: .default)
    }
    public func resetSession(configuration:URLSessionConfiguration){
        Downloader.shared.session?.finishTasksAndInvalidate()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: self.operationQueue)
    }
}
extension Data{
    public var hex:String{
        self.reduce(into: "") { r, i in
            r += String(format: "%02x", i)
        }
    }
}
