//
//  ArticleListTableViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/25.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore

class ArticleListTableViewController: UITableViewController, ListSectionObserver {
    
    deinit {
        ModelManager.articles.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ModelManager.articles.addObserver(self)
        self.tableView.rowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModelManager.articles.numberOfObjectsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Resourse.articleListCell(), forIndexPath: indexPath) as! ArticleListCell

        let article = ModelManager.articles[indexPath]
        cell.configureWith(article.title, subtitle: article.url, downloaded: article.archivePath != nil)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let article = ModelManager.articles[indexPath]
        self.performSegueWithIdentifier("showArticle", sender: article)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArticle", let vc = segue.destinationViewController as? WebViewController {
            let article = sender as! Article
            vc.url = NSURL(fileURLWithPath: FileManagerAdaptor.webarchivePath(withName: article.archivePath ?? article.url!)!)
        }
    }
    
    // MARK: - ListObserver
    func listMonitorWillChange(monitor: ListMonitor<Article>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<Article>) {
        
        self.tableView.endUpdates()
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<Article>) {
        
        self.tableView.reloadData()
    }
    
    func listMonitor(monitor: ListMonitor<Article>, didInsertObject object: Article, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Article>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Article>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Article>, didDeleteObject object: Article, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Article>, didUpdateObject object: Article, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}

class ArticleListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    
    func configureWith(title: String?, subtitle: String?, downloaded: Bool) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subtitle
        self.iconImageView.hidden = !downloaded
        self.titleTrailingConstraint.constant = downloaded ? 8 : 0
    }
}
