//
//  Table.swift
//  WebImageCache
//
//  Created by hao yin on 2021/7/23.
//

import Foundation
import SQLite3


public enum ColumeType:String{
    case integer
    case double
    case text
    case blob
}

public struct TableKey{
    let name:String
    let type:ColumeType
    var notnull,unique,primary,autoincreament:Bool
    var `default`:String
    
}

public struct TableBody{
    let colume:[TableKey]
}
public protocol SQLCode {
    @BuildTable var table:TableBody { get }
}
extension SQLCode{
//    func tableBody(db:Database)->TableBody{
//        
//    }
}
@resultBuilder
public enum BuildTable{
    public static func buildBlock(_ components: TableKey...) -> TableBody {
        TableBody(colume: components)
    }
}



