//
//  ContentView.swift
//  example
//
//  Created by hao yin on 2021/8/19.
//

import UIKit
import Beta

class ContentView: UIView {
    override class var layerClass: AnyClass{
        return NodeGroupLayer.self
    }
    var group:NodeGroup?{
        set{
            let l = self.layer as! NodeGroupLayer
            l.nodeGroup = newValue
        }
        get{
            return (self.layer as! NodeGroupLayer).nodeGroup
        }
    }
}

