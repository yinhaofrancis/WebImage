//
//  ViewController.swift
//  WebImage
//
//  Created by wenyang on 2021/7/17.
//

import UIKit
import WebImageCache
class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.image.load(url: URL(string: "https://upload-images.jianshu.io/upload_images/2920524-8997016b01ca6552.jpg")!)
        
        self.image.load(url: URL(string: "http://littlesvr.ca/apng/images/GenevaDrive.webp")!)
        // Do any additional setup after loading the view.
    }


}

