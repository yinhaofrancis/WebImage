//
//  AlphaTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/7/27.
//

import XCTest
@testable import Alpha

class AlphaTests: XCTestCase {

    func data(name:String)throws ->Database{
        try Database(url: Env.home().appendingPathComponent("name"))
    }
    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        print(try Env.home())
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateAndDropTable() throws {
        let db = try self.data(name: "a")
        let sql = """
        CREATE TABLE pp (
            Field1 INTEGER,
            Field2 TEXT UNIQUE,
            Field3    BLOB NOT NULL DEFAULT 'k',
            PRIMARY KEY(Field1 AUTOINCREMENT)
            );
            CREATE TABLE sds (
                Field1    INTEGER,
                Field2    TEXT DEFAULT 'd' UNIQUE COLLATE BINARY,
                FOREIGN KEY(Field2) REFERENCES pp(Field1) on delete cascade,
                PRIMARY KEY(Field2)
            );
"""
        
        try db.exec(sql: sql)
        let pp = try db.tableInfo(name: "pp")
        for i in pp {
            if i.key == "Field1"{
                XCTAssert(i.value.cid == 0, "index fail")
                XCTAssert(i.value.name == "Field1", "name fail")
                XCTAssert(i.value.type == "INTEGER", "type fail")
                XCTAssert(i.value.dlft_value == "", "default fail")
                XCTAssert(i.value.pk == 0, "default fail")
                XCTAssert(i.value.notnull == 0, "default fail")
            }
            if i.key == "Field2"{
                XCTAssert(i.value.cid == 0, "index fail")
                XCTAssert(i.value.name == "Field2", "name fail")
                XCTAssert(i.value.type == "Text", "type fail")
                XCTAssert(i.value.dlft_value == "", "default fail")
                XCTAssert(i.value.pk == 0, "default fail")
                XCTAssert(i.value.notnull == 0, "default fail")
            }
        }
    }

    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
public class Env{
    public static func home()throws->URL{
        guard let u = URL(string: NSHomeDirectory()) else { throw NSError(domain: "no home", code: 0, userInfo: nil) }
        return u
    }
}
