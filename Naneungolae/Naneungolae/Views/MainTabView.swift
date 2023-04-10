//
//  MainTabView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI

struct MainTabView: View {
    @State private var tabSelector: Int = 1
    
    var body: some View {
        NavigationStack {
            TabView(selection: $tabSelector) {
                MatchingView()
                    .tabItem {
                        Image(systemName: "paperplane.circle.fill")
                        Text("매칭")
                    }.tag(1)
                WhaleView()
                    .tabItem {
                        Image(systemName : "fish.circle")
                        Text("고래키우기")
                    }.tag(2)
                MyPageView()
                    .tabItem {
                        Image(systemName: "face.smiling")
                        Text("마이페이지")
                    }.tag(3)
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
