//
//  AppDelegate.swift
//  WebImage
//
//  Created by wenyang on 2021/7/17.
//

import UIKit
import WebImageCache

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        let a = mmm.asy(T: mv.self, path: \mv.i)
        print(a)
        return true
    }

//    func a<T:SQLCode>(sql:T)->T {
//        let align = sql.normalKey.map({MemoryLayout.alignment(ofValue: $0.1)}).max(by: {$0 > $1}) ?? 8
//        let a = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<T>.stride, alignment: align)
//        let map = sql.normalKey
//        for i in 0 ..< map.count {
//
//            a.storeBytes(of: 2, toByteOffset: align * align, as: map[i].1.Self.self)
//        }
//        a.storeBytes(of: 1, as: Int64.self)
//
//        a.storeBytes(of: "dsdsds", toByteOffset: 16, as: String.self)
//        return a.assumingMemoryBound(to: T.self).pointee
//    }
    

}
class mmm{
    static func asy<T:SQLCode>(T:T.Type,path:AnyKeyPath)->T{
        var a = T.init()
        a[keyPath: (path as! WritableKeyPath<T,Int64>)] = 10
        return a
    }
}
class mv:SQLCode{
    required init() {}
    static var tableName: String = "fff"
    
    static var explictKey: Bool = false
    
    @Key("ddd")
    @PrimaryKey
    var i:Int64 = 0
    var j:Int32 = 0
    var s:String = ""

}


extension SQLCode{
  
}
