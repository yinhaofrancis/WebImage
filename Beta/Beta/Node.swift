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
    var view:UIView? { get }
    func draw(ctx:CGContext)
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
        if(self.max == 0 && self.min == 0){
            return value
        }
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

    public func draw(ctx: CGContext) {
        
    }
    static let queue:DispatchQueue = DispatchQueue(label: "render")
    public var layer: CALayer
    public var view: UIView?
    public static func == (lhs: Node, rhs: Node) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }

    public var frame:CGRect = .zero
    public var width:Size
    public var height:Size
    public weak var parent:Node?
    public var margin:Edge = .init()
    public var name:String?
    public var hidden:Bool = false{
        didSet{
            self.view?.isHidden = self.hidden
            self.layer.isHidden = self.hidden
        }
    }
    public init(width:Size,height:Size,parent:Node? = nil,layer:CALayer = CALayer(),view:UIView? = nil) {
        self.width = width
        self.height = height
        self.parent = parent
        self.layer = layer
        self.view = view
        self.layer.contentsScale = Node.scale
    }
    public func layout(){
        self.applyDefine()
    }
    
    public var contentSize:CGSize{
        return self.frame.size
    }
    public func findNode(name:String)->Node?{
        if self.name == name{
            return self
        }else{
            return nil
        }
    }
    public func applyView(){
        if let view = self.view{
            view.frame = self.frame
        }else{
            
            self.layer.frame  = self.frame
        }
    }
    public func drawView(){
        Node.queue.async {
            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
            
            defer{
                UIGraphicsEndImageContext()
            }
            guard let ctx = UIGraphicsGetCurrentContext() else {return}
            UIGraphicsPushContext(ctx)
            self.draw(ctx: ctx)
            let img = ctx.makeImage()
            DispatchQueue.main.async {
                self.layer.contents = img
            }
            UIGraphicsPopContext()
            
        }
        
        
    }
}
extension Node{
    func applyFrame(){
        DispatchQueue.main.async {
            self.applyView()
        }
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
    private var _nodes:[Node]
    public var nodes:[Node]{
        self._nodes.filter({!$0.hidden})
    }
    public let keyNode:[String:Node]
    public init(width: Size, height: Size,nodes:[Node],layer:CALayer = CALayer(),view:UIView? = UIView()){
        self._nodes = nodes
        keyNode = nodes.filter({$0.name != nil}).reduce(into: [:], { r, n in
            r[n.name!] = n
        })
        super.init(width: width, height: height,layer: view?.layer ?? layer,view: view)
        for i in nodes {
            i.parent = self
            if let v = i.view{
                self.view?.addSubview(v)
            }else{
                self.layer.addSublayer(i.layer)
            }
        }
    }
    public static func layer(width: Size, height: Size,nodes:[Node])->NodeGroup{
        return NodeGroup(width: width, height: height, nodes: nodes, layer: CALayer(), view: nil)
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
        self.applyFrame()
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
    public override func findNode(name: String) -> Node? {
        if let n = super.findNode(name: name){
            return n
        }
        if let n = self.keyNode[name]{
            return n
        }
        for i in self.nodes {
            if let n = i.findNode(name: name){
                return n
            }
        }
        return nil
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
    
    public var scrollView:UIScrollView
    
    public override func layout() {
        if self.parent != nil{
            super.layout()
        }
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
//                i.applyFrame()
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
                start.x = self.nodes[i].frame.maxX + self.nodes[i].margin.right
                break
            case .row:
                self.nodes[i].frame.origin.x = self.nodes[i].margin.left + start.x + offset.x
                self.nodes[i].frame.origin.y = self.nodes[i].margin.top + start.y
                start.y = self.nodes[i].frame.maxY + self.nodes[i].margin.bottom
                break
            }
            self.nodes[i].applyFrame()
        }
        
        self.applyFrame()
    }
    public override func applyView() {
        super.applyView()
        self.scrollView.contentSize = self.contentSize
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
    public init(width: Size, height: Size, nodes: [Node],isScroll:Bool = false) {
        let scrollView = UIScrollView()
        self.scrollView = scrollView
        self.scrollView.isScrollEnabled = isScroll
        super.init(width: width, height: height, nodes: nodes,layer: scrollView.layer,view: scrollView)
    }
}
public class ImageNode:Node{
    public var image: CGImage?
    public init(image:CGImage?){
        self.image = image
        super.init(width: .matchContent, height: .matchContent)
    }
    public override func layout() {
        guard let img = self.image else {
            return
        }
        if self.width == .matchContent{
            self.width = .init(value: CGFloat(img.width) / Node.scale,max:self.width.max,min:self.width.min)
        }
        if self.height == .matchContent{
            self.height = .init(value: CGFloat(img.height) / Node.scale,max:self.height.max,min:self.height.min)
        }
        self.layer.contents = self.image
        super.layout()
    }
}
public class ButtonNode:Node{
    public var text:NSAttributedString?{
        didSet{
            self.button .setAttributedTitle(self.text, for: .normal)
        }
    }
    var action:NodeActionBlock
    var button:UIButton
    public init(text:NSAttributedString,callback: @escaping ()->Void){
        self.text = text
        self.action = NodeActionBlock(call: callback)
        let b =  UIButton()
        self.button = b
        super.init(width: .matchContent, height: .matchContent ,parent: nil,layer:b.layer  ,view: b)
        self.button .addTarget(self.action, action: #selector(NodeActionBlock.callFunc), for: .touchUpInside)
        self.button .setAttributedTitle(self.text, for: .normal)
    }
    public override func layout() {
        guard let p = self.parent else { return  }
        
        
        if self.width == .matchContent && self.height == .matchContent{
            let rect = text?.size(constraint: CGSize(width: p.frame.width - self.margin.left - self.margin.right, height: .infinity)) ?? .zero
            self.frame.size.width = rect.width
            self.frame.size.height = rect.height
        }else if self.width == .matchContent{
            let rect = text?.size(constraint: CGSize(width: p.frame.width - self.margin.left - self.margin.right, height: self.height.size)) ?? .zero
            self.frame.size.width = rect.width
            self.frame.size.height = self.height == Size.matchParent ? p.frame.height - self.margin.bottom - self.margin.top : self.height.size
        }else if self.height == .matchContent{
            let rect = text?.size(constraint: CGSize(width:self.width.size , height: .infinity)) ?? .zero
            self.frame.size.height = rect.height
            self.frame.size.width =  self.width == Size.matchParent ? p.frame.width - self.margin.left - self.margin.right : self.width.size
        }
        self.applyFrame()
    }
}
public class TextNode:Node{
    public var text:NSAttributedString?
//    public var textLayer:CATextLayer = CATextLayer()
    
    public init(text:NSAttributedString){
        self.text = text
        super.init(width: .matchContent, height: .matchContent,parent: nil,layer: CALayer(),view: nil)
//        self.textLayer.string = text
//        textLayer.isWrapped = true
    }
    public override func layout() {
        guard let p = self.parent else { return  }
        
        
        if self.width == .matchContent && self.height == .matchContent{
            let rect = text?.size(constraint: CGSize(width: p.frame.width - self.margin.left - self.margin.right, height: .infinity)) ?? .zero
            self.frame.size.width = rect.width
            self.frame.size.height = rect.height
        }else if self.width == .matchContent{
            let rect = text?.size(constraint: CGSize(width: p.frame.width - self.margin.left - self.margin.right, height: self.height.size)) ?? .zero
            self.frame.size.width = rect.width
            self.frame.size.height = self.height == Size.matchParent ? p.frame.height - self.margin.bottom - self.margin.top : self.height.size
        }else if self.height == .matchContent{
            let rect = text?.size(constraint: CGSize(width:self.width.size , height: .infinity)) ?? .zero
            self.frame.size.height = rect.height
            self.frame.size.width =  self.width == Size.matchParent ? p.frame.width - self.margin.left - self.margin.right : self.width.size
        }
        self.applyFrame()
    }
    public override func draw(ctx: CGContext) {
        
        self.text?.draw(in: self.layer.bounds)
    }
    public override func applyView() {
        super.applyView()
        self.drawView()
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
public class NodeGroupView:UIView{
    let queue = DispatchQueue(label: "layout")
    public var nodeGroup:NodeGroup?{
        didSet{
            
            if let ov = oldValue,ov.layer.superlayer == self{
                ov.layer.removeFromSuperlayer()
                ov.view?.removeFromSuperview()
            }
            
            if let node = self.nodeGroup {
                
                if let view = node.view{
                    self.addSubview(view)
                }else{
                    self.layer.addSublayer(node.layer)
                }
                
                
                node.frame = self.bounds
                self.queue.async {
                    node.layout()
                }
            }
            
        }
    }
}
public class NodeActionBlock:NSObject{
    private var call:()->Void
    
    public init(call:@escaping ()->Void){
        self.call = call
    }
    @objc public func callFunc(){
        self.call()
    }
    
}

@resultBuilder
public struct BuildAttributeString{
    public static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        components.reduce(into: NSMutableAttributedString()) { r, s in
            r.append(s)
        }
    }
    public static func buildBlock(_ paragraphStyle:NSParagraphStyle, _ components: NSAttributedString...) -> NSAttributedString {
        let c = components.reduce(into: NSMutableAttributedString()) { r, s in
            r.append(s)
        }
        c.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: c.length))
        return c
    }
}
extension NSAttributedString{
    public static func create(@BuildAttributeString call:()->NSAttributedString)->NSAttributedString{
        return call()
    }
    public func size(constraint:CGSize) ->CGSize{
        let setter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        return CTFramesetterSuggestFrameSizeWithConstraints(setter, CFRangeMake(0, self.length), nil, constraint, nil)
    }
}
