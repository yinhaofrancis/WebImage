//
//  modelTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/31.
//

import XCTest
@testable import Alpha
class modelTest: XCTestCase {

    func datapool(name:String) throws->DataBasePool{
        try DataBasePool(name: name)
    }
    override func setUpWithError() throws {
//        self.db = try self.data(name: "data")
        self.pool = try self.datapool(name: "datapool")
//        try self.pool.loadMode(mode: .ACP)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    var pool:DataBasePool!
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
//        var jj = """
//            {
//                "a":"ddd",
//                "b":131,
//                "c":{
//                    "q":"12",
//                    "f":13
//                },
//                "d":[{
//                    "q":"123",
//                    "f":133
//                },{
//                    "q":"123",
//                    "f":1337
//                }]
//            }
//            """
//        let json = try! JSONSerialization.jsonObject(with: jj.data(using: .utf8)!, options: .fragmentsAllowed)
//        let djson:JSON = JSON.json(json)
//        print(djson.d[1].f)
//        let testjson:JSON = [
//            "1":1,
//            "2":"sdsd",
//            "3":3.0,
//            "dddd":[
//                "d":0,
//                "8":7
//            ],
//            "cc":
//                [
//                    ["d":1,"8":7],
//                    ["d":3,"8":7],
//                    ["d":5,"8":7]
//                ]
//]
//        print(testjson.15)
//        print(testjson.cc[2].d)
//        print(testjson.json)
//        print(testjson.dddd.8)
//        let a:Int = testjson.dddd.8
//        let b:Int = testjson.cc[2].d
//        print(a)
//        print(b)
//        print(testjson)

        let j:JSON = ["sdada":"dasdasd","dd":1,"dsdsd":["dd","d"],"sad":"dasdasd","k":["a":1]]
//        print(j)
        
        self.pool.write { db in
            try db.insert("a", j)
        }
        self.pool.writeSync { b in
            let j = try b.query(name: "a")
            for i in j{
                print(i.dd)
                print(i.k.a)
                print(i.dsdsd[1])
            }
        }
//        print(l.dddd.d)
//        print(l.cc[0].8)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func json(j:JSON){
        print(j)
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

