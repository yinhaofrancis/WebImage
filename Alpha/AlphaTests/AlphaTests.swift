//
//  AlphaTests.swift
//  AlphaTests
//
//  Created by hao yin on 2021/7/27.
//

import XCTest
@testable import Alpha

class AlphaTests: XCTestCase {

    struct model:SQLCode{
        static var tableName: String = "model"
        
        @PrimaryKey
        @Column(\model.a)
        var a:Int = 0
        
        @Key("b_key")
        @Column(\model.b)
        var b:String = ""
        
        @Column(\model.c)
        var c:Data = Data()
        
        @Default("3.14")
        @Column(\model.d)
        var d:Double = 0.0
        
        @Column(\model.f)
        var f:Int32 = 0
        
        @Column(\model.g)
        var g:Int64 = 0
        
    
        @NullableColumn(\model.oa)
        var oa:Int? = nil
        
        @Key("ob_key")
        @NullableColumn(\model.ob)
        var ob:String? = nil
        
        @NullableColumn(\model.oc)
        var oc:Data? = nil
        
        @NullableColumn(\model.od)
        var od:Double? = nil

        @NullableColumn(\model.of)
        var of:Int32? = 0
        
        @NullableColumn(\model.og)
        var og:Int64? = 1
    }
    struct model2:SQLCode{
        static var tableName: String = "model2"
        
        @PrimaryKey
        @Key("Identify")
        @Column(\model2.a2)
        var a2:Int = 0
        
        
        @ForeignKey(remoteTable: "model", remoteKey: "a", onDelete: .SET_DEFAULT, onUpdate: .CASCADE)
        @Default("0")
        @Key("IdentifyRef")
        @Column(\model2.a)
        var a:Int = 0
        
    }
    func data(name:String)throws ->Database{
        try Database(url: Env.home().appendingPathComponent(name))
    }
    func datapool(name:String) throws->DataBasePool{
        try DataBasePool(name: name)
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
            Field3    BLOB NOT NULL DEFAULT k,
            PRIMARY KEY(Field1 AUTOINCREMENT)
            );
            CREATE TABLE sds (
                Field1    INTEGER,
                Field2    TEXT DEFAULT d UNIQUE COLLATE BINARY,
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
                XCTAssert(i.value.pk == 1, "default fail")
                XCTAssert(i.value.notnull == 0, "default fail")
            }
            if i.key == "Field2"{
                XCTAssert(i.value.cid == 1, "index fail")
                XCTAssert(i.value.name == "Field2", "name fail")
                XCTAssert(i.value.type == "TEXT", "type fail")
                XCTAssert(i.value.dlft_value == "", "default fail")
                XCTAssert(i.value.pk == 0, "default fail")
                XCTAssert(i.value.notnull == 0, "default fail")
            }
            if i.key == "Field3"{
                XCTAssert(i.value.cid == 2, "index fail")
                XCTAssert(i.value.name == "Field3", "name fail")
                XCTAssert(i.value.type == "BLOB", "type fail")
                XCTAssert(i.value.dlft_value == "k", "default fail")
                XCTAssert(i.value.pk == 0, "default fail")
                XCTAssert(i.value.notnull == 1, "default fail")
            }
        }
        let fp = try db.tableForeignKeyInfo(name: "sds")
        for i in fp{
            XCTAssert(i.key == "Field2", "name fail")
            XCTAssert(i.value.id == 0 , "name fail")
            XCTAssert(i.value.from == "Field2", "from fail")
            XCTAssert(i.value.to == "Field1", "to fail")
            XCTAssert(i.value.table == "pp", "ref table fail")
            XCTAssert(i.value.onUpdate == .NO_ACTION, "name fail")
            XCTAssert(i.value.onDelete == .CASCADE, "name fail")
        }
        try db.exec(sql: "drop table sds;drop table pp;")
        try db.exec(sql: sql)
        try db.exec(sql: "drop table sds;drop table pp;")
    }
    func testCreateTableByModel() throws {
        
        let dm = try self.data(name: "data")
        dm.foreignKey = true
        try dm.drop(modelType: model2.self)
        try dm.drop(modelType: model.self)
        try dm.create(obj: model())
        try dm.create(obj: model2())
        for i in 0 ..< 10 {
            try dm.insert(model: model(a: i,
                                       b: "ddd\(i)",
                                       c: "dd\(i * 2)".data(using: .utf8)!
                                       , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
        }
        for i in 0 ..< 10 {
            do {
                try dm.insert(model: model(a: i, b: "ddd", c: "dd".data(using: .utf8)!, d: 0.9))
            } catch {
                break;
            }
            XCTAssert(false, "table primary constaint fail")
        }
        for i in 0 ..< 10 {
            try dm.insert(model: model2(a2: i, a: i))
        }
        var f = false
        do {
            try dm.insert(model: model2(a2: 100, a:100))
        } catch  {
            f = true
        }
        
        XCTAssert(f, "table foreign keu constaint fail")
        let r = try dm.select(request: FetchRequest(table: model.self))
        print(r)
        for i in 0..<10 {
            XCTAssert(r[i].a == i,"\(r[i].a)")
            XCTAssert(r[i].b == "ddd\(i)",r[i].b)
            XCTAssert(String(data: r[i].c, encoding: .utf8)! == "dd\(i * 2)",String(data: r[i].c, encoding: .utf8)!)
            XCTAssert(r[i].d == 0.9 + Double(i),"\(r[i].d )")
            XCTAssert(r[i].f == 0)
            XCTAssert(r[i].g == 0)
            XCTAssert(r[i].oa == i + 1)
            XCTAssert(r[i].ob == "")
            XCTAssert(r[i].oc?.count == 0)
            XCTAssert(r[i].od == 0.0)
            XCTAssert(r[i].of! == 10 - i)
            XCTAssert(r[i].og == 1)
        }
        let r2 = try dm.select(request: FetchRequest(table: model2.self))
        for i in 0..<10 {
            XCTAssert(r2[i].a == i)
            XCTAssert(r2[i].a2 == i)
        }
        var up = r[0]
        up.og = nil
        up.oc = "abc".data(using: .utf8)
        up.ob = "abc"
        try dm.update(model: up)
        let rr = try dm.select(model: model(a: 0))
        XCTAssert(rr != nil)
        XCTAssert(rr?.og == 0)
//        XCTAssert(rr[0].a == 100)
        
        
        XCTAssert(String(data: rr!.oc!, encoding: .utf8)! == "abc")
        XCTAssert(rr?.ob == "abc")
        dm.close()
    }
    func testSelect() throws{
        let dm = try self.data(name: "data")
        dm.foreignKey = true
        try dm.drop(modelType: model2.self)
        try dm.drop(modelType: model.self)
        try dm.create(obj: model())
        try dm.create(obj: model2())
        for i in 0 ..< 100 {
            try dm.insert(model: model(a: i,
                                       b: "ddd\(i)",
                                       c: "dd\(i * 2)".data(using: .utf8)!
                                       , d: 0.9 + Double(i),oa: i + 1,of: 10 - Int32(i)))
        }
        let request = FetchRequest(table: model.self, condition: ConditionKey("a") < "90" && ConditionKey("a") > "10", page: Page(offset: 10, limit: 20), order: [.desc("a")])
        let r = try dm.select(request: request)
        for i in 0 ..< r.count {
            XCTAssert(r[i].a == 79 - i)
        }
        dm.close()
    }
}
public class Env{
    public static func home()throws->URL{
        guard let u = URL(string: NSHomeDirectory()) else { throw NSError(domain: "no home", code: 0, userInfo: nil) }
        return u
    }
}