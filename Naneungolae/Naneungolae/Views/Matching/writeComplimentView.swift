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
    
    @State private var complimentText: String = ""
    @State private var isShowingToast: Bool = false
    
    var body: some View {
        VStack {
            if feedStore.matchedOpponentFeed.isEmpty {
                Spacer()
                Text("매칭된 칭찬이 없습니다")
                    .font(.title)
                Spacer()
            } else {
                ScrollView {
                    ForEach(feedStore.matchedOpponentFeed) { feed in
                        matchedOpponentFeedListCell(isShowingToast: $isShowingToast, feed: feed)
                    }
                }
            }
        }
        .task {
            feedStore.fetchMatchedOpponentFeed(userEmail: userStore.user.email)
        }
        .toast(isPresenting: $isShowingToast){
            AlertToast(type: .complete(Color("mainColor")), title: "칭찬 작성 완료!")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("매칭된 상대방 글")
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("mainColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct matchedOpponentFeedListCell: View {
    @EnvironmentObject var userStore : UserStore
    @EnvironmentObject var feedStore : FeedStore
    @State private var complimentText: String = ""
    @Binding var isShowingToast: Bool
    let feed: Feed
    
    var body: some View {
        VStack {
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
            
            TextEditor(text: $complimentText)
                .frame(width: 350, height: 150, alignment: .top)
                .border(.black, width: 1)
                .padding(.horizontal, 10)
                .autocapitalization(.none)
            
            
            Button {
                feedStore.updateOpponentFeed(userEmail: userStore.user.email ,feedID: feed.id, matchedFeedID: feed.matchedFeedID, text: complimentText)
                isShowingToast.toggle()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    isShowingToast.toggle()
                }
            } label: {
                Text("칭찬글 작성 완료")
                    .font(.system(size: 17))
                    .bold()
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                    .padding()
                    .background(Color("mainColor"))
                    .cornerRadius(10)
            }
            .padding()

            Divider()
                .foregroundColor(.black)
        }
    }
}

struct writeComplimentView_Previews: PreviewProvider {
    static var previews: some View {
        writeComplimentView()
    }
}
