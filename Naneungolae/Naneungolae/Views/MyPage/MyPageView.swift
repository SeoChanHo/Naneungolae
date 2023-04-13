//
//  MyPageView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        VStack {
            HStack {
                Text("MyPage")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
            }
            .background(Color("mainColor"))
            .padding(.bottom, 20)
            
            ScrollView {
                ForEach(feedStore.myPageFeed) { feed in
                    VStack {
                        Text("내가 쓴 글 : \(feed.senderPost)")
                        Text("상대 닉네임 : \(feed.receiverNickname)")
                        Text("상대가 쓴 글 : \(feed.receiverPost)")
                        
                    }
                }
            }
        }
        .task {
            feedStore.fetchCompletedFeedInMyPage(userEmail: userStore.user.email)
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
