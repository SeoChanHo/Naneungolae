//
//  SignupView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/05.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nickname: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isPasswordValid: Bool = true
    @State private var isNicknameValid: Bool = true
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
        case nickname
    }
    
    var body: some View {
        ZStack {
            Color("mainColor")
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment:.leading) {
                        Text("이메일")
                        TextField("이메일을 입력해주세요", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                        if !isEmailValid {
                            Text("Email is Not Valid")
                                .font(.callout)
                                .foregroundColor(Color.red)
                        }
                        
                    }
                    VStack(alignment:.leading) {
                        Text("비밀번호")
                        SecureField("6 ~ 12 글자 비밀번호를 입력해주세요", text: $password)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                focusedField = .nickname
                            }
                        
                        if !isPasswordValid {
                            Text("Password is Not Valid")
                                .font(.callout)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    VStack(alignment:.leading) {
                        Text("닉네임")
                        TextField("10 글자 이하 닉네임을 입력해주세요", text: $nickname)
                            .autocapitalization(.none)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                            .focused($focusedField, equals: .nickname)
                            .onSubmit {
                                if email.isEmpty {
                                    focusedField = .email
                                } else if password.isEmpty {
                                    focusedField = .password
                                } else if nickname.isEmpty {
                                    focusedField = .nickname
                                } else {
                                    isEmailValid = checkEmailValid(email)
                                    isPasswordValid = checkPasswordValid(password)
                                    isNicknameValid = checkNicknameValid(nickname)
                                    if isEmailValid, isPasswordValid, isNicknameValid {
                                        authStore.registerUser(email: email, password: password, nickname: nickname)
                                        dismiss()
                                    }
                                }
                            }
                        
                        if !isNicknameValid {
                            Text("Nickname is Not Valid")
                                .font(.callout)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    Button {
                        if email.isEmpty {
                            focusedField = .email
                        } else if password.isEmpty {
                            focusedField = .password
                        } else if nickname.isEmpty {
                            focusedField = .nickname
                        } else {
                            isEmailValid = checkEmailValid(email)
                            isPasswordValid = checkPasswordValid(password)
                            isNicknameValid = checkNicknameValid(nickname)
                            if isEmailValid, isPasswordValid, isNicknameValid {
                                authStore.registerUser(email: email, password: password, nickname: nickname)
                                dismiss()
                            }
                        }
                    } label: {
                        Text("회원가입")
                            .font(.title3)
                            .foregroundColor(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 100, height: 12)
                            .padding()
                            .background(Color("buttonColor"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 10)
                }
                .bold()
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                .padding(.top, 30)
            }
        }
        .onTapGesture {
            endTextEditing()
        }

    }
    
    func checkEmailValid(_ string: String) -> Bool {
        if string.count > 100 { return false }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    func checkPasswordValid(_ string: String) -> Bool {
        if string.count < 6 || string.count > 12 {
            return false
        } else {
            return true
        }
    }
    
    func checkNicknameValid(_ string: String) -> Bool {
        if string.count == 0 || string.count > 10 {
            return false
        } else {
            return true
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
