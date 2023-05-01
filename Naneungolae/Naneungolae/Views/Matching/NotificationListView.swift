//
//  NotificationListView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/28.
//

import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var feedStore: FeedStore
    
    var body: some View {
        VStack {
            if feedStore.notifications.isEmpty {
                Spacer()
                Text("알림이 없습니다")
                    .font(.title)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    ForEach(feedStore.notifications) { notification in
                        NavigationLink {
                            if notification.notificationType == "matching" {
                                writeComplimentView()
                            } else {
                                MyPageFeedDetailView(feed: feedStore.notificationMatchedFeed[notification.id] ?? Feed(id: "", category: "", images: [], senderEmail: "", senderNickname: "", senderPost: "", receiverNickname: "", receiverEmail: "", receiverPost: "", isdoneMatching: false, isdoneReply: false, isdoneReplyMatchedFeed: false, matchedFeedID: ""))
                            }
                        } label: {
                            NotificationListCell(notification: notification)
                        }
                        .foregroundColor(.black)
                    }
                }
                .padding(.top, 10)
            }
        }
        .task {
            feedStore.notifyMatchingComplete(userEmail: userStore.user.email)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("mainColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct NotificationListCell: View {
    let notification: Notification
    var body: some View {
        HStack {
            if notification.notificationType == "matching" {
                Image(systemName: "paperplane.circle.fill")
                    .foregroundColor(Color("mainColor"))
                    .font(.largeTitle)
                    .padding()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("매칭이 완료됐습니다!")
                            .bold()
                        Spacer()
                        Text(notification.dateText)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 20)
                    }
                    Text("상대방 칭찬글을 작성해주세요")
                        .bold()
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("mainColor"))
                    .font(.largeTitle)
                    .padding()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("칭찬이 완료됐습니다!")
                            .bold()
                        Spacer()
                        Text(notification.dateText)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 20)
                    }
                    Text("상대방이 보낸 칭찬글을 확인해주세요")
                        .bold()
                }
            }
            Spacer()
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
    }
}
