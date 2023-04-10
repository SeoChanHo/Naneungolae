//
//  MyPageView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
        VStack {
            HStack {
                Text("MyPage")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
            }
            .background(Color("mainColor"))
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
