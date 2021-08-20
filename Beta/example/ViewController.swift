//
//  ViewController.swift
//  example
//
//  Created by hao yin on 2021/8/19.
//

import UIKit
import Beta
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let a = NodeGroup(frame: UIScreen.main.bounds, nodes: [
            Node(frame: CGRect(x: 0, y: 0, width: 100, height: 100)),
            Node(frame: CGRect(x: 10, y: 10, width: 100, height: 100)),
            Node(frame: CGRect(x: 20, y: 20, width: 100, height: 100)),
            Node(frame: CGRect(x: 30, y: 30, width: 100, height: 100)),
            Node(frame: CGRect(x: 30, y: 30, width: 100, height: 100)),
            NodeGroup(frame: CGRect(x: 40, y: 40, width: 100, height: 100), nodes: [
                Node(frame: CGRect(x: 8, y: 8, width: 100, height: 100)),
                Node(frame: CGRect(x: 10, y: 10, width: 100, height: 100)),
                Node(frame: CGRect(x: 20, y: 20, width: 100, height: 100)),
                Node(frame: CGRect(x: 30, y: 30, width: 100, height: 100)),
                Node(frame: CGRect(x: 30, y: 30, width: 100, height: 100))
            ])
            
        ])
        a.layout()
    }

}

