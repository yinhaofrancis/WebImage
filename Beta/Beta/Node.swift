////
////  Node.swift
////  Beta
////
////  Created by hao yin on 2021/8/19.
////
//
import QuartzCore
import ImageIO
#if os(iOS)
import UIKit
#endif

public protocol Drawable{
    var layer:CALayer { get }
}
extension Drawable{
    public func set<V>(path:ReferenceWritableKeyPath<Self,V>,value:V)->Self{
        self[keyPath: path] = value
        return self
    }
}
public struct Size:ExpressibleByFloatLiteral,ExpressibleByIntegerLiteral,Equatable{
    public init(integerLiteral value: Int) {
        self.init(value: CGFloat(value))
    }
    
    public typealias IntegerLiteralType = Int
    
    public init(floatLiteral value: Double) {
        self.init(value: CGFloat(value))
    }
    public typealias FloatLiteralType = Double
    
    public let value:CGFloat
    public let weight:CGFloat
    public let max:CGFloat
    public let min:CGFloat
    public init(value:CGFloat,max:CGFloat = .infinity,min:CGFloat = 0,weight:CGFloat = 0){
        self.value = value
        self.max = max
        self.weight = weight
        self.min = min
    }
    public var size:CGFloat{
        return self.constaint(size: self.value)
    }
    public func constaint(size:CGFloat,delta:CGFloat = 0,weightSum:CGFloat = 1)->CGFloat{
        let value = size + delta * weight / weightSum
        if self.max < value{
            return self.max
        }else if self.min > value{
            return self.min
        }else{
            return value
        }
    }
    public static func == (lhs: Size, rhs: Size) -> Bool{
        lhs.max == rhs.max && lhs.min == rhs.min && lhs.value == rhs.value
    }
    public static var matchContent:Size = .init(value: 0, max: 0, min: 0)
    public static var matchParent:Size = .init(value: 0,max: .infinity,min: 0)
}
public struct Edge{
    let left:CGFloat
    let right:CGFloat
    let top:CGFloat
    let bottom:CGFloat
    
    public init(left:CGFloat = 0,right:CGFloat = 0,top:CGFloat = 0,bottom:CGFloat = 0){
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }
}


extension CGRect{
    public var left:CGFloat{
        get{
            return self.minX
        }
        set{
            self.origin.x = newValue
            self.size.width = newValue - self.origin.x
        }
    }
    
    public var top:CGFloat{
        get{
            return self.minY
        }
        set{
            self.origin.y = newValue
            self.size.height = newValue - self.origin.y
        }
    }
    public var bottom:CGFloat{
        get{
            return self.maxY
        }
        set{
            self.size.height = newValue - self.minY
        }
    }
    public var right:CGFloat{
        get{
            return self.maxX
        }
        set{
            self.size.width = newValue - self.minX
        }
    }
    public var edge:Edge{
        get{
            Edge(left: self.left, right: self.right, top: self.top, bottom: self.bottom)
        }
        set{
            self.left = newValue.left
            self.right = newValue.right
            self.top = newValue.top
            self.bottom = newValue.bottom
        }
    }
    public init(left:CGFloat,right:CGFloat,top:CGFloat,bottom:CGFloat){
        self.init(x: left, y: top, width: right - left, height: bottom - top)
    }
}

public class Node:Equatable,Drawable{
    public var layer: CALayer = CALayer()
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }

    public var frame:CGRect = .zero
    public var width:Size
    public var height:Size
    public weak var parent:Node?
    public var margin:Edge = .init()
    public init(width:Size,height:Size,parent:Node? = nil) {
        self.width = width
        self.height = height
        self.parent = parent
        self.layer.contentsScale = Node.scale
    }
    public func layout(){
        self.applyDefine()
    }
    
    public var contentSize:CGSize{
        return self.frame.size
    }
}
extension Node{
    func applyFrame(){
        self.layer.frame  = self.frame
    }
    func applyDefine(){
        guard let p = self.parent else { return  }
        self.frame.size.width =  self.width == Size.matchParent ? p.frame.width - self.margin.left - self.margin.right : self.width.size 
        self.frame.size.height = self.height == Size.matchParent ? p.frame.height - self.margin.bottom - self.margin.top : self.height.size
        self.applyFrame()
    }
    public var convertFrame:CGRect{
        var point:Node? = self.parent
        var x:CGFloat = self.frame.origin.x
        var y:CGFloat = self.frame.origin.y
        while point != nil {
            x += point!.frame.minX
            y += point!.frame.minY
            point = point!.parent
        }
        return CGRect(x: x, y: y, width: self.frame.width, height: self.frame.height)
    }
    public static var scale:CGFloat{
        return UIScreen.main.scale
    }
}
public class NodeGroup:Node{
    public let nodes:[Node]
    public init(width: Size, height: Size,nodes:[Node]){
        self.nodes = nodes
        super.init(width: width, height: height)
        for i in nodes {
            i.parent = self
        }
        for i in self.nodes{
            self.layer.addSublayer(i.layer)
        }
    }
    public override func layout() {
        super.layout()
        for i in nodes {
            i.layout()
        }
        if self.width == .matchContent{
            self.frame.size.width = self.contentSize.width
        }
        if self.height == .matchContent{
            self.frame.size.height = self.contentSize.height
        }
    }
    public override var contentSize: CGSize{
        let w = self.nodes.reduce(0.0) { r, n in
            max(r , (n.margin.left + n.margin.right + n.frame.width))
        }
        let h = self.nodes.reduce(0.0) { r, n in
            max(r,(n.margin.top + n.margin.bottom + n.frame.height))
        }
        return CGSize(width: w, height: h)
    }
}
public class LinearNodeGroup:NodeGroup{

