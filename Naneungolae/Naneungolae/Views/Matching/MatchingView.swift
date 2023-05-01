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
//    @EnvironmentObject var notificationStore: NotificationStore
    
    // 포토스 피커
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    var keywords: [String] = ["응원", "위로", "자신감", "목표달성", "인정", "축하"]
    @State var selectedKeyword: String = "응원"
    @State var complimentText: String = ""
    
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
                    NavigationLink {
                        NotificationListView()
                    } label: {
                        if feedStore.notifications.isEmpty {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .bold()
                                .padding()
                        } else {
                            Image(systemName: "bell.badge.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .yellow)
                                .font(.title2)
                                .bold()
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
                        Spacer()
                        
                        Text("받고 싶은 칭찬 키워드를 선택하세요")
                            .foregroundColor(.white)
                        Spacer()
                        
                        Picker("키워드를 선택하세요", selection: $selectedKeyword) {
                            
                            ForEach(keywords, id: \.self) { keyword in
                                Text(keyword)
                                
                            }
                        }
                        .pickerStyle(.menu)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("buttonColor")))
                        .frame(width: 110)
                        .tint(Color.white)
                        .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .bold()
                    
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
                            .font(.title3)
                            .bold()
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
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .scrollDisabled(true)
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .task {
            userStore.fetchUser(userEmail: authStore.currentUser?.email ?? "")
            feedStore.notifyMatchingComplete(userEmail: authStore.currentUser?.email ?? "")
            feedStore.fetchNotification(userEmail: authStore.currentUser?.email ?? "")
        }
    }
    
}

struct MatchingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchingView()
    }
}
