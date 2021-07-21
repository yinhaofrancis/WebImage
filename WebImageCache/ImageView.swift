//
//  ImageView.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/20.
//

import UIKit

extension UIImageView{
    public func load(url:URL,defaultImg:UIImage? = nil){
        self.image = defaultImg
        if let u = self.url{
            Downloader.shared.noUseUrl(url: u)
        }
        self.url = url
        if let ob = self.observer{
            Downloader.shared.center.removeObserver(ob)
        }
        do{
            let ob = try Downloader.shared.download(url: url,callback: { f in
                f.readData { d in
                    RunLoop.main.perform(inModes: [.default]) {
                        self.image = UIImage(data: d)
                    }
                }
            })
            self.observer = ob
        }catch{
            
        }
        
    }
    public var url:URL?{
        get{
            objc_getAssociatedObject(self, "url") as? URL
        }
        set{
            objc_setAssociatedObject(self, "url", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var observer:Any?{
        get{
            objc_getAssociatedObject(self, "observer")
        }
        set{
            objc_setAssociatedObject(self, "observer", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
