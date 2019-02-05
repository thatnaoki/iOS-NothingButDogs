//
//  PostTableViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    var postArray: [Post] = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: プルリフレッシュ
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        self.navigationItem.hidesBackButton = true
        
        SVProgressHUD.show()
        configureTableview()
        setDataToArray()
    }
    
    @objc func pullToRefresh() {
        
        setDataToArray()
        refreshControl?.endRefreshing()
        
    }
    
    //MARK: データが揃ってから、グローバルのarrayにセットしてreloadする
    func setDataToArray() {
        
        postArray.removeAll()
        
        retrieveData() { (post) in
            print(post)
            self.postArray.append(post)
        }
        
        print(self.postArray)
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
    
    }
    
    
    //MARK: データベースからポストを取得する
    func retrieveData(completion: @escaping (Post) -> Void) {
        
        let postsColRef = db.collection("posts").order(by: "createdAt")
        
        postsColRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Document data: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let userId = data["userId"] as? String
                    let postImage = data["postImageURL"] as? String
                    let postText = data["postText"] as? String
                    let createdAt = data["createdAt"] as? String
                    let numberOfLike = data["numberOfLike"] as? Int
                    //投稿に紐づくユーザーデータを取得して合わせてpostArrayに挿入
                    let docRef = self.db.collection("users").document(userId!)
                    
                    docRef.getDocument() { (document, error) in
                        if let document = document, document.exists {
                            
                            let data = document.data()!
                            let userName = data["userName"] as? String
                            let userImage = data["userImageURL"] as? String
                            
                            let post = Post(
                                userId: userId!,
                                userName: userName!,
                                userImageURL: userImage!,
                                postImageURL: postImage!,
                                postText: postText!,
                                createdAt: createdAt!,
                                numberOfLike: numberOfLike!)
                            
                            print(post)
                            completion(post)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "homeToChooseImage", sender: nil)
        
    }

}

// MARK: - Table view data source
extension PostTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postArray.count
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postArray[indexPath.row]
        // 画像を取得して挿入
        let postImageURL = URL(string: post.postImageURL)
        
        do {
            let data = try Data(contentsOf: postImageURL!)
            cell.postImage.image = UIImage(data: data)
        }catch let err {
            print("Error : \(err.localizedDescription)")
        }
        // テキスト挿入
        cell.postText.text = post.postText
        
        cell.userName.text = post.userName
        
        cell.createdAt.text = post.createdAt
        
        cell.postLikeButton.titleLabel?.text = "\(post.numberOfLike) Likes"
        
        return cell
    }

}


// MARK: - Table viewのlayout設定
extension PostTableViewController {
    
    func configureTableview() {
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
    }
    
}
