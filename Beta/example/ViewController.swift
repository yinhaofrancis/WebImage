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
        self.content.nodeGroup = NodeGroup(width: .matchParent, height: .matchParent, nodes: [
            Node(width: .matchParent, height: .matchParent).set(path: \Node.layer.backgroundColor, value: UIColor.gray.cgColor),
            LinearNodeGroup(width: .matchParent, height: .matchParent, nodes: [
                Node(width: .matchParent, height: 128)
                    .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                    .set(path: \.layer.masksToBounds, value: true)
                    .set(path: \.layer.borderWidth, value: 1)
                    .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
                k,
                TextNode(text: NSAttributedString(string: "dasdasda", attributes: [.font:UIFont.systemFont(ofSize: 50),.foregroundColor:UIColor.blue]))
                    .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                    .set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10))
                    .set(path: \TextNode.name,value: "text"),
                ButtonNode(text: NSAttributedString(string: "gogo", attributes: [.font:UIFont.systemFont(ofSize: 50),.foregroundColor:UIColor.yellow]), callback: {
                    [weak self] in
                    self?.go()
                }).set(path: \ButtonNode.name,value: "ttn"),
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
                        .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10)),
                Node(width: .matchParent, height: 128)
                    .set(path: \.layer.backgroundColor, value: UIColor.orange.cgColor)
                    .set(path: \.layer.masksToBounds, value: true)
                    .set(path: \.layer.borderWidth, value: 1)
                    .set(path: \.layer.borderColor, value: UIColor.green.cgColor).set(path: \.margin, value: .init(left: 10, right: 10, top: 10, bottom: 10))
            ],isScroll: true)
            .set(path: \.direction, value: .row)
            .set(path: \.align, value: .center)
        ])
        
        
    }
    

    func go(){
        let a = self.content.nodeGroup?.findNode(name: "text") as! TextNode
        let b = self.content.nodeGroup?.findNode(name: "ttn") as! ButtonNode
        a.text = NSAttributedString(string: "sads", attributes: [.font:UIFont.systemFont(ofSize: 50),.foregroundColor:UIColor.white.withAlphaComponent(0.5)])
        b.hidden = true
        self.content.nodeGroup?.layout()
        a.width = .init(value: 300)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(2)) {
            let n = NSMutableParagraphStyle()
            n.alignment = .center
            n.lineSpacing = 200
            a.text = NSAttributedString.create {
                n
                NSAttributedString(string: "sadsasdadasd", attributes: [.font:UIFont.systemFont(ofSize: 50),.foregroundColor:UIColor.white])
                NSAttributedString(string: "sadsasdadasd", attributes: [.font:UIFont.systemFont(ofSize: 50),.foregroundColor:UIColor.black])
            }
            b.hidden = false
            self.content.nodeGroup?.layout()
        }
    }
    var content:NodeGroupView {
        return self.view as! NodeGroupView
    }

}

