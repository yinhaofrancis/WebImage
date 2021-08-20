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
        
        let line = LinearLayout(nodes: [
            Layer(id: "a")
                .set(path: \Layer.backgroundColor, value: UIColor.red.cgColor)
                .set(path: \Layer.width, value: .parent)
                .set(path: \Layer.height, value: .pt(200)),
            Layer(id: "b")
                .set(path: \Layer.backgroundColor, value: UIColor.blue.cgColor)
                .set(path: \Layer.width, value: .parent)
                .set(path: \Layer.height, value: .pt(200)).set(path: \.heightWeight, value: 1),
            Layer(id: "c")
                .set(path: \Layer.backgroundColor, value: UIColor.green.cgColor)
                .set(path: \Layer.width, value: .parent)
                .set(path: \Layer.height, value: .pt(200))
        ])
        self.content.group = line
        
    }

    var content:Container{
        return self.view.layer as! Container
    }

}

