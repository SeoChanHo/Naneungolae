//
//  FeedStore.swift
//  Whale_MVP
//
//  Created by ㅇㅇ on 2022/12/19.
//

import Foundation
import FirebaseFirestore

class FeedStore: ObservableObject {
    @Published var feed: [Feed] = []
    
    let database = Firestore.firestore()
    
    init(){
        feed = []
    }
    
    func fetchFeed(){
        database.collection("Feed").getDocuments { (snapshot, error) in
            self.feed.removeAll()
            
            if let snapshot {
                for document in snapshot.documents{
                    let id: String = document.documentID

                    let docData = document.data()
                    let category: String = docData["category"] as? String ?? ""
                    let image: String = docData["image"] as? String ?? ""
                    let createdAt: String = docData["createdAt"] as? String ?? ""
                    let senderEmail: String = docData["senderEmail"] as? String ?? ""
                    let senderNickname: String = docData["senderNickname"] as? String ?? ""
                    let receiverNickname: String = docData["receiverNickname"] as? String ?? ""
                    let receiverEmail: String = docData["receiverEmail"] as? String ?? ""
                    let reply: String = docData["reply"] as? String ?? ""
                    let isdoneMatching: Bool = docData["isdoneMatching"] as? Bool ?? false
                    let isdoneReply: Bool = docData["isdoneReply"] as? Bool ?? false
                    
                    
                    self.feed.append(Feed(id: id, category: category, image: image, createdAt: createdAt, senderEmail: senderEmail, senderNickname: senderNickname, receiverNickname: receiverNickname, receiverEmail: receiverEmail, reply: reply, isdoneMatching: isdoneMatching, isdoneReply: isdoneReply))
                }
            }
        }
    }
    
    func addFeed(_ feed: Feed){
        database.collection("Feed").document(feed.id)
            .setData(["id" : feed.id,
                      "category" : feed.category,
                      "image" : feed.image,
                      "createdAt" : feed.createdAt,
                      "senderEmail" : feed.senderEmail,
                      "senderNickname" : feed.senderNickname,
                      "receiverNickname" : feed.receiverNickname,
                      "receiverEmail" : feed.receiverEmail,
                      "reply" : feed.reply,
                      "isdoneMatching" : feed.isdoneMatching,
                      "isdoneReply" : feed.isdoneReply
            ])
        
        for matchingFeed in self.feed {
            if !matchingFeed.isdoneMatching {
                updateMatchingState(matchingFeed)
                updateMatchingState(feed)
            }
        }
        fetchFeed()
    }
    
    func removeFeed(_ feed: Feed){
        database.collection("Feed")
            .document(feed.id).delete()
        fetchFeed()
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
