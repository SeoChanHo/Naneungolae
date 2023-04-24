//
//  Feed.swift
//  Whale_MVP
//
//  Created by 서찬호 on 2023/03/30.
//

import SwiftUI

struct Feed: Codable, Identifiable {
    let id: String
    let category: String
    let images: [String]
    var createdAt: Date = Date()
    var isBookmarked: Bool = false
    
    var dateText: String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_KR")
        format.dateFormat = "YYYY년 M월 d일 HH:mm"
        return format.string(from: createdAt)
    }
    
    // 발신자
    let senderEmail: String
    let senderNickname: String
    let senderPost: String
    
    // 수신자
    let receiverNickname: String
    let receiverEmail: String
    let receiverPost: String
    
    let isdoneMatching: Bool
    let isdoneReply: Bool
    
    // 이 Feed에 매칭된 글에 답장을 했는지 여부
    let isdoneReplyMatchedFeed: Bool
    
    // 매칭된 Feed의 ID를 저장하는 프로퍼티
    let matchedFeedID: String
}
