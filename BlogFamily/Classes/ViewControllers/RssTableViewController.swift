//
//  RssTableViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/27.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit
import CoreStore

class RssTableViewController: UITableViewController, ListSectionObserver {
    
    deinit {
        ModelManager.feeds.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ModelManager.feeds.addObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModelManager.feeds.numberOfObjectsInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let feed = ModelManager.feeds[indexPath]
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.url

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let Feed = ModelManager.feeds[indexPath]
        self.performSegueWithIdentifier("showFeed", sender: Feed)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFeed", let vc = segue.destinationViewController as? RssContentTableViewController {
            let feed = sender as! Feed
            vc.feed = feed
            vc.title = feed.title
        }
    }
    
    // MARK: - ListObserver
    func listMonitorWillChange(monitor: ListMonitor<Feed>) {
        
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(monitor: ListMonitor<Feed>) {
        
        self.tableView.endUpdates()
    }
    
    func listMonitorDidRefetch(monitor: ListMonitor<Feed>) {
        
        self.tableView.reloadData()
    }
    
    func listMonitor(monitor: ListMonitor<Feed>, didInsertObject object: Feed, toIndexPath indexPath: NSIndexPath) {
        
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Feed>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Feed>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Feed>, didDeleteObject object: Feed, fromIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func listMonitor(monitor: ListMonitor<Feed>, didUpdateObject object: Feed, atIndexPath indexPath: NSIndexPath) {
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}
