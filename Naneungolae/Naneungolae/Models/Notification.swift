//
//  Notification.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/25.
//

import Foundation

struct Notification: Codable, Identifiable {
    let id: String
    let date: Date
    let notificationType: String
    var dateText: String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_KR")
        format.dateFormat = "M월 d일 HH:mm"
        return format.string(from: date)
    }
}
