//
//  RssViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/2.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit

class RssViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.rssViewController.showAdd.identifier, let nc = segue.destinationViewController as? UINavigationController, let vc = nc.topViewController as? AddViewController {
            vc.addViewModel = AddFeedViewModel()
        }
    }
    
    // MARK: - Actions
    @IBAction func syncTapped(sender: UIBarButtonItem) {
        FeedParseManager.syncIfNeeded()
    }

}
