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
        
        let k = ImageNode(image: #imageLiteral(resourceName: "s").cgImage!).set(path: \ImageNode.layer.borderWidth, value: 1)
        print(k)
        k.layer.contentsGravity = .bottomLeft
        k.layer.masksToBounds = true
        k.layer.cornerRadius = 8
        k.margin = .init(left: 0, right: 0, top: 0, bottom: 0)
        self.content.nodeGroup = LinearNodeGroup(width: 500, height: 500, nodes: [
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),Node(width: .matchParent, height: 128)
                    .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                    .set(path: \.layer.masksToBounds, value: true)
                    .set(path: \.layer.borderWidth, value: 1)
                    .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            Node(width: .matchParent, height: 128)
                .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                .set(path: \.layer.masksToBounds, value: true)
                .set(path: \.layer.borderWidth, value: 1)
                .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
            k,
        ],isScroll: true)
        .set(path: \.direction, value: .row)
        .set(path: \.align, value: .end)
        
    }
    
    var content:NodeGroupView {
        return self.view as! NodeGroupView
    }

}

