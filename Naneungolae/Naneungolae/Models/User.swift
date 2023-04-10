//
//  User.swift
//  Whale_MVP
//
//  Created by ㅇㅇ on 2022/12/19.
//

import SwiftUI

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let nickname: String
    let totalNumberOfCompliments: Int
}
