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
                if let _ = authStore.currentUser {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
