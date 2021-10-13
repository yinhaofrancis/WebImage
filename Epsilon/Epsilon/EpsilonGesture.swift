//
//  EpsilonGesture.swift
//  Epsilon
//
//  Created by hao yin on 2021/9/6.
//

import UIKit

public extension UIGestureRecognizer{
    var priority:Int{
        get{
            (objc_getAssociatedObject(self, "priority") as? Int) ?? 0
        }
        set{
            objc_setAssociatedObject(self, "priority", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var mutex:Bool{
        get{
            (objc_getAssociatedObject(self, "mutex") as? Bool) ?? false
        }
        set{
            objc_setAssociatedObject(self, "mutex", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
