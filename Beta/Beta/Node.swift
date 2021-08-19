//
//  Node.swift
//  Beta
//
//  Created by hao yin on 2021/8/19.
//

import QuartzCore

public enum Demainsion{
    case pt(CGFloat)
    case content
    case parent
    func isMatchContent()->Bool{
        switch self {
        case .pt(_):
            return false
        case .content:
            return true
        case .parent:
            return false
        }
    }
    func isMatchParent()->Bool{
        switch self {
        case .pt(_):
            return false
        case .content:
            return false
        case .parent:
            return true
        }
    }
    func ptValue()->CGFloat{
        switch self {
        case let .pt(v):
            return v
        case .content:
            return 0
        case .parent:
            return 0
        }
    }
}

public struct Edge{
    public let left:CGFloat
    public let right:CGFloat
    public let top:CGFloat
    public let bottom:CGFloat
    
    public static func all(value:CGFloat)->Edge{
        Edge(left: value, right: value, top: value, bottom: value)
    }
    public static func hv(horizental:CGFloat,vertical:CGFloat)->Edge{
        Edge(left: horizental, right: horizental, top: vertical, bottom: vertical)
    }
    public static func lrtb(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat)->Edge{
        Edge(left: left, right: right, top: top, bottom: bottom)
    }
    public static func value(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0)->Edge{
        Edge(left: left, right: right, top: top, bottom: bottom)
    }
}
public protocol Drawable{
    var drawable:CALayer { get }
}
public protocol Node:Drawable,AnyObject {
    var width:Demainsion { get }
    var height:Demainsion { get }
    var widthWeight:CGFloat { get }
    var heightWeight:CGFloat { get }
    var id:String? { get }
    var padding:Edge { get }
    var margin:Edge { get }
    var frame:CGRect { get set }
    func layout()
    var parent:NodeGroup? { get set }
    var nodes:[Node] { get }
}

extension Node{
    public func set<V>(path:ReferenceWritableKeyPath<Self,V>,value:V)->Self{
        self[keyPath: path] = value
        return self
    }
}

public protocol NodeGroup:Node{
    init(nodes:[Node])
    var width:Demainsion { get set }
    var height:Demainsion { get set }
}



public enum Axis{
    case vertical
    case horizontal
}
public class LinearLayout:NodeGroup{
    
    public var drawable: CALayer = CALayer()

    public weak var parent: NodeGroup?
    
    public var frame: CGRect = .zero
    
    public required init(nodes: [Node]) {
        self.nodes = nodes
        
        for i in nodes {
            self.drawable.addSublayer(i.drawable)
            i.parent = self
        }
    }
    
    
    public var nodes: [Node]
    
    public func layout() {
        self.nodes.filter({$0.height.isMatchParent()}).forEach { n in
            n.frame.size.height = self.frame.height
        }
        self.nodes.filter({$0.width.isMatchParent()}).forEach { n in
            n.frame.size.width = self.frame.width
        }
        self.nodes.filter({$0.width.ptValue() > 0}).forEach { n in
            n.frame.size.width = n.width.ptValue()
        }
        self.nodes.filter({$0.height.ptValue() > 0}).forEach { n in
            n.frame.size.height = n.height.ptValue()
        }
        
        for i in nodes {
            i.layout()
        }
        switch self.direction {
            
        case .vertical:
            var startPoint = CGPoint.zero
            for i in 0 ..< nodes.count {
                self.nodes[i].frame.origin.x = startPoint.x
                self.nodes[i].frame.origin.y = startPoint.y + self.nodes[i].margin.top + (i > 0 ? self.nodes[i - 1].margin.bottom : 0)
                startPoint = CGPoint(x: startPoint.x, y: self.nodes[i].frame.maxY)
            }
            let h = (self.nodes.last?.frame.maxY ?? 0) + (self.nodes.last?.margin.bottom ?? 0)
            if self.height.isMatchContent(){
                self.frame.size.height = h
            }
            break
            
        case .horizontal:
            var startPoint = CGPoint.zero
            for i in 0 ..< nodes.count {
                self.nodes[i].frame.origin.y = startPoint.y
                self.nodes[i].frame.origin.x = startPoint.x + self.nodes[i].margin.left + (i > 0 ? self.nodes[i - 1].margin.right : 0)
                startPoint = CGPoint(x:self.nodes[i].frame.maxX, y:startPoint.y)
            }
            let w = (self.nodes.last?.frame.maxX ?? 0) + (self.nodes.last?.margin.right ?? 0)
            if self.width.isMatchContent(){
                self.frame.size.height = w
            }
            break
            
        }
    }
    
    public var direction:Axis = .vertical
    
    public var width: Demainsion = .parent
    
    public var height: Demainsion = .parent
    
    public var widthWeight: CGFloat = 0
    
    public var heightWeight: CGFloat = 0
    
    public var id: String?
    
    public var padding: Edge = .value()
    
    public var margin: Edge = .value()
}

public class Layer:CALayer,Node{
    public var drawable: CALayer{
        return self
    }
    public init(id:String) {
        super.init()
        self.id = id
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var nodes: [Node] = []
    
    public var width: Demainsion = .parent
    
    public var height: Demainsion = .parent
    
    public var widthWeight: CGFloat = 0
     
    public var heightWeight: CGFloat = 0
    
    public var id: String?
    
    public var padding: Edge = .value()
    
    public var margin: Edge = .value()
    
    public func layout() {
        
    }
    public var parent: NodeGroup?
}

public class Container:CALayer{
    var drawLayer:CALayer?
    public var group:NodeGroup?{
        didSet{
            drawLayer?.removeFromSuperlayer()
            guard let no = self.group else { return }
            self.addSublayer(no.drawable)
            self.drawLayer = no.drawable
            no.frame = self.bounds
            no.width = .parent
            no.height = .parent
            no.layout()
        }
    }
}