    public enum LinearNodeGroupDirection{
        case row
        case colume
    }
    public enum LinearNodeAlign{
        case start
        case end
        case center
    }
    public var direction:LinearNodeGroupDirection = .colume
    
    public var align:LinearNodeAlign = .start
    
    public override func layout() {
    
        for i in nodes {
            i.layout()
        }
        if self.weightSum > 0{
            let deltaS = self.deltaSum
            for i in nodes {
                switch self.direction {
                case .colume:
                    i.frame.size.width +=  (i.width.weight / self.weightSum) * deltaS
                    break
                case .row:
                    i.frame.size.height += (i.height.weight / self.weightSum) * deltaS
                    break
                }
                i.applyFrame()
            }
        }
        var start = CGPoint.zero
        var offset = CGPoint.zero
        for i in 0 ..< self.nodes.count {
            switch self.align {
            case .start:
                offset = CGPoint.zero
                break
            case .center:
                offset.x = (self.frame.width - self.nodes[i].frame.width - self.nodes[i].margin.left - self.nodes[i].margin.right) / 2
                offset.y = (self.frame.height - self.nodes[i].frame.height - self.nodes[i].margin.bottom - self.nodes[i].margin.top) / 2
                break
            case .end:
                offset.x = self.frame.width - self.nodes[i].frame.width - self.nodes[i].margin.left - self.nodes[i].margin.right
                offset.y = self.frame.height - self.nodes[i].frame.height - self.nodes[i].margin.left - self.nodes[i].margin.right
                break
            }
            switch self.direction{
            case .colume:
                self.nodes[i].frame.origin.x = self.nodes[i].margin.left + start.x
                self.nodes[i].frame.origin.y = self.nodes[i].margin.top + start.y + offset.y
                start.x = self.nodes[i].frame.maxX
                break
            case .row:
                self.nodes[i].frame.origin.x = self.nodes[i].margin.left + start.x + offset.x
                self.nodes[i].frame.origin.y = self.nodes[i].margin.top + start.y
                start.y = self.nodes[i].frame.maxY
                break
            }
            self.nodes[i].applyFrame()
        }
        
        self.applyFrame()
    }
    public override var contentSize:CGSize{
        
        let sumSize = self.nodes.reduce(0.0) { r, n in
            r + (self.direction == .row ? n.margin.bottom + n.margin.top + n.frame.height : n.margin.left + n.margin.right + n.frame.width)
        }
        let maxSize = self.nodes.reduce(0.0) { r, n in
            max(r,(self.direction == .colume ? n.margin.bottom + n.margin.top + n.frame.height : n.margin.left + n.margin.right + n.frame.width))
        }
        switch self.direction{
        
        case .row:
            return CGSize(width: maxSize,height: sumSize)
        case .colume:
            return CGSize(width: sumSize,height: maxSize)
        }
    }
    public var weightSum:CGFloat{
        switch self.direction {
        case .colume:
            return self.nodes.reduce(0.0, {$0 + $1.width.weight})
        case .row:
            return self.nodes.reduce(0.0, {$0 + $1.height.weight})
        }
    }
    public var deltaSum:CGFloat{
        let sumDefSize = self.nodes.reduce(0.0) { r, n in
            r + (self.direction == .row ? n.margin.bottom + n.margin.top + n.height.size : n.margin.left + n.margin.right + n.width.size)
        }
        return (self.direction == .row ? self.frame.height : self.frame.width) - sumDefSize
    }
}
public class ImageNode:Node{
    public var image: CGImage?
    public init(image:CGImage?){
        self.image = image
        super.init(width: .init(value: CGFloat(image?.width ?? 0) / Node.scale), height: .init(value: CGFloat(image?.height ?? 0) / Node.scale))
    }
    public override func layout() {
        guard let img = self.image else {
            
            return
        }
        if self.width.value == 0{
            self.width = .init(value: CGFloat(img.height) / Node.scale,max:self.width.max,min:self.width.min)
        }
        if self.width.value == 0{
            self.height = .init(value: CGFloat(img.height) / Node.scale,max:self.height.max,min:self.height.min)
        }
        self.layer.contents = self.image
        super.layout()
    }
}
public class NodeGroupLayer:CALayer{
    public var nodeGroup:NodeGroup?{
        didSet{
            
            if let ov = oldValue,ov.layer.superlayer == self{
                ov.layer.removeFromSuperlayer()
            }
            
            if let node = self.nodeGroup {
                self.addSublayer(node.layer)
                
                node.frame = self.bounds
                node.layout()
            }
            
        }
    }
}
