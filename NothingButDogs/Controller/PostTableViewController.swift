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
    
    private var loadStatus: Bool = true
    
    private var fetchCount : Int = 0
    
    private var postArray: [Post] = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //バックボタン隠す
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        //プルリフレッシュ
//        self.refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
//        self.tableView.addSubview(self.refreshControl!)
        
        //tableView初期化
        configureTableview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        postArray.removeAll()
        fetchCount = 0
        updateView()
    }
    
//    @objc func pullToRefresh() {
//
//        print("removeAll()")
//        postArray.removeAll()
//        fetchCount = 0
//        DispatchQueue.main.async {
//            print("updateView()")
//            self.updateView()
//            DispatchQueue.main.async {
//                print("endRefreshing()")
//                self.refreshControl?.endRefreshing()
//            }
//        }
//    }
    
    //MARK: データが揃ってから、グローバルのarrayにセットしてreloadする
    func updateView() {
        
        SVProgressHUD.show()
        
        fetchData() { posts in
            self.postArray = self.postArray + posts
            print("in updateView() -> \(self.postArray)")
            self.tableView.reloadData()
            self.loadStatus = false
            SVProgressHUD.dismiss()
        }

    }
    
    //MARK: データベースからポストを取得する
    //配列化する、理想は返す件数を指定できる仕様
    func fetchData(completion: @escaping ([Post]) -> Void) {
        
        var posts: [Post] = []
        
        if self.fetchCount == 0{
            
            let postsColRef = db.collection("posts").order(by: "timestamp", descending: true).limit(to: 5)
            
            let group = DispatchGroup()
            
            postsColRef.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Document data: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        group.enter()
                        let documentId = document.documentID
                        let data = document.data()
                        let userId = data["userId"] as? String
                        let postImage = data["postImageURL"] as? String
                        let createdAt = data["createdAt"] as? String
                        let numberOfLike = data["numberOfLike"] as? Int
                        //投稿に紐づくユーザーデータを取得して合わせてpostArrayに挿入
                        let docRef = db.collection("users").document(userId!)
                        
                        docRef.getDocument() { (document, error) in
                            if let document = document, document.exists {
                                
                                let data = document.data()!
                                let userName = data["userName"] as? String
                                
                                let post = Post(
                                    userId: userId,
                                    userName: userName,
                                    postImageURL: postImage,
                                    createdAt: createdAt,
                                    documentId: documentId,
                                    numberOfLike: numberOfLike
                                )
                                posts.append(post)
                                group.leave()
                            }
                        }
                    }
                    //配列化してクロージャに渡す
                    group.notify(queue: .main) {
                        print("infetchData()\(posts)")
                        self.fetchCount += 1
                        completion(posts)
                    }
                }
            }
        } else if self.fetchCount > 0 {

            let first = db.collection("posts").order(by: "timestamp", descending: true).limit(to: 5 * self.fetchCount)
            
            first.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error: \(error.debugDescription)")
                    return
                }
                guard let lastSnapshot = snapshot.documents.last else {
                    return
                }
                let postsColRef = db.collection("posts").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot).limit(to: 3)
                
                let group = DispatchGroup()
                
                postsColRef.getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("Document data: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            group.enter()
                            let documentId = document.documentID
                            let data = document.data()
                            let userId = data["userId"] as? String
                            let postImage = data["postImageURL"] as? String
                            let createdAt = data["createdAt"] as? String
                            let numberOfLike = data["numberOfLike"] as? Int
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
                                        createdAt: createdAt!,
                                        documentId: documentId,
                                        numberOfLike: numberOfLike!
                                    )
                                    posts.append(post)
                                    group.leave()
                                }
                            }
                        }
                        //配列化してクロージャに渡す
                        group.notify(queue: .main) {
//                            print(posts)
                            self.fetchCount += 1
                            completion(posts)
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
        
        print("called cellforRowat")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        cell.post = postArray[indexPath.row]
        
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

// MARK: - 一番下までスクロールしたときに追加で読み込む
extension PostTableViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(fetchCount)
        if fetchCount > 5 {
            return
        } else {
            let currentOffsetY = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
            let distanceToBottom = maximumOffset - currentOffsetY
            if !self.loadStatus && distanceToBottom < -50 {
                print("distanceToBottom=0の状態")
                self.loadStatus = true
                updateView()
            } else {
                return
            }
        }
    }
}
