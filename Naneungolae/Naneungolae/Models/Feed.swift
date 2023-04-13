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
    
    var dateText: DateFormatter {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_KR")
        format.dateFormat = "YYYY년 M월 d일"
        return format
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
    
    // 매칭된 두 Feed에 같은 matchingID를 저장해서 1대1로 연결해준다
    let matchedFeedID: String
}
