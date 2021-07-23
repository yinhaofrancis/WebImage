//
//  WebImageTests.swift
//  WebImageTests
//
//  Created by wenyang on 2021/7/18.
//

import XCTest
@testable import WebImageCache
import SQLite3
class WebImageTests: XCTestCase {
    

    var data:DataPool = try! DataPool(name: "a")
    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
//        self.data = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDropTable() throws {
        let a = XCTestExpectation(description: "time out")
        
        self.data.write { db in
            try db.exec(sql: "CREATE TABLE m (Field1    INTEGER NOT NULL UNIQUE,Field2    INTEGER,PRIMARY KEY(Field1,Field2))")
            
            try db.exec(sql: "DROP table m")
            a.fulfill()
        }
        self.wait(for: [a], timeout: 10)
    }
    func testSimpleInsert() throws {
        let a = XCTestExpectation(description: "time out")
        
        self.data.write { db in
            try db.exec(sql: "CREATE TABLE IF NOT EXISTS A (Field1    INTEGER,Field2    TEXT,Field3    REAL,Field4    NUMERIC,Field5    BLOB)")
            let result = try db.query(sql: "INSERT INTO A  VALUES (?,?,?,?,?)")
            result.bind(index: 1).bind(value: 1)
            result.bind(index: 2).bind(value: "ds撒打算😗👨‍👨‍👧‍👦ds")
            result.bind(index: 3).bind(value: 3.14)
            result.bind(index: 4).bind(value: 1.414)
            result.bind(index: 5).bind(value: "dsdsd".data(using: .utf8)!)
            result.finish()
        }
        self.data.read { db in
            let result = try db.query(sql: "SELECT * from A where Field1=:name")
            result.bind(name: ":name")?.bind(value: 1)
            while try result.step() {
                print(result.column(index: 0, type: Int.self).value())
                print(result.column(index: 1, type: String.self).value())
                print(result.column(index: 2, type: Float.self).value())
                print(result.column(index: 3, type: Float.self).value())
                print(result.column(index: 4, type: String.self).value())
            }
            result.close()
            a.fulfill()
        }
        self.wait(for: [a], timeout: 10)
    }

    func testTransactions() throws{
        let sql2 = """
        BEGIN;
        DROP TABLE IF EXISTS emp_master;
        
        CREATE TABLE IF NOT EXISTS emp_master

        (emp_id INTEGER PRIMARY KEY AUTOINCREMENT,

        first_name TEXT,

        last_name TEXT,

        salary NUMERIC,

        dept_id INTEGER);

        INSERT INTO emp_master

        values (1,'Honey','Patel', 10100,1),

                (2,'Shweta','Jariwala', 19300,2),

                (3,'Vinay','Jariwala', 35100,3),

                (4,'Jagruti','Viras', 9500,2),

                (5,'Shweta','Rana',12000,3),

                (6,'sonal','Menpara', 13000,1),

                (7,'Yamini','Patel', 10000,2),

                (8,'Khyati','Shah', 50000,3),

                (9,'Shwets','Jariwala',19400,2);
        
                INSERT INTO emp_master VALUES (10,'yinhao','Francis',99999,1);

        COMMIT;
        """
        let a = XCTestExpectation(description: "time out")
        
        self.data.write { db in
            try db.exec(sql: sql2)
        }
        let f = Database.ScalarFunction(name: "A", nArg: 1) {ctx, i, a in
            ctx.ret(v: ctx.value(value: a!) + 1)
            ctx.valueNoChange(value: a!)
        }
    
        
        self.data.read { db in
            db.addScalarFunction(function: f)
            let sql2 = """
            select emp_id,A(emp_id) from emp_master;
            """
            try db.exec(sql: sql2)
            a.fulfill()
            
        }
        self.wait(for: [a], timeout: 10)
    }
    public func testTable() throws{
        let a = XCTestExpectation(description: "time out")
        self.data.read { db in
            try db.exec(sql: "select * from sqlite_master where type='table';")
            a.fulfill()
        }
        self.wait(for: [a], timeout: 10)
    }
    public func testSql() throws{
        let sql = """
            PRAGMA foreign_keys = ON;
             CREATE TABLE klb_log (
                          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                          log_comment varchar(512)
                        );

                        CREATE TABLE klb_log_food_maps (
                          uid integer,
                          did integer,
                          PRIMARY KEY (uid,did),
                          FOREIGN KEY (uid) references klb_log(id) ON DELETE CASCADE,
                          FOREIGN KEY (did) references klb_food(id) ON DELETE CASCADE
                        );

                        CREATE TABLE klb_food (
                          id integer,
                          description varchar(255),
                          PRIMARY KEY (id)
                        );
            """
        let a = XCTestExpectation(description: "time out")
        self.data.write { db in
            try db.exec(sql: sql)
            a.fulfill()
        }
        self.wait(for: [a], timeout: 10)
    }
    public func testCondition() throws{
        let c = (ConditionKey(key: "a") > ConditionKey(key: "b")) || (ConditionKey(key: "c") < ConditionKey(key: "d"))
        print(Sql.select(keys: "a","b").from(tables: "fdd").where(c).sqlCode)
    }
}


