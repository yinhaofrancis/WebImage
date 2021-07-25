//
//  ViewController.swift
//  WebImage
//
//  Created by wenyang on 2021/7/17.
//

import UIKit
import WebImageCache
import CommonCrypto


public class Max:WebService<String,Body>{
    func req(page:Int,group:DispatchGroup)->Max{
        group.enter()
        self.get(url: "/csgo/content", param: "category=1&page=\(page)") { e in
            group.leave()
        }
        return self
    }
}

class Cell:UITableViewCell{
    @IBOutlet weak var imgView:UIImageView!
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.content?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.imgView.load(url: URL(string: self.content![indexPath.row].image!)!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = self.content?[indexPath.row].image
    }
    

    let group:DispatchGroup = DispatchGroup()
    
    @IBOutlet weak var table:UITableView!
    
    @JSONFile(name:"content")
    var content:[Content]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.content == nil{
            let a = (1..<50).map { i in
                Max().req(page: i, group: group)
            }
            self.group.notify(queue: .main) {
                let a = a.map { m in
                    m.response?.data?.content
                }.compactMap{$0}.flatMap{$0}
                self.content = a
                self.table.reloadData()
            }
        }
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        CacheFile.clean()
        self.table.reloadData()
    }
}

