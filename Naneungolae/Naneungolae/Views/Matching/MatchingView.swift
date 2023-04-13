//
//  MatchingView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI
import PhotosUI

struct MatchingView: View {
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var authStore: AuthStore

    // 새로운 포토스 피커
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    var keywords: [String] = ["응원", "위로", "자신감", "목표달성", "인정", "축하"]
    @State var selectedKeyword: String = "응원"
    @State var complimentText: String = ""
    @State var isShowingNotificationList: Bool = false
    @State var isNotification: Bool = false
    
    func selectedPhotosToUIImage() -> [UIImage] {
        var uiImages = [UIImage]()
        for photoData in selectedPhotosData {
            uiImages.append(UIImage(data: photoData)!)
        }
        return uiImages
    }
    
    var body: some View {
        ZStack {
            Color("mainColor")
                .edgesIgnoringSafeArea(.top)
            VStack {
                
                HStack {
                    Text("나는고래")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .padding()
                    Spacer()
                    ZStack {
                        Button {
                            isShowingNotificationList.toggle()
                        } label: {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                                .padding()
                        }
                        
                        if isShowingNotificationList {
                            ScrollView {
                                ForEach(feedStore.notificationFeed) { feed in
                                    if feed.isdoneMatching && !feed.isdoneReply {
                                        Text("매칭 완료")
                                    } else if feed.isdoneMatching && feed.isdoneReply {
                                        NavigationLink {
                                            MyPageView()
                                        } label: {
                                            Text("칭찬 완료")
                                        }
                                    }
                                }
                            }
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .offset(y: 100)
                            .padding()
                        }
                    }
                }
                ScrollView {
                    HStack {
                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .overlay {
                                    Image(systemName: "camera.fill")
                                }
                                .padding(.horizontal)
                        }
                        .foregroundColor(.black)
                        .onChange(of: selectedItems) { newItems in
                            for newItem in newItems {
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                                        selectedPhotosData.append(data)
                                    }
                                }
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedPhotosData, id: \.self) { photoData in
                                    if let image = UIImage(data: photoData) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: 60, height: 60)
                                            .overlay {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(10.0)
                                                    .padding(.horizontal)
                                            }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    HStack {
                        Text("키워드를 선택하세요")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Picker("키워드를 선택하세요", selection: $selectedKeyword) {
                            
                            ForEach(keywords, id: \.self) { keyword in
                                Text(keyword)
                                
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .fontWeight(.bold)
                        .zIndex(2)
                    }
                    TextEditor(text: $complimentText)
                        .frame(width: 350, height: 200, alignment: .top)
                        .background(Color.white)
                        .padding()
                        .autocapitalization(.none)
                    
                    Button {
                        feedStore.addFeed(
                            Feed(
                                id: userStore.user.email,
                                category: selectedKeyword,
                                images: [],
                                senderEmail: userStore.user.email,
                                senderNickname: userStore.user.nickname,
                                senderPost: complimentText,
                                receiverNickname: "",
                                receiverEmail: "",
                                receiverPost: "",
                                isdoneMatching: false,
                                isdoneReply: false,
                                isdoneReplyMatchedFeed: false,
                                matchedFeedID: ""
                            ),
                            images: selectedPhotosToUIImage()
                        )
                        
                        selectedItems = []
                        selectedPhotosData = []
                        complimentText = ""
                        
                    } label: {
                        Text("매칭 하기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    NavigationLink {
                        writeComplimentView()
                        
                    } label: {
                        Text("칭찬답글 하러가기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    
                    NavigationLink {
                        TestView()
                    } label: {
                        Text("칭찬 받은 글 보러가기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .scrollDisabled(true)
            }
        }
        .task {
            userStore.fetchUser(userEmail: authStore.currentUser?.email ?? "")
            feedStore.notifyMatchingComplete(userEmail: authStore.currentUser?.email ?? "")
        }
    }
    
}

struct MatchingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchingView()
    }
}
