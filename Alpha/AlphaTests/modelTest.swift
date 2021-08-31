//
//  modelTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/31.
//

import XCTest
@testable import Alpha
class modelTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var l = JSON(json: [
                        "1":1,
                        "2":"sdsd",
                        "3":3.0,
                        "dddd":[
                            "d":0,
                            "8":7
                        ],
                        "cc":
                            [
                                ["d":0,"8":7],
                                ["d":0,"8":7],
                                ["d":0,"8":7]
                            ]
        ])
        
        var jj = """
            {
                "a":"ddd",
                "b":131,
                "c":{
                    "q":"12",
                    "f":13
                },
                "d":[{
                    "q":"123",
                    "f":133
                },{
                    "q":"123",
                    "f":133
                }]
            }
            """
        let json = try! JSONSerialization.jsonObject(with: jj.data(using: .utf8)!, options: .fragmentsAllowed)
        
        let testjson = JSON(json: json as! [String : Any])
        
        var n:String = l.2
        print(n)
        var c:String = l.dddd.d
        var i:Int = l.cc
        
        let a:String = testjson.a
        let bb:Int = testjson.b
        let bbb:String = testjson.b
        let bbbb:JSON = testjson.d[1]
        let bbbbb:String = testjson.c.q
        print(a,bb,bbb,bbbb,bbbbb)
        print(testjson.jsonContent)
//        print(l.dddd.d)
//        print(l.cc[0].8)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
@dynamicMemberLookup
public struct JSON{
    private var json:[String:Any] = [:]
    public init (json:[String:Any]){
        for i in json {
            if let dc = i.value as? Dictionary<String,Any>{
                self.json[i.key] = JSON(json: dc)
            }else if let dc = i.value as? Array<Any>{
                self.json[i.key] = JSON.parse(json:dc)
            }else{
                self.json[i.key] = i.value
            }
        }
    }
    public static func parse(json:[Any])->[Any]{
        var a:Array<Any> = []
        for i in json {
            if let dc = i as? Dictionary<String,Any>{
                a.append(JSON(json: dc))
            }else{
                a.append(i)
            }
        }
        return a
    }
    public static func gen(json:[Any])->[Any]{
        var a:Array<Any> = []
        for i in json {
            if let dc = i as? JSON{
                a.append(dc.jsonContent)
            }else{
                a.append(i)
            }
        }
        return a
    }
    public var jsonContent:[String:Any]{
        var dic:[String:Any] = [:]
        for i in self.json {
            if let j = i.value as? JSON{
                dic[i.key] = j.jsonContent
            }else if let a = i.value as? Array<Any>{
                dic[i.key] = JSON.gen(json:a)
            }else{
                dic[i.key] = i.value
            }
        }
        return dic
    }
    public subscript(dynamicMember dynamicMember:String)->Any?{
        get{
            return json[dynamicMember]
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->String{
        get{
            guard let v = json[dynamicMember] else {
                return ""
            }
            return "\(v)"
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->JSON{
        get{
            guard let v = json[dynamicMember] as? JSON else {
                return JSON(json: [:])
            }
            return v
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Int{
        get{
            if let v = json[dynamicMember] as? String {
                return Int(v) ?? 0
            }
            if let v = json[dynamicMember] as? Int {
                return v
            }
            if let v = json[dynamicMember] as? Int8 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? Int16 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? Int32 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? Int64 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? UInt {
                return Int(v)
            }
            if let v = json[dynamicMember] as? UInt8 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? UInt16 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? UInt32 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? UInt64 {
                return Int(v)
            }
            if let v = json[dynamicMember] as? Float {
                return Int(v)
            }
            if let v = json[dynamicMember] as? Double {
                return Int(v)
            }
            if let v = json[dynamicMember] as? NSNumber {
                return v.intValue
            }
            return 0
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    public subscript(dynamicMember dynamicMember:String)->Double{
        get{
            if let v = json[dynamicMember] as? String {
                return Double(v) ?? 0
            }
            if let v = json[dynamicMember] as? Int {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Int8 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Int16 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Int32 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Int64 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? UInt {
                return Double(v)
            }
            if let v = json[dynamicMember] as? UInt8 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? UInt16 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? UInt32 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? UInt64 {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Float {
                return Double(v)
            }
            if let v = json[dynamicMember] as? Double {
                return v
            }
            if let v = json[dynamicMember] as? NSNumber {
                return v.doubleValue
            }
            return 0
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    
    public subscript(dynamicMember dynamicMember:String)->Bool{
        get{
            if let v = json[dynamicMember] as? String {
                return v == "true" ? true : false
            }
            if let v = json[dynamicMember] as? Int {
                return v > 0
            }
            if let v = json[dynamicMember] as? Int8 {
                return v > 0
            }
            if let v = json[dynamicMember] as? Int16 {
                return v > 0
            }
            if let v = json[dynamicMember] as? Int32 {
                return v > 0
            }
            if let v = json[dynamicMember] as? Int64 {
                return v > 0
            }
            if let v = json[dynamicMember] as? UInt {
                return v > 0
            }
            if let v = json[dynamicMember] as? UInt8 {
                return v > 0
            }
            if let v = json[dynamicMember] as? UInt16 {
                return v > 0
            }
            if let v = json[dynamicMember] as? UInt32 {
                return v > 0
            }
            if let v = json[dynamicMember] as? UInt64 {
                return v > 0
            }
            if let v = json[dynamicMember] as? Float {
                return v > 0
            }
            if let v = json[dynamicMember] as? Double {
                return v > 0
            }
            if let v = json[dynamicMember] as? NSNumber {
                return v.boolValue
            }
            return false
        }
        set{
            json[dynamicMember] = newValue
        }
    }
    public subscript<T>(dynamicMember dynamicMember:String)->[T]{
        get{
            if let v = json[dynamicMember] as? Array<T>{
                return v
            }else{
                return []
            }
        }
        set{
            json[dynamicMember] = newValue
        }
    }
} 
