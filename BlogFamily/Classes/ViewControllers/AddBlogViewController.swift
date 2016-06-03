//
//  AddBlogViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/17.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit

class AddBlogViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    var tobeAddBlog: Blog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        cleanDBTrashIfNeeded()
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
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
        guard let blog = tobeAddBlog else {
            return
        }
        
        if !inputValide() {
            return
        }
        
        ModelManager.dataStack.beginAsynchronous { [weak self] (transaction) in
            
            if let strongSelf = self {
                if let blog = transaction.edit(blog) {
                    blog.title = strongSelf.titleTextField.text
                    blog.url = strongSelf.urlTextField.text
                    
                    transaction.commit({ (result) in
                        if result {
                            strongSelf.cancelled = false
                            strongSelf.navigationController?.popViewControllerAnimated(true)
                        }
                    })
                }
            }
        }
    }

    // MARK: - Private
    private var cancelled = true
    
    private func cleanDBTrashIfNeeded() {
        
        if cancelled {
            ModelManager.dataStack.beginSynchronous({ [weak self] (transaction) in
                
                if let strongSelf = self {
                    transaction.delete(strongSelf.tobeAddBlog)
                    let saveResult = transaction.commitAndWait()
                    switch saveResult {
                    case .Success(let hasChanges):
                        print("delete success : \(hasChanges)")
                    case .Failure(let error):
                        print("delete error : \(error.localizedDescription)")
                    }
                }
            })
            
        }
    }
    
    private func inputValide() -> Bool {
        
        guard let title = titleTextField.text else {
            showErrorAlert(withMessage: "Title could not be nil")
            return false
        }
        
        guard let url = urlTextField.text else {
            showErrorAlert(withMessage: "Url could not be nil")
            return false
        }
        
        if title.isEmpty {
            showErrorAlert(withMessage: "Title could not be nil")
            return false
        }
        
        if (url.isEmpty) {
            showErrorAlert(withMessage: "Url could not be nil")
            return false
        }
        
        if (!url.hasPrefix("http")) {
            showErrorAlert(withMessage: "Wrong url format, must started by http")
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(withMessage message: String) {
        
        IndicatorAdaptor.showErrorAlert(inViewController: self, message: message)
    }
    
}
