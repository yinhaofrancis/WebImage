//
//  Map.swift
//  WebImageCache
//
//  Created by wenyang on 2021/7/18.
//

import Foundation

public class Map<K:Hashable,V>{
    private var dic:Dictionary<K,V> = Dictionary()
    private var rw:UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)
    
    public init(){
        pthread_rwlock_init(self.rw, nil)
    }
    public subscript(key:K)->V?{
        get{
            pthread_rwlock_rdlock(self.rw)
            let n = dic
            pthread_rwlock_unlock(self.rw)
            return n[key]
        }
        set{
            pthread_rwlock_wrlock(self.rw)
            self.dic[key] = newValue
            pthread_rwlock_unlock(self.rw)
        }
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        self.rw.deallocate()
    }
    public func clean(){
        pthread_rwlock_wrlock(self.rw)
        self.dic.removeAll()
        pthread_rwlock_unlock(self.rw)
    }
}
public class List<K:Hashable>{
    private var array = Array<K>()
    private var rw:UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)
    public init(){
        pthread_rwlock_init(self.rw, nil)
    }
    public subscript(key:Int)->K?{
        pthread_rwlock_rdlock(self.rw)
        let n = array
        pthread_rwlock_unlock(self.rw)
        if key >= n.count{
            return nil
        }
        return n[key]
    }
    public func append(element:K){
        pthread_rwlock_wrlock(self.rw)
        self.array.append(element)
        pthread_rwlock_unlock(self.rw)
    }
    public func remove(element:K){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeAll { e in
            e == element
        }
        pthread_rwlock_unlock(self.rw)
    }
    @discardableResult
    public func removeFirst()->K?{
        pthread_rwlock_wrlock(self.rw)
        let a = self.array.count > 0 ? self.array.removeFirst() : nil
        pthread_rwlock_unlock(self.rw)
        return a
    }
    @discardableResult
    public func removeLast()->K?{
        pthread_rwlock_wrlock(self.rw)
        let a = self.array.count > 0 ?  self.array.removeLast() : nil
        pthread_rwlock_unlock(self.rw)
        return a
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        self.rw.deallocate()
    }
    public func clean(){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeAll()
        pthread_rwlock_unlock(self.rw)
    }
    public var count:Int{
        pthread_rwlock_wrlock(self.rw)
        let c = self.array.count
        pthread_rwlock_unlock(self.rw)
        return c
    }
}
public class BTree<T>:CustomStringConvertible{
    public var description: String{
        return self.array.description
    }

    private var array:Array<T> = Array()
    private var rw:UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)
    public init() {
        pthread_rwlock_init(self.rw, nil)
    }
    deinit {
        pthread_rwlock_destroy(self.rw)
        rw.deallocate()
    }
    public struct Node:Equatable{
        var index:Int
        public var leftNode:Node{  Node(index: index * 2 + 1) }
        public var rightNode:Node{ Node(index: index * 2 + 2) }
        public var parent:Node{ Node(index: index % 2 == 0 ? (index - 2) / 2 : (index - 1) / 2) }
        public var root:Bool{ self.index == 0 }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(index)
        }
        public static func == (lhs: Node, rhs: Node) -> Bool{
            lhs.index == rhs.index
        }
    }
    public subscript(index:Node)->T{
        get{
            pthread_rwlock_rdlock(self.rw)
            let temp = array[index.index]
            pthread_rwlock_unlock(self.rw)
            return temp
        }
        set{
            pthread_rwlock_wrlock(self.rw)
            self.array[index.index] = newValue
            pthread_rwlock_unlock(self.rw)
        }
    }
    public func append(object:T){
        pthread_rwlock_wrlock(self.rw)
        self.array.append(object)
        pthread_rwlock_unlock(self.rw)
    }
    public func removelast(){
        pthread_rwlock_wrlock(self.rw)
        if array.count > 0{
            array.removeLast()
        }
        pthread_rwlock_unlock(self.rw)
    }
    public func isEmpty(index:Node)->Bool{
        pthread_rwlock_rdlock(self.rw)
        let temp = index.index >= self.array.count
        pthread_rwlock_unlock(self.rw)
        return temp
    }
    public func isLeaf(index:Node)->Bool{
        pthread_rwlock_rdlock(self.rw)
        let temp = self.isEmpty(index: index.leftNode) && self.isEmpty(index: index.rightNode)
        pthread_rwlock_unlock(self.rw)
        return temp
    }
    public var lastNode:Node{
        Node(index: self.array.count - 1)
    }
    public var firstNode:Node{
        Node(index: 0)
    }
    public var count:Int{
        return self.array.count
    }
}
public class Heap<T:Comparable>:BTree<T>{
    private var compare:(_ lfs:T,_ rfs:T)->Bool
    public init(compare:@escaping (_ lfs:T,_ rfs:T)->Bool){
        self.compare = compare
    }
    public func insert(object:T){
        self.append(object: object)
        var current = self.lastNode
        var parent = current.parent
        if(current != self.firstNode){
            var parentV = self[parent]
            while compare(parentV,object) && current != self.firstNode{
                
                self[parent] = self[current]
                self[current] = parentV
                current = parent
                parent = current.parent
                if parent.index < 0{
                    break
                }
                parentV = self[parent]
            }
        }
    }
    public func remove()->T{
        let result = self[self.firstNode]
        let last = self[self.lastNode]
        self.removelast()
        if(self.count == 0){
            return result
        }
        self[firstNode] = last
        var current = self.firstNode
        var l = current.leftNode
        var r = current.rightNode
        
        while !self.isEmpty(index: l) || !self.isEmpty(index: r) {
            if !self.isEmpty(index: l) && !self.isEmpty(index: r){
                if self.compare(self[r],self[l]){
                    if self.compare(self[current],self[l]){
                        let pv = self[current]
                        let lv = self[l]
                        self[l] = pv
                        self[current] = lv
                        current = l
                        l = current.leftNode
                        r = current.rightNode
                        continue
                    }
                }else{
                    if self.compare(self[current],self[r]){
                        let pv = self[current]
                        let rv = self[r]
                        self[r] = pv
                        self[current] = rv
                        current = r
                        l = current.leftNode
                        r = current.rightNode
                        continue
                    }
                }
            }else if !self.isEmpty(index: l){
                if self.compare(self[current],self[l]){
                    let pv = self[current]
                    let lv = self[l]
                    self[l] = pv
                    self[current] = lv
                    current = l
                    l = current.leftNode
                    r = current.rightNode
                    continue
                }
            }else if !self.isEmpty(index: r){
                if self.compare(self[current],self[r]){
                    let pv = self[current]
                    let rv = self[r]
                    self[r] = pv
                    self[current] = rv
                    current = r
                    l = current.leftNode
                    r = current.rightNode
                    continue
                }
            }
            break
        }
        
        return result
    }
}
public class MaxHeap<T:Comparable>:Heap<T>{
    public init(){
        super.init(compare: {$0<$1})
    }
}
public class MinHeap<T:Comparable>:Heap<T>{
    public init(){
        super.init(compare: {$0>$1})
    }
}
