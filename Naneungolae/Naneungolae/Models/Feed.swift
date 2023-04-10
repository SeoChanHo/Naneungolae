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
    
    var isdoneMatching: Bool
    var isdoneReply: Bool
}
