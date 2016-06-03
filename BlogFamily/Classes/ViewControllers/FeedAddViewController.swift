//
//  FeedAddViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore

class FeedAddViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var feedTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneTapped(sender: UIBarButtonItem) {
        if !inputValide() {
            return
        }
        
        ModelManager.dataStack.beginAsynchronous { [weak self] (transaction) in
            
            guard let safeSelf = self else {
                return
            }
            
            let feed = transaction.create(Into(Feed))
            feed.feedId = NSUUID().UUIDString
            feed.title = safeSelf.titleTextField.text
            feed.url = safeSelf.feedTextField.text
            
            transaction.commit({ (result) in
                dispatch_async_safely_to_main_queue({
                    switch result {
                    case .Success:
                        IndicatorAdaptor.toast(message: "添加成功")
                    case .Failure:
                        IndicatorAdaptor.toast(message: "添加失败")
                    }
                    safeSelf.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }
    }
    
    // MARK: - Private
    private func inputValide() -> Bool {
        
        guard let title = titleTextField.text else {
            showErrorAlert(withMessage: "Title could not be nil")
            return false
        }
        
        guard let feed = feedTextField.text else {
            showErrorAlert(withMessage: "Url could not be nil")
            return false
        }
        
        if title.isEmpty {
            showErrorAlert(withMessage: "Title could not be nil")
            return false
        }
        
        if (feed.isEmpty) {
            showErrorAlert(withMessage: "Url could not be nil")
            return false
        }
        
        if (!feed.hasPrefix("http") || !feed.hasSuffix(".xml")) {
            showErrorAlert(withMessage: "Wrong url format, must started by http, and ended by .xml")
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(withMessage message: String) {
        
        IndicatorAdaptor.showErrorAlert(inViewController: self, message: message)
    }
}
