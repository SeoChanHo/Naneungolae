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
    let image: String
    let createdAt: String
    
    // 발신자
    let senderEmail: String
    let senderNickname: String
    
    // 수신자
    let receiverNickname: String
    let receiverEmail: String
    let reply: String
    
    var isdoneMatching: Bool
    var isdoneReply: Bool
}
