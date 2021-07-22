import Foundation

let session = URLSession(configuration: .default)

public enum WebServiceError:Error{
    case success
    case jsonFail(URLRequest)
    case timeout(URLRequest)
    case httpStatus(Int,URLRequest)
    case loseConnect(URLRequest)
    case error(Error)
    case unknowedError
}
extension Notification.Name{
    public static var updateToken:Notification.Name = .init("AppConfig.updateToken")
}

open class WebService<U:Codable,D:Codable>{
    
    public var header:[String:String]{
        
        let headerdic = [
            "platform":self.platform,
        ]
        do {
            guard let eq = String(data: try self.jsonEncoder.encode(headerdic), encoding: .utf8) else {
                return [:]
            }
            return [
                        "equipment":"ios",
                        "Content-Type":"application/json",
                        "mobileModel":eq]
        } catch  {
            return [:]
        }
        
        
    }
    public var platform:String{
        var size:Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        
        let u:UnsafeMutablePointer<UInt8> = .allocate(capacity: size)
        
        sysctlbyname("hw.machine", u, &size, nil, 0);
        
        let string = String(cString: u)
        u.deallocate()
        
        return string
        
    }
    public typealias callback = (WebServiceError)->Void


    
    public var name: String = ""

    
    public var jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()
    
    public var jsonEncoder = JSONEncoder()
    
    open var body:U?
    open var response:D?
    open var callback:callback?
    public func post(url:String,callback: callback?){
        var domain = URL(string: "https://app.5eplay.com/api/")!
        domain.appendPathComponent(url)
        var req = URLRequest(url: domain)
        req.httpMethod = "post"
        if let b = self.body{
            do {
                req.httpBody = try self.jsonEncoder.encode(b)
            } catch  {
                callback?(.error(error))
            }
            
        }
        self.request(request: req, callback: callback)
    }
    public func get(url:String,param:String,callback:callback? = nil){
        var domain =  URL(string: "https://app.5eplay.com/api/")!
        domain.appendPathComponent(url)
        var c = URLComponents(string: domain.absoluteString)
        c?.query = param
        var req = URLRequest(url: c!.url!)
        req.httpMethod = "get"
        self.request(request: req, callback: callback)
    }
    public func request(request:URLRequest,callback: callback?  = nil){
        var req = request
        self.callback = callback
        req.allHTTPHeaderFields = self.header
        session.dataTask(with: req) { data, response, e in
            guard let http = response as? HTTPURLResponse else {
                guard let error = e as NSError? else {
                    callback?(.unknowedError)
                    return
                }
                switch(error.code){
                case NSURLErrorCannotFindHost:
                    callback?(.loseConnect(req))
                    return
                case NSURLErrorTimedOut:
                    callback?(.timeout(req))
                    return
                default:
                    callback?(.error(error))
                    return
                }
            }
            if http.statusCode >= 200 && http.statusCode < 300{
                if let d = data{
                    do {
                        self.response = try self.jsonDecoder.decode(D.self, from: d)
                        callback?(.success)
                    } catch  {
                        print(error)
                        callback?(.jsonFail(req))
                    }
                    return
                }
            }else{
                callback?(.httpStatus(http.statusCode, req))
                return
            }
        }.resume()
    }
    public func retry(error:WebServiceError){
        switch error {
        case .success:
            break
        case let .jsonFail(req):
            self.request(request: req, callback: self.callback)
            break
        case let .timeout(req):
            self.request(request: req, callback: self.callback)
            break
        case .error:
            break
        case let .httpStatus(_, req):
            self.request(request: req, callback: self.callback)
            break
        case .unknowedError:
            break
        case let .loseConnect(req):
            self.request(request: req, callback: self.callback)
        }
    }
}
