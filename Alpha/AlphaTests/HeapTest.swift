//
//  HeapTest.swift
//  AlphaTests
//
//  Created by hao yin on 2021/8/17.
//

import XCTest
@testable import Alpha
class HeapTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeap() throws {
        let a = MaxHeap<UInt32>()
        
   
        for _ in 0..<100 {
            a.insert(object: arc4random() % 1000)
            print(a)
        }
        
        print(a)
        var array:[UInt32] = []
        for _ in 0..<100 {
            array.append(a.remove())
        }
        print(array)
        for i in 0 ..< (array.count - 1) {
            XCTAssert(array[i] >= array[i + 1])
        }
    }
    func testMinHeap() throws {
        let a = MinHeap<UInt32>()
        
   
        for _ in 0..<100 {
            a.insert(object: arc4random() % 1000)
            print(a)
        }
        
        print(a)
        var array:[UInt32] = []
        for _ in 0..<100 {
            array.append(a.remove())
        }
        print(array)
        for i in 0 ..< (array.count - 1) {
            XCTAssert(array[i] <= array[i + 1])
        }
    }
}
