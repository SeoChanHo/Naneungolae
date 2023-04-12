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
    @Published var matchedFeed: [Feed] = []
    @Published var matchedOpponentFeed: [Feed] = []
    @Published var completedFeed: [Feed] = []
    @Published var notificationFeed: [Feed] = []
    @Published var imageDict = [String: UIImage]()
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    init(){
        feed = []
        matchedFeed = []
        matchedOpponentFeed = []
        completedFeed = []
        notificationFeed = []
        imageDict = [:]
    }
    
    // 수정해야함
    func fetchFeed(userEmail: String){
        database.collection("Feed")
            .whereField("senderEmail", isEqualTo: userEmail)
            .getDocuments { (snapshot, error) in
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
                    self.fetchImage(postID: id, userEmail: userEmail, imageNames: images)
                }
            }
        }
    }
    
    // 스토리지에 저장된 이미지를 불러와 ImageDict에 저장하는 함수
    func fetchImage(postID: String, userEmail: String, imageNames: [String]) {
        for imageName in imageNames {
            let ref = storage.reference().child("images/\(postID)|\(userEmail)/\(imageName)")
            
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
    
    // 피드 작성 완료시 피드 업로드 함수
//    func addFeed(_ feed: Feed, images: [UIImage]) async {
//        let feedID = UUID().uuidString
//
//        var imageNameList: [String] = []
//
//        for image in images {
//            let imageName = UUID().uuidString
//            imageNameList.append(imageName)
//            uploadImage(image: image, name: (feedID + "|" + feed.senderEmail + "/" + imageName))
//        }
//        do {
//            try await database.collection("Feed").document(feedID)
//                .setData(["id" : feed.id,
//                          "category" : feed.category,
//                          "images" : imageNameList,
//                          "createdAt" : feed.createdAt,
//                          "senderEmail" : feed.senderEmail,
//                          "senderNickname" : feed.senderNickname,
//                          "senderPost" : feed.senderPost,
//                          "receiverNickname" : feed.receiverNickname,
//                          "receiverEmail" : feed.receiverEmail,
//                          "receiverPost" : feed.receiverPost,
//                          "isdoneMatching" : feed.isdoneMatching,
//                          "isdoneReply" : feed.isdoneReply
//                ])
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//        await matchWhenAddFeed(userEmail: feed.senderEmail, feedID: feed.id)
//    }
    
    func addFeed(_ feed: Feed, images: [UIImage]) {
        let feedID = UUID().uuidString

        var imageNameList: [String] = []

        for image in images {
            let imageName = UUID().uuidString
            imageNameList.append(imageName)
            uploadImage(image: image, name: (feedID + "|" + feed.senderEmail + "/" + imageName))
        }

        database.collection("Feed").document(feedID)
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.matchWhenAddFeed(userEmail: feed.senderEmail, feedID: feedID)
        }
    }
    
    // 피드 작성을 완료했을때 서버에 매칭 대기중인 글이 있다면 매칭해주는 함수
//    func matchWhenAddFeed(userEmail: String, feedID: String) async {
//        do {
//            let documents = try await database.collection("Feed")
//                .whereField("senderEmail", isNotEqualTo: userEmail)
//                .whereField("isdoneMatching", isEqualTo: false)
//                .getDocuments()
//
//            let firstDocument = documents.documents[0]
//            try await database.collection("Feed").document(firstDocument.documentID).updateData(
//                ["isdoneMatching" : true]
//            )
//
//            try await database.collection("Feed").document(feedID).updateData(
//                ["isdoneMatching" : true]
//            )
//
//        } catch {
//            print("Error: 매칭 해주는 함수 에러")
//        }
//    }
    
    func matchWhenAddFeed(userEmail: String, feedID: String) {
        database.collection("Feed")
            .whereField("senderEmail", isNotEqualTo: userEmail)
            .whereField("isdoneMatching", isEqualTo: false)
            .getDocuments { (snapshot, error) in

                if let error {
                    print("Error: \(error.localizedDescription)")
                }

                if let snapshot {
                    let firstDocument = snapshot.documents[0]
                    self.database.collection("Feed").document(firstDocument.documentID).updateData(
                        ["isdoneMatching" : true]
                    ) { err in
                        if let err {
                            print("Error updating document: \(err)")
                        }
                    }

                    self.database.collection("Feed").document(feedID).updateData(
                        ["isdoneMatching" : true]
                    ) { err in
                        if let err {
                            print("Error updating document: \(err)")
                        }
                    }
                }
            }
    }
    
    // 스토리지에 이미지 업로드하는 함수
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
    
    // 피드 지우는 함수
    func removeFeed(_ feed: Feed){
        database.collection("Feed")
            .document(feed.id)
            .delete() { error in
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
    
    // 매칭이 됐을때 isdoneMatching 프로퍼티를 업데이트해주는 함수
    func updateMatchingState(_ feedID: String) {
        database.collection("Feed")
            .document(feedID)
            .updateData(
            ["isdoneMatching" : true]
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    // 매칭된 나의 글을 가져오는 함수
    func fetchMyMatchedFeed(userEmail: String){
        database.collection("Feed")
            .whereField("senderEmail", isEqualTo: userEmail)
            .whereField("isdoneMatching", isEqualTo: true)
            .getDocuments { (snapshot, error) in

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
                    self.fetchImage(postID: id, userEmail: userEmail, imageNames: images)
                }
            }
        }
    }
    
    // 매칭된 상대방 글을 가져오는 함수
    func fetchMatchedOpponentFeed(userEmail: String) {
        database.collection("Feed")
            .whereField("receiverEmail", isEqualTo: userEmail)
            .whereField("isdoneMatching", isEqualTo: true)
            .whereField("isdoneReply", isEqualTo: false)
            .getDocuments { (snapshot, error) in

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
                    
                    self.matchedOpponentFeed.append(Feed(id: id, category: category, images: images, senderEmail: senderEmail, senderNickname: senderNickname, senderPost: senderPost, receiverNickname: receiverNickname, receiverEmail: receiverEmail, receiverPost: receiverPost, isdoneMatching: isdoneMatching, isdoneReply: isdoneReply))
                    self.fetchImage(postID: id, userEmail: userEmail, imageNames: images)
                }
            }
        }
    }
    
    // 매칭이 완료된것을 알리는 함수 (리스너)
    func notifyMatchingComplete(userEmail: String) {
        database.collection("Feed")
            .whereField("senderEmail", isEqualTo: userEmail)
            .addSnapshotListener  { snapshot, error in
                if let error {
                    print("ListenerError: \(error.localizedDescription)")
                } else {
                    if let snapshot {
                        for document in snapshot.documents {
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
                            
                            self.notificationFeed.append(Feed(id: id, category: category, images: images, senderEmail: senderEmail, senderNickname: senderNickname, senderPost: senderPost, receiverNickname: receiverNickname, receiverEmail: receiverEmail, receiverPost: receiverPost, isdoneMatching: isdoneMatching, isdoneReply: isdoneReply))
                            
                        }
                    }
                }
            }
    }
    
    // 칭찬글 작성하고 상대방 글 수정하는 함수
    func updateOpponentFeed(feedID: String, user: User, post: String) {
        database.collection("Feed")
            .document(feedID)
            .updateData(
                ["receiverNickname" : user.nickname,
                 "receiverEmail" : user.email,
                 "receiverPost" : post,
                "isdoneReply" : true]
        ) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    // 나의 매칭 및 작성 완료된 글을 가져오는 함수
    func fetchCompletedFeed(userEmail: String) {
        database.collection("Feed")
            .whereField("senderEmail", isEqualTo: userEmail)
            .whereField("isdoneMatching", isEqualTo: true)
            .whereField("isdoneReply", isEqualTo: true)
            .getDocuments { (snapshot, error) in

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
                    
                    self.completedFeed.append(Feed(id: id, category: category, images: images, senderEmail: senderEmail, senderNickname: senderNickname, senderPost: senderPost, receiverNickname: receiverNickname, receiverEmail: receiverEmail, receiverPost: receiverPost, isdoneMatching: isdoneMatching, isdoneReply: isdoneReply))
                    self.fetchImage(postID: id, userEmail: userEmail, imageNames: images)
                }
            }
        }
    }
    
}
