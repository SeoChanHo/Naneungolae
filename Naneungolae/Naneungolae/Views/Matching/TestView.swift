//
//  TestView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/10.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(feedStore.completedFeed) { feed in
                    VStack {
                        Text(feed.id)
                        Text(feed.category)
                        Text(feed.senderEmail)
                        Text(feed.senderNickname)
                        Text("\(feed.createdAt)")
                        Text(feed.senderPost)
                        ForEach(feed.images, id: \.self) { imageName in
                            Image(uiImage: feedStore.imageDict[imageName] ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                        }
                    }
                    .padding(.bottom, 20)
                    VStack {
                        Text(feed.receiverEmail)
                        Text(feed.receiverNickname)
                        Text(feed.receiverPost)
                    }
                }
            }
            
        }
        .task {
            feedStore.fetchCompletedFeed(userEmail: userStore.user.email)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
