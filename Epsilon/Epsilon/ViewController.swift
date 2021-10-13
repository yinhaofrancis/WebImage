//
//  ViewController.swift
//  Epsilon
//
//  Created by hao yin on 2021/8/31.
//

import UIKit

class ViewController: UIViewController,UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

public class EpsilonScrollView:UIScrollView,UIGestureRecognizerDelegate,UIScrollViewDelegate{
    private var pageScrollView:UIScrollView = UIScrollView()
    private var stackView:UIStackView  = UIStackView()
    @IBOutlet public var childScrollView:[UIScrollView] = []
    @IBInspectable var topContent:CGFloat = 0{
        didSet{
            self.contentInset = UIEdgeInsets(top: self.topContent, left: 0, bottom: 0, right: 0)
        }
    }
    @IBInspectable var page:Int = 1{
        didSet{
            guard let wc = self.widthConstraint else { return  }
            self.removeConstraint(wc)
            self.widthConstraint = self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(self.page))
            self.addConstraint(self.widthConstraint!)
        }
    }
    @IBInspectable public var top:CGFloat = 0{
        didSet{
            self.topConstaint?.constant = self.top
            self.heightConstraint?.constant = -self.top
        }
    }
    private var topConstaint:NSLayoutConstraint?
    private var widthConstraint:NSLayoutConstraint?
    private var heightConstraint:NSLayoutConstraint?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutPage()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
       
        self.layoutPage()
    }
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        for i in self.childScrollView {
            i.removeFromSuperview()
            self.stackView.addArrangedSubview(i)
        }
        self.delegate = self
        let t = self.top
        self.top = t
        self.panGestureRecognizer.delegate = self
    }
    func layoutPage(){
        self.pageScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.pageScrollView.showsVerticalScrollIndicator = false
        self.pageScrollView.showsHorizontalScrollIndicator = false
        self.contentInset = UIEdgeInsets(top: self.topContent, left: 0, bottom: 0, right: 0)
        self.addSubview(self.pageScrollView)
        self.stackView.axis = .horizontal
        self.pageScrollView.isPagingEnabled = true
        self.stackView.distribution = .fillEqually
        self.pageScrollView.addSubview(self.stackView)
        self.topConstaint = self.pageScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.top)
        self.heightConstraint = self.pageScrollView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -self.top)
        let c = [
            self.topConstaint!,
            self.pageScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.pageScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.pageScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.pageScrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.heightConstraint!
        ]
        self.addConstraints(c)
        self.widthConstraint = self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: CGFloat(self.page))
        self.addConstraint(self.widthConstraint!)
        let s = [
            self.stackView.topAnchor.constraint(equalTo: self.pageScrollView.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.pageScrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.pageScrollView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.pageScrollView.bottomAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.pageScrollView.centerYAnchor),
        ]
        self.pageScrollView.addConstraints(s)
        self.bounces = false
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view == self.pageScrollView{
            return false
        }
        if self.stackView.arrangedSubviews.contains(otherGestureRecognizer.view!){
            return true
        }
        return false
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
