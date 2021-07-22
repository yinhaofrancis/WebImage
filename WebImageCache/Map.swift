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
    public func removeFirst(){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeFirst()
        pthread_rwlock_unlock(self.rw)
    }
    public func removeLast(){
        pthread_rwlock_wrlock(self.rw)
        self.array.removeLast()
        pthread_rwlock_unlock(self.rw)
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
}
