//
//  FeedAddViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore

class AddViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var feedTextField: UITextField!
    
    var addViewModel: AddConfiguable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "suggestion", let vc = segue.destinationViewController as? SuggestTableViewController {
            vc.titleTextField = self.titleTextField
            vc.urlTextField = self.feedTextField
            vc.viewModel = self.addViewModel
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneTapped(sender: UIBarButtonItem) {
        if !inputValid() {
            return
        }
        
        self.addViewModel?.submitWithTitle(self.titleTextField.text!, subtitle: self.feedTextField.text!, handler: { [weak self] in
            self!.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // MARK: - Private
    private func inputValid() -> Bool {
        
        guard let title = titleTextField.text where !title.isEmpty else {
            if let viewModel = self.addViewModel {
                showErrorAlert(withMessage: viewModel.titleNilMessage)
            }
            return false
        }
        
        guard let feed = feedTextField.text where !feed.isEmpty else {
            if let viewModel = self.addViewModel {
                showErrorAlert(withMessage: viewModel.subtitleNilMessage)
            }
            return false
        }
        
        guard feed.hasPrefix("http") else {
            if let viewModel = self.addViewModel {
                showErrorAlert(withMessage: viewModel.subtitleInvalidMessage)
            }
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(withMessage message: String) {
        
        IndicatorAdaptor.showErrorAlert(inViewController: self, message: message)
    }
}
