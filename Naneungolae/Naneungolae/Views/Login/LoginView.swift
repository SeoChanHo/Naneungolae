//
//  LoginView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/05.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore
    
    @State private var email: String = "test@test.com"
    @State private var password: String = "123123"
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        ZStack {
            Color("mainColor")
                .ignoresSafeArea()
            
            
            VStack {

                Image("LoginWhale")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 30)
                    .padding(.top, 50)
                
                VStack(spacing: 20) {
                    VStack(alignment:.leading) {
                        TextField("이메일을 입력해주세요", text: $email)
                            .autocapitalization(.none)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                    }
                    
                    VStack(alignment:.leading) {
                        SecureField("비밀번호를 입력해주세요", text: $password)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                if email.isEmpty {
                                    focusedField = .email
                                } else if password.isEmpty {
                                    focusedField = .password
                                } else {
                                    authStore.signIn(email: email, password: password)
                                }
                            }
                    }
                    
                    HStack(spacing: 40) {
                        VStack {
                            Button {
                                if email.isEmpty {
                                    focusedField = .email
                                } else if password.isEmpty {
                                    focusedField = .password
                                } else {
                                    authStore.signIn(email: email, password: password)
                                }
                            } label: {
                                Text("로그인")
                                    .font(.title3)
                                    .foregroundColor(Color.white)
                                    .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                                    .padding()
                                    .background(Color("buttonColor"))
                                    .cornerRadius(10)
                            }
                            
                            HStack {
                                Button {
                                } label: {
                                    Text("계정찾기")
                                }
                                .padding(.leading, 30)
                                
                                Spacer()

                                NavigationLink {
                                    SignupView()
                                } label: {
                                    Text("회원가입")
                                }
                                .padding(.trailing, 35)
                            }
                            .padding(10)
                            
                            
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                .foregroundColor(.black)
                .bold()
                .padding(.horizontal)
                Spacer()
                
            }
        }
        .onTapGesture {
            endTextEditing()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
