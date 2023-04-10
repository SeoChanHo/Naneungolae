//
//  AuthStore.swift
//  Whale_MVP
//
//  Created by 서찬호 on 2023/03/30.
//

import Foundation
import FirebaseAuth

class AuthStore: ObservableObject {
    
    let userStore: UserStore = UserStore()
    
    @Published var isLogin: Bool = false
    
    let auth = Auth.auth()
    
    func registerUser(email: String, password: String, nickname: String) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Error: \(error.localizedDescription)")
            }
            
            guard (authResult?.user) != nil else { return }
            
            self.userStore.createUser(User(id: email, email: email, nickname: nickname, totalNumberOfCompliments: 0))
            self.isLogin = true
        }
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error {
                print("Error: \(error.localizedDescription)")
            }
            
            guard let user = authResult?.user else { return }
            
            self?.userStore.fetchUser(userEmail: user.email ?? "")
            self?.isLogin = true
        }
    }
    
    func signOut() {
        try? auth.signOut()
        self.isLogin = false
        print("logout complete")
    }
}

