//
//  ViewController.swift
//  threeDisplay
//
//  Created by hao yin on 2021/8/19.
//

import UIKit
import SceneKit
class ViewController: UIViewController {

    @IBOutlet weak var scene: SCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let scr = SCNScene(named: "a.scnassets/dd.scn")
        print(scr)
        // Do any additional setup after loading the view.
        self.scene.scene = scr
    }


}

