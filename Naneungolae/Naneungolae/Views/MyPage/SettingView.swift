//
//  SettingView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/05.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ListItem(imageName: "phone.and.waveform", menuName: "신고하기")
            ListItem(imageName: "bell", menuName: "알림")
            ListItem(imageName: "lock", menuName: "개인정보 보호")
            ListItem(imageName: "checkmark.seal", menuName: "보안")
            ListItem(imageName: "light.beacon.min", menuName: "광고")
            ListItem(imageName: "person.circle", menuName: "계정")
            ListItem(imageName: "info.circle", menuName: "정보")

            Button {
                dismiss()
                authStore.signOut()
            } label: {
                Text("로그아웃")
            }
        }
        .scrollDisabled(true)
    }
}

struct ListItem: View {
    var imageName: String
    var menuName: String
    
    var body: some View {
        HStack{
            Image(systemName: imageName)
            Text(menuName)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
