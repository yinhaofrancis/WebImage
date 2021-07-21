//
//  ImageView.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/20.
//

import UIKit

extension UIImageView{
    public func load(url:URL,size:CGSize? = nil,defaultImg:UIImage? = nil){
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
                    let a = ImageProcess()
                    a.update(data: d, final: true)
                    let image = a.image
                    RunLoop.main.perform(inModes: [.default]) {
                        self.image = image
                        
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

public class ImageProcess{
    var imageSource:CGImageSource
    public init() {
        imageSource = CGImageSourceCreateIncremental(nil)
    }
    public func update(data:Data,final:Bool){
        CGImageSourceUpdateData(self.imageSource, data as CFData, final)
    }
    public var fileSize:UInt{
        let a = CGImageSourceCopyProperties(self.imageSource, nil) as! [String:UInt]
        return a["FileSize"] ?? 0
    }
    public subscript(index:Int)->CGImage?{
        CGImageSourceCreateImageAtIndex(self.imageSource, index, nil)
    }
    public func property(index:Int)->CFDictionary?{
        CGImageSourceCopyPropertiesAtIndex(self.imageSource, index, nil)
    }
    public subscript(index:Int,size:CGSize)->CGImage?{
        let max = max(size.width, size.height)
        return CGImageSourceCreateThumbnailAtIndex(self.imageSource, index, [
            kCGImageSourceThumbnailMaxPixelSize:max
        ] as CFDictionary)
    }
    public var duration:TimeInterval{
        var sum:TimeInterval = 0
        for i in 0..<self.count {
            sum += self.duration(index: i)
        }
        return sum
    }
    private func duration(index:Int)->TimeInterval{
        
        guard let d = self.property(index: index) as? [String:Any] else { return 0}
        if (d["{GIF}"] != nil){
            guard let ad = d["{GIF}"] as? [String:Double] else { return 0 }
            if let durStr = ad["DelayTime"]{
                return TimeInterval(durStr)
            }
            if let durStr = ad["UnclampedDelayTime"]{
                return TimeInterval(durStr)
            }
        }
        if (d["{PNG}"] != nil){
            guard let ad = d["{PNG}"] as? [String:Double] else { return 0 }
            if let durStr = ad["DelayTime"]{
                return TimeInterval(durStr)
            }
            if let durStr = ad["UnclampedDelayTime"]{
                return TimeInterval(durStr)
            }
        }
        if (d["{WebP}"] != nil){
            guard let ad = d["{WebP}"] as? [String:Double] else { return 0 }
            if let durStr = ad["DelayTime"]{
                return TimeInterval(durStr)
            }
            if let durStr = ad["UnclampedDelayTime"]{
                return TimeInterval(durStr)
            }
        }
        return 0
    }
    public var count:Int{
        CGImageSourceGetCount(self.imageSource)
    }
    public var image:UIImage?{
        if(self.count == 0){
            return nil
        }
        if self.count == 1{
            return self.image(index: 0)
        }else{
            var images:[UIImage] = []
            for i in 0 ..< self.count {
                if let img = image(index: i){
                    images.append(img)
                }
            }
            return UIImage.animatedImage(with: images, duration: self.duration)
        }
    }
    public func image(index:Int)->UIImage?{
        guard let img = self[index] else { return nil }
        return UIImage(cgImage: img, scale: UIScreen.main.scale, orientation: .up)
    }
}
