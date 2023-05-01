//
//  MyPageFeedDetailView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/24.
//

import SwiftUI

struct MyPageFeedDetailView: View {
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var userStore: UserStore
    
    let feed: Feed
    
    var body: some View {
        ScrollView {
            HStack {
                Image("whale1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(feed.senderNickname)
                    .font(.title3)
                Spacer()
                Text(feed.dateText)
                    .font(.body)
            }
            .padding()
            VStack {
                if feed.images.isEmpty {
                    Image("alertWhale")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal)
                } else {
                    GeometryReader { proxy in
                        TabView {
                            ForEach(feed.images, id: \.self) { imageName in
                                Rectangle()
                                    .foregroundColor(.gray)
                                    .opacity(0.1)
                                    .cornerRadius(10)
                                    .overlay {
                                        Image(uiImage: feedStore.imageDict[imageName] ?? UIImage())
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 300)
            
            Text(feed.senderPost)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Divider()
                .padding(.horizontal)
            
            HStack {
                Text(feed.category)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.cyan))
                Text("이(가) 담긴 칭찬을 해주세요!")
            }
            .bold()
            .padding(.horizontal)
            .padding(.vertical, 5)
            

            Divider()
                .foregroundColor(.black)
            
            HStack {
                Image("whale1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(feed.receiverNickname)
                    .font(.title3)
                Spacer()
            }
            .padding()
            
            Text(feed.receiverPost)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .onAppear {
            feedStore.deleteCompleteNotification(userEmail: userStore.user.email, feedID: feed.id)
        }
    }
}

//struct MyPageFeedDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyPageFeedDetailView()
//    }
//}
