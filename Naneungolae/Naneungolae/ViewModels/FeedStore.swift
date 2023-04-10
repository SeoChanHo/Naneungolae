//
//  FeedStore.swift
//  Whale_MVP
//
//  Created by ㅇㅇ on 2022/12/19.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class FeedStore: ObservableObject {
    @Published var feed: [Feed] = []
    @Published var imageDict = [String: UIImage]()
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    init(){
        feed = []
        imageDict = [:]
    }
    
    func fetchFeed(userEmail: String){
        database.collection("Feed").whereField("senderEmail", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            self.feed.removeAll()
            
            if let snapshot {
                for document in snapshot.documents{
                    let id: String = document.documentID

                    let docData = document.data()
                    let category: String = docData["category"] as? String ?? ""
                    let images: [String] = docData["images"] as? [String] ?? []
                    let senderEmail: String = docData["senderEmail"] as? String ?? ""
                    let senderNickname: String = docData["senderNickname"] as? String ?? ""
                    let senderPost: String = docData["senderPost"] as? String ?? ""
                    let receiverNickname: String = docData["receiverNickname"] as? String ?? ""
                    let receiverEmail: String = docData["receiverEmail"] as? String ?? ""
                    let receiverPost: String = docData["receiverPost"] as? String ?? ""
                    let isdoneMatching: Bool = docData["isdoneMatching"] as? Bool ?? false
                    let isdoneReply: Bool = docData["isdoneReply"] as? Bool ?? false
                    
                    self.feed.append(Feed(id: id, category: category, images: images, senderEmail: senderEmail, senderNickname: senderNickname, senderPost: senderPost, receiverNickname: receiverNickname, receiverEmail: receiverEmail, receiverPost: receiverPost, isdoneMatching: isdoneMatching, isdoneReply: isdoneReply))
                    self.fetchImage(postID: id, imageNames: images)
                }
            }
        }
    }
    
    func fetchImage(postID: String, imageNames: [String]) {
        for imageName in imageNames {
            let ref = storage.reference().child("images/\(postID)/\(imageName)")
            
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("error while downloading image\n\(error.localizedDescription)")
                    return
                } else {
                    let image = UIImage(data: data!)
                    self.imageDict[imageName] = image
                }
            }
        }
    }
    
    func addFeed(_ feed: Feed, images: [UIImage]){
        let postID = UUID().uuidString
        
        var imageNameList: [String] = []
        
        for image in images {
            let imageName = UUID().uuidString
            imageNameList.append(imageName)
            uploadImage(image: image, name: (postID + "/" + imageName))
        }
        
        database.collection("Feed").document(postID)
            .setData(["id" : feed.id,
                      "category" : feed.category,
                      "images" : imageNameList,
                      "createdAt" : feed.createdAt,
                      "senderEmail" : feed.senderEmail,
                      "senderNickname" : feed.senderNickname,
                      "senderPost" : feed.senderPost,
                      "receiverNickname" : feed.receiverNickname,
                      "receiverEmail" : feed.receiverEmail,
                      "receiverPost" : feed.receiverPost,
                      "isdoneMatching" : feed.isdoneMatching,
                      "isdoneReply" : feed.isdoneReply
            ])
        
//        for matchingFeed in self.feed {
//            if !matchingFeed.isdoneMatching {
//                updateMatchingState(matchingFeed)
//                updateMatchingState(feed)
//            }
//        }
        fetchFeed(userEmail: feed.senderEmail)
    }
    
    func uploadImage(image: UIImage, name: String){
        let storageRef = storage.reference().child("images/\(name)")
        let data = image.jpegData(compressionQuality: 0.1)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("err when uploading jpg\n\(error)")
                }
                
                if let metadata = metadata {
                    print("metadata: \(metadata)")
                }
            }
        }
    }
    
    func removeFeed(_ feed: Feed){
        database.collection("Feed")
            .document(feed.id).delete() { error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                }
            }
        let imageRef = storage.reference().child("images/\(feed.id)")
        imageRef.delete { error in
            if let error = error {
                print("Error removing image from storage\n\(error.localizedDescription)")
            } else {
                print("images directory deleted successfully")
            }
        }
    }
    
    func updateMatchingState(_ feed: Feed) {
        database.collection("Feed").document(feed.id).updateData(
            ["isdoneMatching" : true]
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}
