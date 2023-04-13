//
//  writeComplimentView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/12.
//

import SwiftUI
import AlertToast

struct writeComplimentView: View {
    @EnvironmentObject var feedStore : FeedStore
    @EnvironmentObject var userStore: UserStore
    
    @State var complimentText: String = ""
    @State var isShowingToast: Bool = false
    var body: some View {
        ZStack {
            Color("mainColor")
                .edgesIgnoringSafeArea(.top)
            ScrollView {
                ForEach(feedStore.matchedOpponentFeed) { feed in
                    VStack {
                        Text("매칭된 상대방 글")
                            .font(.title)
                            .padding()
                        Text(feed.senderNickname)
                            .padding()
                        Text(feed.category)
                            .padding()
                        Text("\(feed.dateText)")
                            .padding()
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(feed.images, id: \.self) { imageName in
                                    Image(uiImage: feedStore.imageDict[imageName] ?? UIImage())
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 300)
                                }
                            }
                        }
                        .padding()
                        Text(feed.senderPost)
                            .padding()
                        
                        TextEditor(text: $complimentText)
                            .frame(width: 350, height: 200, alignment: .top)
                            .background(Color.white)
                            .padding()
                            .autocapitalization(.none)
                        
                        Button {
                            feedStore.updateOpponentFeed(feedID: feed.id, matchedFeedID: feed.matchedFeedID, text: complimentText)
                            feedStore.fetchMatchedOpponentFeed(userEmail: userStore.user.email)
                            isShowingToast.toggle()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                isShowingToast.toggle()
                            }
                        } label: {
                            Text("칭찬글 작성 완료")
                        }
                        
                        Divider()
                    }
                }
            }
            .task {
                feedStore.fetchMatchedOpponentFeed(userEmail: userStore.user.email)
            }
            .toast(isPresenting: $isShowingToast){
                AlertToast(type: .complete(Color("mainColor")), title: "칭찬 작성 완료!")
            }
        }
    }
}

struct writeComplimentView_Previews: PreviewProvider {
    static var previews: some View {
        writeComplimentView()
    }
}
