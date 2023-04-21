//
//  ContentView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authStore: AuthStore
    
    var body: some View {
        NavigationStack {
            VStack {
                if authStore.isLogin {
                    MainTabView()
                } else {
                    LoginView()
                }
                /*
                if let authStore.currentUser {
                    // 뷰
                } else {
                    // 로그인뷰
                }
                 */
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
