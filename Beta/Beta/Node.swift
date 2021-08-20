////
////  Node.swift
////  Beta
////
////  Created by hao yin on 2021/8/19.
////
//
import QuartzCore

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
//    public mutating func edge(edge:Edge,container:CGRect){
//        self.left = edge.left
//        self.top = edge.top
//        self.bottom = container.bottom - edge.bottom
//        self.right = container.right - edge.right
//    }

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

public class Node:Equatable{
    public static func == (lhs: Node, rhs: Node) -> Bool {
        Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
    }

    public var frame:CGRect
    public weak var parent:Node?
    public init(frame:CGRect,parent:Node? = nil) {
        self.frame = frame
        self.parent = parent
    }
    public func layout(){
        print(self.convertFrame)
    }
    public var contentSize:CGSize{
        return self.frame.size
    }
}
extension Node{
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
}
public class NodeGroup:Node{
    public let nodes:[Node]
    public init(frame:CGRect,nodes:[Node]){
        self.nodes = nodes
        super.init(frame: frame)
        for i in nodes {
            i.parent = self
        }
    }
    public override func layout() {
        
        for i in nodes {
            i.layout()
        }
    }
}
