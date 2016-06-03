//
//  WebViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/18.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIScrollViewDelegate {
    
    var url: NSURL? = nil
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var toolView: UIView!
    
    deinit {
        webView.scrollView.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
        if let url = self.url {
            self.webView.loadRequest(NSURLRequest(URL: url))
        }
        self.webView.scrollView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dragPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let needHide = contentOffset.y - self.dragPoint.y > 10
        if needHide {
            let needChange = self.toolViewBottomConstraint!.constant == 0
            if needChange {
                self.toolViewBottomConstraint!.constant = 44
                self.view.setNeedsUpdateConstraints()
                UIView.animateWithDuration(0.25, animations: { 
                    self.view.layoutIfNeeded()
                })
            }
        } else {
            let needChange = self.toolViewBottomConstraint!.constant > 0
            if needChange {
                self.toolViewBottomConstraint!.constant = 0
                self.view.setNeedsUpdateConstraints()
                UIView.animateWithDuration(0.25, animations: { 
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func downloadButtonTapped(sender: UIButton) {
        if let url = self.webView.request?.URL {
            WebarchiveManager.sharedInstance.archive(url: url)
        }
    }
    
    // MARK: - Private
    private var dragPoint = CGPointZero
    private var toolViewBottomConstraint: NSLayoutConstraint?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    private let webView: UIWebView = {
        
        let webView = UIWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()
    
    private func setupViews() {
        
        self.contentView.addSubview(self.webView)
        let constrains: [NSLayoutConstraint] = [
            self.webView.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor),
            self.webView.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor),
            self.webView.bottomAnchor.constraintEqualToAnchor(self.contentView.bottomAnchor),
            self.webView.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor)
        ]
        self.contentView.addConstraints(constrains)
        self.toolViewBottomConstraint = self.toolView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor)
        self.contentViewBottomConstraint = self.contentView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor)
        self.view.addConstraint(self.toolViewBottomConstraint!)
        self.view.addConstraint(self.contentViewBottomConstraint!)
    }
}
