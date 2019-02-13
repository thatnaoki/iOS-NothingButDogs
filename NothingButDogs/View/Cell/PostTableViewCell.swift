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
    var numberOfLikeForView: Int?
    
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
        
        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        
        var numberOfLike: Int?
        guard let documentId = documentId else { return }
        let docRef = db.collection("posts").document(documentId)
        print(documentId)
        DispatchQueue.global().async {
            docRef.getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    print(data["numberOfLike"])
                    numberOfLike = data["numberOfLike"] as? Int
                    self.numberOfLikeForView = numberOfLike
                    print(numberOfLike)
                    docRef.updateData([
                        "numberOfLike" : numberOfLike! + 1
                    ]) { error in
                        if let error = error {
                            print("error updating document \(error)")
                        } else {
                            print("Document successfully updated")
                            self.numberOfLikeForView! += 1
                            self.numberOfLikeLabel.text = "\(String(self.numberOfLikeForView!)) Likes"
                        }
                    }
                }
            }
        }
    }
}
