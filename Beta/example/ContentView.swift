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
        return Container.self
    }
}
