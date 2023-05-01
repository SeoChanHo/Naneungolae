//
//  UserStore.swift
//  Whale_MVP
//
//  Created by ㅇㅇ on 2022/12/19.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Firebase

class UserStore: ObservableObject {
    @Published var user: User
    
    let database = Firestore.firestore()
    
    init(){
       user = User(id: "", email: "", nickname: "", totalNumberOfCompliments: 0)
    }
    
    func fetchUser(userEmail: String){
        database.collection("Users").document(userEmail).getDocument { (snapshot, error) in

            if let data = snapshot?.data() {
                let email: String = data["email"] as? String ?? ""
                let nickname: String = data["nickname"] as? String ?? ""
                let totalNumberOfCompliments: Int = data["totalNumberOfCompliments"] as? Int ?? 0
                
                self.user = User(id: userEmail, email: email, nickname: nickname, totalNumberOfCompliments: totalNumberOfCompliments)
            }
        }
    }
    
    func createUser(_ user: User){
        database.collection("Users").document(user.email)
            .setData([
                "id": user.id,
                "email": user.email,
                "nickname": user.nickname,
                "totalNumberOfCompliments": user.totalNumberOfCompliments,
            ])
        
        fetchUser(userEmail: user.email)
    }
    
    func removeUser(_ user: User) {
        database.collection("Users")
            .document(user.id).delete()
        fetchUser(userEmail: user.email)
    }
    
    func updateUserNickname(nickname: String) {
        database.collection("Users")
            .document(self.user.email)
            .updateData(
                ["nickname" : nickname]
            ) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        
        fetchUser(userEmail: self.user.email)
    }
    
    func addNumberOfCompliments() {
        database.collection("Users")
            .document(self.user.email)
            .updateData(
                ["totalNumberOfCompliments" : self.user.totalNumberOfCompliments + 1]
            ) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        
        fetchUser(userEmail: self.user.email)
    }
}
