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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        try web.download(url: URL(string: "http://contentcms-bj.cdn.bcebos.com/cmspic/7b5c4321988ec4af8188786d132fea24.jpeg?x-bce-process=image/crop,x_0,y_0,w_1000,h_544")!)
        RunLoop.main.run()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
