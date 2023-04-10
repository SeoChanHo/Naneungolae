//
//  MatchingView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI

struct MatchingView: View {
    var keywords: [String] = ["응원", "위로", "자신감", "목표달성", "인정", "축하"]
    @State var selectedKeyword: String = "응원"
    @State var complimentText: String = ""
    
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
                    
                }
                ScrollView {
                    HStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Button {
                            
                        } label: {
                            Text("사진 추가")
                                .font(.system(size: 15))
                                .frame(width: 70)
                                .cornerRadius(16)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    HStack {
                        Text("키워드를 선택하세요")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Picker("키워드를 선택하세요", selection: $selectedKeyword) {
                            
                            ForEach(keywords, id: \.self) { keyword in
                                Text(keyword)
                                
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .fontWeight(.bold)
                        .zIndex(2)
                    }
                    TextEditor(text: $complimentText)
                        .frame(width: 350, height: 200, alignment: .top)
                        .background(Color.white)
                        .padding()
                        .autocapitalization(.none)
                    
                    Button {
                        
                    } label: {
                        Text("매칭 하기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    NavigationLink {
                        
                        
                    } label: {
                        Text("칭찬답글 하러가기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        Text("칭찬 받은 글 보러가기")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .scrollDisabled(true)
            }
        }
        
    }
    
}

struct MatchingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchingView()
    }
}
