//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by William McPhail on 2/25/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    @objc func loadTweets(){
        numberOfTweets = 20
        
        let URL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: URL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { Error in
            print("Could not retrieve tweet")
        })
    }
    
    func loadMoreTweets(){
        let URL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: URL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { Error in
            print("Could not retrieve tweet")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let username = user["name"] as! String
        

        cell.usernameLabel.text = username
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }
}