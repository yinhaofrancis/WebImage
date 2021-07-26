//
//  testRestore.swift
//  WebImageTests
//
//  Created by wenyang on 2021/7/25.
//

import XCTest
@testable import WebImageCache
import SQLite3
extension Int{

}
class testRestore: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testRestore() throws {
        let u = try DataBasePool.checkDir().appendingPathComponent("a")
        let f = try FileHandle(forWritingTo: u)
        f.write(Data(count: 109))
        try f.close()
        try DataBasePool.restore(name: "a")
        let data = try! DataBasePool(name: "a")
        data.readSync { db in
            try db.exec(sql: "select * from n")
        }
    }
    

    func testBackup() throws {
        let data = try! DataBasePool(name: "a")
        let a = XCTestExpectation(description: "time out")
        let model = DatabaseModel(pool: data)
        for _ in 0 ..< 20 {
            let nn = n()
            nn.name =
                """
        Dadad
        ada

        asds
        """
            nn.ds = Int(arc4random())
            nn.d = "abc".data(using: .utf8)
            nn.ms = "cccc"
            model.insert(model: nn)
        }
        data.read { db in
            try db.exec(sql: "select * from n")
        }
        
        Timer.scheduledTimer(withTimeInterval: 40, repeats: false) { i in
            a.fulfill()
        }
        self.wait(for: [a], timeout: 80)
    }
    
    func testDelete(){
        let a = XCTestExpectation(description: "time out")
        let data = try! DataBasePool(name: "a")
        func create(){
            let model = DatabaseModel(pool: data)
            model.create(obj: n())
            data.readSync { db in
                try db.exec(sql: "select * from n")
            }
        }
        func insert(){
            let model = DatabaseModel(pool: data)
            let nn = n()
            nn.name =
                """
        Dadad
        ada

        asds
        """
            nn.ds = 123
            nn.d = "abc".data(using: .utf8)
            nn.ms = "cccc"
            model.insert(model: nn)
            data.read { db in
                try db.exec(sql: "select * from n")
            }
        }

        func update(){
            let model = DatabaseModel(pool: data)
            let nn = n()
            nn.name =
                """
        Dadad
        ada

        asds
        """
            nn.ds = 123
            nn.d = "abc".data(using: .utf8)
            nn.ms = "updates"
            model.update(model: nn)
            data.read { db in
                try db.exec(sql: "select * from n")
            }
        }
        func updateCondition(){
            let model = DatabaseModel(pool: data)
            model.update(model: ["name":"testUpdateCondition"],
                         table: n.self, condition: ConditionKey(key: "ms") == "@u" && ConditionKey(key: "_ds") == ConditionKey(key: "123"),
                         bind: ["u":"updates"])
            
            
            model.update(model: ["name":"testUpdate"],
                         table: n.self, condition: ConditionKey(key: "ms") == "@u" && ConditionKey(key: "_ds") == ConditionKey(key: "123"),
                         bind: ["u":"updates"])
            data.read { db in
                try db.exec(sql: "select * from n")
            }
        }

        func delete(){
            let model = DatabaseModel(pool: data)
            let m = n()
            m.ds = 123
            model.delete(model: m)
            
            data.read { db in
                print("delete")
                try db.exec(sql: "select * from n")
            }
        }

        func deleteCondition(){
            let model = DatabaseModel(pool: data)
            let m = n()
            m.ds = 123
            model.delete(table: n.self, condition: ConditionKey("_ds") == "123", bind: [:])
            
            data.read { db in
                print("delete")
                try db.exec(sql: "select * from n")
            }
        }


        create()
        insert()
        update()
        deleteCondition()
        insert()
        update()
        delete()
        insert()
        update()
        data.queue.async {
            a.fulfill()
        }
        self.wait(for: [a], timeout: 40)
        
    }
    

    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
