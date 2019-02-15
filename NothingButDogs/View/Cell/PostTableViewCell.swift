//
//  PostTableViewCell.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import Firebase

class PostTableViewCell: UITableViewCell {

    var documentId : String?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var post: Post? {
        
        didSet {
            print("didset called")
            guard let post = post else {return}
            self.documentId = post.documentId
            self.userName.text = post.userName
            self.createdAt.text = post.createdAt
            self.numberOfLikeLabel.text = "\(post.numberOfLike!) Likes"
            self.postImage!.cacheImage(imageUrlString: post.postImageURL!)
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        print("likebuttonpressed")
        var numberOfLike: Int?
        guard let documentId = documentId else { return }
        let docRef = db.collection("posts").document(documentId)
        print(documentId)
        DispatchQueue.global().async {
            docRef.getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    print(data["numberOfLike"]!)
                    numberOfLike = data["numberOfLike"] as? Int
                    docRef.updateData([
                        "numberOfLike" : numberOfLike! + 1
                    ]) { error in
                        if let error = error {
                            print("error updating document \(error)")
                        } else {
                            print("Document successfully updated")
                            self.post?.numberOfLike! += 1
                            print("a")
                            self.numberOfLikeLabel.text = "\(self.post!.numberOfLike!) Likes"
                            print("b")
                        }
                    }
                }
            }
        }
    }
}
