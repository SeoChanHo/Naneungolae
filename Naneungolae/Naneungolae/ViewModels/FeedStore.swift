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
    // storage에서 Feed에 저장된 imageName(String Type)에 맞는 이미지를 불러와 담는 프로퍼티
    @Published var imageDict = [String: UIImage]()
    // 매칭된 상대방 Feed들을 담는 프로퍼티
    @Published var matchedOpponentFeed: [Feed] = []
    // 알림 피드
    @Published var notificationFeed: [Feed] = []
    // 매칭 가능한 Feed들 담는 프로퍼티 (시간순 정렬, 상대 닉네임, 이메일 가져오는데 사용)
    @Published var matchableFeed: [Feed] = []
    // 마이페이지 완료된 Feed
    @Published var myPageFeed: [Feed] = []
    // 마이페이지 즐겨찾기된 Feed
    @Published var favoritesFeed: [Feed] = []
    
    //MARK: - 알림
    @Published var notifications: [Notification] = []
    @Published var notificationMatchedFeed: [String: Feed] = [:]
    
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    //MARK: - 스토리지에 이미지 업로드하는 함수
    func uploadImage(image: UIImage, name: String) {
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
    
    //MARK: - 스토리지에 저장된 이미지를 불러와 ImageDict에 저장하는 함수
    func fetchImage(feedID: String, userEmail: String, imageNames: [String]) {
        for imageName in imageNames {
            let ref = storage.reference().child("images/\(feedID)|\(userEmail)/\(imageName)")
            
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
    
    //MARK: - 피드 작성 완료시 피드 업로드 함수
    func addFeed(_ feed: Feed, images: [UIImage]) {
        let feedID = UUID().uuidString
        
        var imageNameList: [String] = []
        
        for image in images {
            let imageName = UUID().uuidString
            imageNameList.append(imageName)
            uploadImage(
                image: image,
                name: (feedID + "|" + feed.senderEmail + "/" + imageName)
            )
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
                      "isdoneReply" : feed.isdoneReply,
                      "isdoneReplyMatchedFeed" : feed.isdoneReplyMatchedFeed,
                      "matchedFeedID" : feed.matchedFeedID
                     ])
        
        self.matchWhenAddFeed(
            senderNickname: feed.senderNickname,
            senderEmail: feed.senderEmail,
            feedID: feedID
        )
    }
    
    //MARK: - 피드 작성을 완료했을때 서버에 매칭 대기중인 글이 있다면 매칭해주는 함수
    func matchWhenAddFeed(senderNickname: String, senderEmail: String, feedID: String) {
        database.collection("Feed")
            .whereField("senderEmail", isNotEqualTo: senderEmail)
            .whereField("isdoneMatching", isEqualTo: false)
            .getDocuments { (snapshot, error) in
                
                if let error {
                    print("매칭 에러 Error: \(error.localizedDescription)")
                }
                
                if let snapshot {
                    let documents = snapshot.documents
                    if !documents.isEmpty {
                        self.matchableFeed.removeAll()
                        for document in documents {
                            let id: String = document.documentID
                            
                            let docData = document.data()
                            let category: String = docData["category"] as? String ?? ""
                            let images: [String] = docData["images"] as? [String] ?? []
                            let timeStampData: Timestamp = docData["createdAt"] as? Timestamp ?? Timestamp()
                            let createdAt : Date = timeStampData.dateValue()
                            let senderEmail: String = docData["senderEmail"] as? String ?? ""
                            let senderNickname: String = docData["senderNickname"] as? String ?? ""
                            let senderPost: String = docData["senderPost"] as? String ?? ""
                            let receiverNickname: String = docData["receiverNickname"] as? String ?? ""
                            let receiverEmail: String = docData["receiverEmail"] as? String ?? ""
                            let receiverPost: String = docData["receiverPost"] as? String ?? ""
                            let isdoneMatching: Bool = docData["isdoneMatching"] as? Bool ?? false
                            let isdoneReply: Bool = docData["isdoneReply"] as? Bool ?? false
                            let isdoneReplyMatchedFeed: Bool = docData["isdoneReplyMatchedFeed"] as? Bool ?? false
                            let matchedFeedID: String = docData["matchedFeedID"] as? String ?? ""
                            
                            
                            self.matchableFeed.append(
                                Feed(
                                    id: id,
                                    category: category,
                                    images: images,
                                    createdAt: createdAt,
                                    senderEmail: senderEmail,
                                    senderNickname: senderNickname,
                                    senderPost: senderPost,
                                    receiverNickname: receiverNickname,
                                    receiverEmail: receiverEmail,
                                    receiverPost: receiverPost,
                                    isdoneMatching: isdoneMatching,
                                    isdoneReply: isdoneReply,
                                    isdoneReplyMatchedFeed: isdoneReplyMatchedFeed,
                                    matchedFeedID: matchedFeedID
                                )
                            )
                        }
                        
                        let firstDocument = self.matchableFeed.sorted(by: { $0.createdAt < $1.createdAt })[0]
                        
                        self.database.collection("Feed").document(firstDocument.id).updateData(
                            ["isdoneMatching" : true,
                             "receiverNickname" : senderNickname,
                             "receiverEmail" : senderEmail,
                             "matchedFeedID" : feedID]
                        ) { err in
                            if let err {
                                print("이즈돈매칭 상대 에러Error updating document: \(err)")
                            }
                        }
                        
                        self.database.collection("Feed").document(feedID).updateData(
                            ["isdoneMatching" : true,
                             "receiverNickname" : firstDocument.senderNickname,
                             "receiverEmail" : firstDocument.senderEmail,
                             "matchedFeedID" : firstDocument.id]
                        ) { err in
                            if let err {
                                print("이즈돈매칭 본인 에러Error updating document: \(err)")
                            }
                        }
                    }
                }
            }
    }
    
    //MARK: -  피드 지우는 함수
    func removeFeed(feedID: String) {
        database.collection("Feed")
            .document(feedID)
            .delete() { error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                }
            }
//        let imageRef = storage.reference().child("images/\(feed.id)")
//        imageRef.delete { error in
//            if let error = error {
//                print("Error removing image from storage\n\(error.localizedDescription)")
//            } else {
//                print("images directory deleted successfully")
//            }
//        }
    }
    
    //MARK: - 매칭된 상대방 글을 가져오는 함수
    func fetchMatchedOpponentFeed(userEmail: String) {
        matchedOpponentFeed.removeAll()
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
                        let timeStampData: Timestamp = docData["createdAt"] as? Timestamp ?? Timestamp()
                        let createdAt : Date = timeStampData.dateValue()
                        let senderEmail: String = docData["senderEmail"] as? String ?? ""
                        let senderNickname: String = docData["senderNickname"] as? String ?? ""
                        let senderPost: String = docData["senderPost"] as? String ?? ""
                        let receiverNickname: String = docData["receiverNickname"] as? String ?? ""
                        let receiverEmail: String = docData["receiverEmail"] as? String ?? ""
                        let receiverPost: String = docData["receiverPost"] as? String ?? ""
                        let isdoneMatching: Bool = docData["isdoneMatching"] as? Bool ?? false
                        let isdoneReply: Bool = docData["isdoneReply"] as? Bool ?? false
                        let isdoneReplyMatchedFeed: Bool = docData["isdoneReplyMatchedFeed"] as? Bool ?? false
                        let matchedFeedID: String = docData["matchedFeedID"] as? String ?? ""
                        
                        self.matchedOpponentFeed.append(
                            Feed(
                                id: id,
                                category: category,
                                images: images,
                                createdAt: createdAt,
                                senderEmail: senderEmail,
                                senderNickname: senderNickname,
                                senderPost: senderPost,
                                receiverNickname: receiverNickname,
                                receiverEmail: receiverEmail,
                                receiverPost: receiverPost,
                                isdoneMatching: isdoneMatching,
                                isdoneReply: isdoneReply,
                                isdoneReplyMatchedFeed: isdoneReplyMatchedFeed,
                                matchedFeedID: matchedFeedID
                            )
                        )
                        self.fetchImage(feedID: id, userEmail: senderEmail, imageNames: images)
                    }
                }
            }
        self.matchedOpponentFeed.sort(by: { $0.createdAt < $1.createdAt })
    }
    
    //MARK: - 매칭이 완료된것을 알리는 함수 (리스너)
    func notifyMatchingComplete(userEmail: String) {
        database.collection("Feed")
            .whereField("senderEmail", isEqualTo: userEmail)
            .addSnapshotListener  { snapshot, error in
                if let error {
                    print("ListenerError: \(error.localizedDescription)")
                } else {
                    if let snapshot {
                        self.notificationFeed.removeAll()
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
                            let isdoneReplyMatchedFeed: Bool = docData["isdoneReplyMatchedFeed"] as? Bool ?? false
                            let matchedFeedID: String = docData["matchedFeedID"] as? String ?? ""
                            
                            let feed = Feed(
                                id: id,
                                category: category,
                                images: images,
                                senderEmail: senderEmail,
                                senderNickname: senderNickname,
                                senderPost: senderPost,
                                receiverNickname: receiverNickname,
                                receiverEmail: receiverEmail,
                                receiverPost: receiverPost,
                                isdoneMatching: isdoneMatching,
                                isdoneReply: isdoneReply,
                                isdoneReplyMatchedFeed: isdoneReplyMatchedFeed,
                                matchedFeedID: matchedFeedID
                            )
                            
                            self.notificationFeed.append(feed)
                            
                            if isdoneMatching && !isdoneReply && !isdoneReplyMatchedFeed {
                                self.addNotification(userEmail: userEmail, feedID: id, notificationType: "matching")
                            } else if isdoneMatching && isdoneReply && isdoneReplyMatchedFeed {
                                self.addCompletedFeedInMyPage(feed: feed, userEmail: userEmail)
                                self.addNotification(userEmail: userEmail, feedID: id, notificationType: "complete")
                            }
                        }
                    }
                }
            }
    }
    
    
    //MARK: - 상대방 Feed 데이터에 답칭찬글을 저장하고 나의 Feed 데이터에 매칭된 Feed에 칭찬답글을 완료했다는 Bool값을 true로 수정해주는 함수
    func updateOpponentFeed(userEmail: String, feedID: String, matchedFeedID: String, text: String) {
        database.collection("Feed")
            .document(feedID)
            .updateData(
                ["receiverPost" : text,
                 "isdoneReply" : true]
            ) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        
        database.collection("Feed")
            .document(matchedFeedID)
            .updateData(
                ["isdoneReplyMatchedFeed" : true]
            ) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        fetchMatchedOpponentFeed(userEmail: userEmail)
    }
    
    //MARK: - 마이페이지에 칭찬 완료된 Feed를 저장하는 함수
    func addCompletedFeedInMyPage(feed: Feed, userEmail: String) {
        database.collection("Users")
            .document(userEmail).collection("MyFeed")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    for document in snapshot.documents {
                        if document.documentID == feed.id {
                            return
                        }
                    }
                }
                self.database.collection("Users")
                    .document(userEmail)
                    .collection("MyFeed")
                    .document(feed.id)
                    .setData(["id" : feed.id,
                              "category" : feed.category,
                              "images" : feed.images,
                              "createdAt" : feed.createdAt,
                              "senderEmail" : feed.senderEmail,
                              "senderNickname" : feed.senderNickname,
                              "senderPost" : feed.senderPost,
                              "receiverNickname" : feed.receiverNickname,
                              "receiverEmail" : feed.receiverEmail,
                              "receiverPost" : feed.receiverPost,
                              "isdoneMatching" : feed.isdoneMatching,
                              "isdoneReply" : feed.isdoneReply,
                              "isdoneReplyMatchedFeed" : feed.isdoneReplyMatchedFeed,
                              "matchedFeedID" : feed.matchedFeedID
                             ])
            }
    }
    
    //MARK: - 마이페이지에서 저장된 Feed들을 불러오는 함수
    func fetchCompletedFeedInMyPage(userEmail: String) {
        database.collection("Users")
            .document(userEmail).collection("MyFeed")
            .getDocuments { (snapshot, error) in
                self.myPageFeed.removeAll()
                
                if let snapshot {
                    for document in snapshot.documents {
                        let id: String = document.documentID
                        
                        let docData = document.data()
                        let category: String = docData["category"] as? String ?? ""
                        let images: [String] = docData["images"] as? [String] ?? []
                        let timeStampData: Timestamp = docData["createdAt"] as? Timestamp ?? Timestamp()
                        let createdAt : Date = timeStampData.dateValue()
                        let isBookmarked: Bool = docData["isBookmarked"] as? Bool ?? false
                        let senderEmail: String = docData["senderEmail"] as? String ?? ""
                        let senderNickname: String = docData["senderNickname"] as? String ?? ""
                        let senderPost: String = docData["senderPost"] as? String ?? ""
                        let receiverNickname: String = docData["receiverNickname"] as? String ?? ""
                        let receiverEmail: String = docData["receiverEmail"] as? String ?? ""
                        let receiverPost: String = docData["receiverPost"] as? String ?? ""
                        let isdoneMatching: Bool = docData["isdoneMatching"] as? Bool ?? false
                        let isdoneReply: Bool = docData["isdoneReply"] as? Bool ?? false
                        let isdoneReplyMatchedFeed: Bool = docData["isdoneReplyMatchedFeed"] as? Bool ?? false
                        let matchedFeedID: String = docData["matchedFeedID"] as? String ?? ""
                        
                        self.myPageFeed.append(
                            Feed(
                                id: id,
                                category: category,
                                images: images,
                                createdAt: createdAt,
                                isBookmarked: isBookmarked,
                                senderEmail: senderEmail,
                                senderNickname: senderNickname,
                                senderPost: senderPost,
                                receiverNickname: receiverNickname,
                                receiverEmail: receiverEmail,
                                receiverPost: receiverPost,
                                isdoneMatching: isdoneMatching,
                                isdoneReply: isdoneReply,
                                isdoneReplyMatchedFeed: isdoneReplyMatchedFeed,
                                matchedFeedID: matchedFeedID
                            )
                        )
                        self.fetchImage(feedID: id, userEmail: senderEmail, imageNames: images)
                    }
                    self.myPageFeed.sort(by: { $0.createdAt > $1.createdAt })
                    self.favoritesFeed = self.myPageFeed.filter { $0.isBookmarked == true }
                }
            }
    }
    
    //MARK: - 마이페이지에 저장된 Feed의 즐겨찾기를 설정하는 함수
    func settingFavoritesFeed(feedID: String, isBookmarked: Bool, userEmail: String) {
        if isBookmarked {
            database.collection("Users")
                .document(userEmail)
                .collection("MyFeed")
                .document(feedID)
                .updateData(
                    ["isBookmarked" : false]
                ) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            
        } else {
            database.collection("Users")
                .document(userEmail)
                .collection("MyFeed")
                .document(feedID)
                .updateData(
                    ["isBookmarked" : true]
                ) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
        }
        fetchCompletedFeedInMyPage(userEmail: userEmail)
    }
    
    //MARK: - 알림을 추가하는 함수
    func addNotification(userEmail: String, feedID: String, notificationType: String) {
        database.collection("Users")
            .document(userEmail)
            .collection("Notifications")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    for document in snapshot.documents {
                        if document.documentID == feedID {
                            return
                        }
                    }
                }
                self.database.collection("Users")
                    .document(userEmail)
                    .collection("Notifications")
                    .document(feedID)
                    .setData(["id" : feedID,
                              "date" : Date(),
                              "notificationType" : notificationType
                             ])
            }
        fetchNotification(userEmail: userEmail)
    }
    
    //MARK: - 알림을 가져오는 함수
    func fetchNotification(userEmail: String) {
        database.collection("Users")
            .document(userEmail)
            .collection("Notifications")
            .order(by:"date")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    self.notifications.removeAll()
                    self.notificationFeed.removeAll()
                    for document in snapshot.documents{
                        let id: String = document.documentID
                        
                        let docData = document.data()
                        let timeStampData: Timestamp = docData["date"] as? Timestamp ?? Timestamp()
                        let date : Date = timeStampData.dateValue()
                        let notificationType: String = docData["notificationType"] as? String ?? ""
                        self.notifications.append(
                            Notification(
                                id: id,
                                date: date,
                                notificationType: notificationType
                            )
                        )
                        self.fetchNotificationFeed(userEmail: userEmail, feedID: id)
                    }
                }
            }
    }
    
    //MARK: - 알림에 해당하는 Feed를 가져오는 함수
    func fetchNotificationFeed(userEmail: String, feedID: String) {
        database.collection("Users")
            .document(userEmail)
            .collection("MyFeed")
            .document(feedID)
            .getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    let id: String = data["id"] as? String ?? ""
                    let category: String = data["category"] as? String ?? ""
                    let images: [String] = data["images"] as? [String] ?? []
                    let timeStampData: Timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
                    let createdAt : Date = timeStampData.dateValue()
                    let senderEmail: String = data["senderEmail"] as? String ?? ""
                    let senderNickname: String = data["senderNickname"] as? String ?? ""
                    let senderPost: String = data["senderPost"] as? String ?? ""
                    let receiverNickname: String = data["receiverNickname"] as? String ?? ""
                    let receiverEmail: String = data["receiverEmail"] as? String ?? ""
                    let receiverPost: String = data["receiverPost"] as? String ?? ""
                    let isdoneMatching: Bool = data["isdoneMatching"] as? Bool ?? false
                    let isdoneReply: Bool = data["isdoneReply"] as? Bool ?? false
                    let isdoneReplyMatchedFeed: Bool = data["isdoneReplyMatchedFeed"] as? Bool ?? false
                    let matchedFeedID: String = data["matchedFeedID"] as? String ?? ""
                    
                    let feed = Feed(
                        id: id,
                        category: category,
                        images: images,
                        createdAt: createdAt,
                        senderEmail: senderEmail,
                        senderNickname: senderNickname,
                        senderPost: senderPost,
                        receiverNickname: receiverNickname,
                        receiverEmail: receiverEmail,
                        receiverPost: receiverPost,
                        isdoneMatching: isdoneMatching,
                        isdoneReply: isdoneReply,
                        isdoneReplyMatchedFeed: isdoneReplyMatchedFeed,
                        matchedFeedID: matchedFeedID
                    )
                    self.notificationMatchedFeed[feedID] = feed
                    self.fetchImage(feedID: id, userEmail: userEmail, imageNames: images)
                }
            }
    }
    
    
    //MARK: - 모든 작업이 완료된 Feed를 확인하면 해당 알림을 삭제하는 함수
    func deleteCompleteNotification(userEmail: String, feedID: String) {
        database.collection("Users")
            .document(userEmail)
            .collection("Notifications")
            .document(feedID)
            .delete() { error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    self.removeFeed(feedID: feedID)
                    print("Document successfully removed!")
                }
            }
        fetchNotification(userEmail: userEmail)
    }
    
    //MARK: - 매칭이 완료된 Feed에 칭찬답글을 작성하면 해당 알림을 삭제하는 함수
    func deleteMatchingNotification(userEmail: String, feedID: String) {
        database.collection("Users")
            .document(userEmail)
            .collection("Notifications")
            .document(feedID)
            .delete() { error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                }
            }
        fetchNotification(userEmail: userEmail)
    }
}
