//
//  WebViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/18.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import WebKit
import NJKWebViewProgress

class WebViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate, NJKWebViewProgressDelegate {
    
    var url: NSURL? = nil
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var toolView: UIView!
    
    lazy var progressView: NJKWebViewProgressView = {
        let view = NJKWebViewProgressView(frame: CGRect(x: 0, y: 20, width: CGRectGetWidth(self.view.frame), height: 4))
        return view
    }()
    
    lazy var progressProxy: NJKWebViewProgress = {
        let proxy = NJKWebViewProgress()
        proxy.webViewProxyDelegate = self
        proxy.progressDelegate = self
        return proxy
    }()
    
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
    
    // MARK: - NJKWebViewProgressDelegate
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressView.setProgress(progress, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(sender: UIButton) {
        if self.webView.canGoBack {
            self.webView.goBack()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
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
        webView.scalesPageToFit = true
        
        return webView
    }()
    
    private func setupViews() {
        
        self.view.addSubview(self.progressView)
        self.webView.delegate = self.progressProxy
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
