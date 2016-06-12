//
//  BlogListViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/17.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore
import LeeGo

class BlogListViewController: UITableViewController, ListSectionObserver {
    
    deinit {
        ModelManager.blogs.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 50
        ModelManager.blogs.addObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let sections = ModelManager.blogs.numberOfSections()
        return sections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = ModelManager.blogs.numberOfObjectsInSection(section)
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Resourse.blogListCell(), forIndexPath: indexPath) as! BlogListCell

        let blog = ModelManager.blogs[indexPath]
        cell.configureCellWith(blog.title, subtitle: blog.subtitle, time: blog.addDate?.lkq_standardDisplayDate())

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let blog = ModelManager.blogs[indexPath]
        self.performSegueWithIdentifier("showDetail", sender: blog)
    }

    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            ModelManager.dataStack.beginSynchronous({ (transaction) in
                let tobeDeletedBlog = ModelManager.blogs[indexPath]
                transaction.delete(tobeDeletedBlog)
                transaction.commitAndWait()
            })
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showAdd",
            let nc = segue.destinationViewController as? UINavigationController,
            let vc = nc.topViewController as? AddViewController {
            
            vc.addViewModel = AddBlogViewModel()
            
        } else if segue.identifier == "showDetail",
            let vc = segue.destinationViewController as? WebViewController,
            let blog = sender as? Blog {
            
            if let url = blog.url {
                vc.url = NSURL(string: url)
            }
            vc.title = blog.title
        }
    }
    
    // MARK: - ListObserver
    func listMonitorWillChange(monitor: ListMonitor<Blog>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<Blog>) {
        
        self.tableView.endUpdates()
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<Blog>) {
        
        self.tableView.reloadData()
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didInsertObject object: Blog, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didDeleteObject object: Blog, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didUpdateObject object: Blog, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Blog>, didMoveObject object: Blog, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([fromIndexPath], withRowAnimation: .Automatic)
        self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(sender: AnyObject) {
        
        self.performSegueWithIdentifier(R.segue.blogListViewController.showAdd, sender: nil)
    }

}

class BlogListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func configureCellWith(title: String?, subtitle: String?, time: String?) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.timeLabel.text = time
    }
}
