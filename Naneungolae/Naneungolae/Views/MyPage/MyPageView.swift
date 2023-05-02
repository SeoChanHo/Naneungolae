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
    
    @State private var isEditingNickname: Bool = false
    @State private var isValidNickname: Bool = true
    @State private var isShowingFavorites: Bool = false
    @State private var nickname: String = ""
    @FocusState private var focusedField: Bool
    
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
                VStack {
                    if isEditingNickname {
                        TextField("닉네임을 입력해주세요", text: $nickname)
                            .font(.title2)
                            .frame(width: 300, height: 25)
                            .focused($focusedField)
                        Rectangle()
                            .frame(width: 320 ,height: 1, alignment: .bottom)
                        
                        Text("10자 이내로 새로운 닉네임을 입력해주세요.")
                            .foregroundColor(isValidNickname ? .gray : .red)
                            .font(.caption)
                        HStack(spacing: 40) {
                            Button {
                                if checkNicknameValid(nickname) {
                                    userStore.updateUserNickname(nickname: nickname)
                                    isValidNickname = true
                                    isEditingNickname.toggle()
                                } else {
                                    isValidNickname = false
                                }
                            } label: {
                                Text("완료")
                                    .foregroundColor(Color("mainColor"))
                                    .font(.headline)
                                    .bold()
                            }
                            Button {
                                isEditingNickname.toggle()
                            } label: {
                                Text("취소")
                                    .foregroundColor(.red)
                                    .font(.headline)
                                    .bold()
                            }
                        }
                        .padding(.top, 5)
                    } else {
                        HStack {
                            Text("내 닉네임 : ")
                                .font(.title3)
                                .padding(.leading, 20)
                            Text(userStore.user.nickname)
                                .font(.title2)
                                .bold()
                            Spacer()
                            Button {
                                nickname = userStore.user.nickname
                                isEditingNickname.toggle()
                                focusedField = true
                            } label: {
                                Text("수정")
                                    .foregroundColor(Color("mainColor"))
                                    .font(.headline)
                                    .bold()
                            }
                            .padding(.trailing, 30)
                        }
                        
                        HStack {
                            Text("총 칭찬 수 : ")
                                .font(.title3)
                                .padding(.leading, 20)
                            Text("\(userStore.user.totalNumberOfCompliments)")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                    Divider()
                }
                .frame(height: 110)
                .padding(.bottom, 10)
                
                Text("받은 칭찬 리스트")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                Spacer()
                HStack {
                    Spacer()
                    Text("즐겨찾기만 보기")
                    Toggle("Favorites", isOn: $isShowingFavorites).labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.yellow))
                        .padding(.trailing, 10)
                }

                if isShowingFavorites {
                    if feedStore.favoritesFeed.isEmpty {
                        Text("즐겨찾기한 칭찬이 없습니다")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding(.top, 50)
                    } else {
                        ForEach(feedStore.favoritesFeed) { feed in
                            NavigationLink {
                                MyPageFeedDetailView(feed: feed)
                            } label: {
                                myPageFeedListCell(feed: feed)
                            }
                            .foregroundColor(.black)
                        }
                    }
                } else {
                    if feedStore.myPageFeed.isEmpty {
                        Text("받은 칭찬이 없습니다")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .padding(.top, 50)
                    } else {
                        ForEach(feedStore.myPageFeed) { feed in
                            NavigationLink {
                                MyPageFeedDetailView(feed: feed)
                            } label: {
                                myPageFeedListCell(feed: feed)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .task {
            feedStore.fetchCompletedFeedInMyPage(userEmail: userStore.user.email)
        }
    }
    
    func checkNicknameValid(_ string: String) -> Bool {
        if string.count == 0 || string.count > 10 {
            return false
        } else {
            return true
        }
    }
}

struct myPageFeedListCell: View {
    @EnvironmentObject var feedStore: FeedStore
    let feed: Feed
    
    var body: some View {
        HStack(alignment: .top) {
            if feed.images.isEmpty {
                Image("alertWhale")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(5)
                    .padding()
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.1)
                    .cornerRadius(5)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(uiImage: feedStore.imageDict[feed.images[0]] ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(5)
                    }
                    .padding()
            }
            
            VStack(alignment: .leading) {
                Text(feed.senderPost)
                    .font(.title3)
                    .lineLimit(1)
                Spacer()
                Text(feed.dateText)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            Spacer()
            Button {
                feedStore.settingFavoritesFeed(feedID: feed.id, isBookmarked: feed.isBookmarked, userEmail: feed.senderEmail)
            } label: {
                Image(systemName: feed.isBookmarked ? "star.fill" : "star")
                    .font(.title)
                    .foregroundColor(.yellow)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.trailing, 10)
       
        }
    }
}

//struct MyPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyPageView()
//    }
//}
