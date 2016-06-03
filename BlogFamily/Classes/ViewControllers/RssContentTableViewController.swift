//
//  RssContentTableViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/27.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit

class RssContentTableViewController: UITableViewController {
    
    var feed: Feed?
    var articles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let articles = feed?.articles {
            var tmpArr = [Article]()
            articles.enumerateObjectsUsingBlock({ (article, stop) in
                let article = article as! Article
                tmpArr += [article]
            })
            self.articles += tmpArr
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let article = self.articles[indexPath.row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.summary
        cell.imageView?.image = Resourse.icFeedImage()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let article = self.articles[indexPath.row]
        self.performSegueWithIdentifier("showContent", sender: article)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showContent", let vc = segue.destinationViewController as? WebViewController {
            let article = sender as! Article
            vc.url = NSURL(fileURLWithPath: FileManagerAdaptor.webarchivePath(withName: article.archivePath!)!)
        }
    }
}
