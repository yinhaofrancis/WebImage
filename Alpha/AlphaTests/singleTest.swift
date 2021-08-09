//
//  singleTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/9.
//

import XCTest
@testable import Alpha
class singleTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    var pool:DataBasePool!
    func testExample() throws {
        self.pool = try DataBasePool(name: "dd")
        
        self.pool.write { db in
            let version = db.version + 1
            try db.setVersion(version: version)
            XCTAssert(version == db.version)
            print("_+_+_+_+_+_")
            print(version,db.version)
        }
        self.pool.writeSync { db in
            
            
            
            
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
