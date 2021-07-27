//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3

 
public protocol SQLCode{
    static var tableName:String { get }
    init()
}
