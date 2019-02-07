//
//  PostTableViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import SVProgressHUD

class PostTableViewController: UITableViewController {
    
    var postArray: [Post] = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //バックボタン隠す
        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true
        
        //MARK: プルリフレッシュ
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        
        configureTableview()
        setDataToArray()
    }
    
    @objc func pullToRefresh() {
        
        setDataToArray()
        refreshControl?.endRefreshing()
        
    }
    
    //MARK: データが揃ってから、グローバルのarrayにセットしてreloadする
    func setDataToArray() {
        SVProgressHUD.show()
        postArray.removeAll()
        print("removeAllのタイミング")
        
        retrieveData() { posts in
//            print(post)
            print("postArrayへの代入のタイミング")
            self.postArray = posts
            print(self.postArray)
            print("reloaddataのタイミング")
            //reloaddataは一回呼ぶだけで済むようにする
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }

    }
    
    //MARK: データベースからポストを取得する
    //配列化する、理想は返す件数を指定できる仕様
    func retrieveData(completion: @escaping ([Post]) -> Void) {
    
        var posts: [Post] = []
        let postsColRef = db.collection("posts").order(by: "createdAt").limit(to: 5)
        let group = DispatchGroup()
        
        postsColRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Document data: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    group.enter()
                    let data = document.data()
                    let userId = data["userId"] as? String
                    let postImage = data["postImageURL"] as? String
                    let createdAt = data["createdAt"] as? String
                    //投稿に紐づくユーザーデータを取得して合わせてpostArrayに挿入
                    let docRef = db.collection("users").document(userId!)
                    
                    docRef.getDocument() { (document, error) in
                        if let document = document, document.exists {
                            
                            let data = document.data()!
                            let userName = data["userName"] as? String
                            
                            let post = Post(
                                userId: userId!,
                                userName: userName!,
                                postImageURL: postImage!,
                                createdAt: createdAt!
                            )
                            
                            print("postsへのappendのタイミング")
                            posts.append(post)
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) {
                    print("completionが呼ばれるタイミング")
                    print(posts)
                    completion(posts)
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
        //Data(contentsOf)は同期処理なので非同期にする
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: postImageURL!)
                DispatchQueue.main.async {
                    cell.postImage.image = UIImage(data: data)
                }
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
        
        cell.userName.text = post.userName
        
        cell.createdAt.text = post.createdAt
        
        return cell
    }

}


// MARK: - Table viewのlayout設定
extension PostTableViewController {
    
    func configureTableview() {
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
    }
    
}
