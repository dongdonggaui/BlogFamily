//
//  FeedSuggestTableViewController.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/6.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import UIKit

class SuggestTableViewController: UITableViewController {
    var datas = NSMutableArray()
    
    var titleTextField: UITextField?
    var urlTextField: UITextField?
    var viewModel: AddConfiguable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 60

        if let jsonPath = NSBundle.mainBundle().pathForResource("suggestion", ofType: "json"),
           let jsonData = NSData(contentsOfFile: jsonPath),
           let json = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! [AnyObject] {
            self.datas.addObjectsFromArray(json)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Resourse.suggestCell(), forIndexPath: indexPath) as! SuggestCell
        let info = self.datas[indexPath.row] as! [String: String]

        let subtitleKey = self.viewModel?.subtitleKey ?? "url"
        cell.configureWithTitle(info["title"], subtitle: info["desc"], url: info[subtitleKey])

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "推荐" : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let info = self.datas[indexPath.row] as! [String: String]
        self.titleTextField?.text = info["title"]
        let subtitleKey = self.viewModel?.subtitleKey ?? "url"
        self.urlTextField?.text = info[subtitleKey]
    }
}

class SuggestCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    func configureWithTitle(title: String?, subtitle: String?, url: String?) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.urlLabel.text = url
    }
}
