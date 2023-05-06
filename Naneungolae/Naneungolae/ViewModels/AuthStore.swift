//
//  AuthStore.swift
//  Whale_MVP
//
//  Created by 서찬호 on 2023/03/30.
//

import Foundation
import FirebaseAuth
import Firebase

class AuthStore: ObservableObject {
    
    let userStore: UserStore = UserStore()
    
    @Published var currentUser: Firebase.User?
    @Published var loginError: Bool = false
    
    let auth = Auth.auth()
    
    init() {
        currentUser = auth.currentUser
    }
    
    func registerUser(email: String, password: String, nickname: String) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Error: \(error.localizedDescription)")
            }
            
            guard let user = authResult?.user else { return }
            
            self.userStore.createUser(User(id: email, email: email, nickname: nickname, totalNumberOfCompliments: 0))
            self.currentUser = user
        }
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Error: \(error.localizedDescription)")
                self.loginError = true
                return
            } else {
                self.loginError = false
            }
            
            guard let user = authResult?.user else { return }
            self.currentUser = user
        }
    }
    
    func signOut() {
        currentUser = nil
        try? auth.signOut()
        print("logout complete")
    }
}

