//
//  WebImageTests.swift
//  WebImageTests
//
//  Created by wenyang on 2021/7/18.
//

import XCTest
@testable import WebImageCache
class WebImageTests: XCTestCase {
    
    var web:Downloader = Downloader(configuration: .default)

    var data:Database?
    override func setUpWithError() throws {
        self.data = try Database(group: DispatchGroup(), queue: .main, name: "a")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDropTable() throws {
        
        try self.data?.exec(sql: "CREATE TABLE m (Field1    INTEGER NOT NULL UNIQUE,Field2    INTEGER,PRIMARY KEY(Field1,Field2))")
        
        try self.data?.exec(sql: "DROP table m")
    }
    func testSimpleInsert() throws {
        
        
        try self.data?.exec(sql: "CREATE TABLE IF NOT EXISTS A (Field1    INTEGER,Field2    TEXT,Field3    REAL,Field4    NUMERIC,Field5    BLOB)")
        let result = try self.data?.query(sql: "INSERT INTO A  VALUES (?,?,?,?,?)")
        result?.writeParam(index: 1, param: Int32(1))
        result?.writeParam(index: 2, param: "2")
        result?.writeParam(index: 3, param: Double(3.14))
        result?.writeParam(index: 4, param: Double(1.414))
        result?.writeParam(index: 5, param: "12312313".data(using: .utf8)!)
        try result?.next()
        result?.close()
        print(self.data?.url)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
