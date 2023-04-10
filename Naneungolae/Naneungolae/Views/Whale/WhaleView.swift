//
//  WhaleView.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI
import AlertToast

struct WhaleView: View {
    
    @State private var isMoving: Bool = false
    @State private var food: Int = 3
    @State private var exp: Double = 0.0
    @State private var level: Int = 1
    @State private var total: Double = 50
    @State private var isUpLevel: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack {
                    Text("Whale")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    NavigationLink(destination: Text("collectionview")) {
                        Image(systemName: "text.book.closed")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }
                }
                .background(Color("mainColor"))
                
                VStack {
                    Spacer()
                    
                    HStack {
                        HStack(spacing: 10) {
                            Image("whaleBob")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.leading, 20)
                                .onDrag {
                                    NSItemProvider()
                                }
                            
                            HStack {
                                Text("\(Image(systemName: "multiply"))")
                                    .foregroundColor(.black)
                                    .padding(.leading, -5)
                                
                                Text("\(food)")
                                    .foregroundColor(food > 0 ? .black : .red)
                                    .padding(.leading, -5)
                            }
                        }
                        Spacer()
                        Label("도커고래Lv.\(level)", systemImage: "figure.fishing")
                            .font(.title3)
                            .padding()
                    }
                    
                    VStack {
                        HStack {
                            Text("Lv.\(level)")
                                .fontWeight(.thin)
                            Spacer()
                            Text("Lv.\(level + 1)")
                                .fontWeight(.thin)
                        }
                        .padding(.horizontal, 10)
                        ProgressView("", value: exp, total: total)
                            .animation(.linear)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        Image("aquarium")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: 500)
                        Image("whale2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 400)
                            .offset(x: isMoving ? 80 : -80 , y: isMoving ? 100 : -100)
                            .animation(Animation.easeInOut(duration: 5).repeatForever(),
                                       value: isMoving)
                            .onDrop(of: [.text], delegate: FoodDropDelegate(exp: $exp, level: $level, total: $total, food: $food, isUpLevel: $isUpLevel))
                    }
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            isMoving = true
                        })
                    })
                }
            }
            .toast(isPresenting: $isUpLevel){
                
                // `.alert` is the default displayMode
//                AlertToast(type: .regular, title: "고래 레벨업!")
                //Choose .hud to toast alert from the top of the screen
                //            AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
                AlertToast(type: .image("alertWhale", Color.red), title: "고래 레벨업!")
                //Choose .banner to slide/pop alert from the bottom of the screen
                //            AlertToast(displayMode: .banner(.slide), type: .regular, title: "Message Sent!")
            }
        }
    }
}

fileprivate
struct FoodDropDelegate: DropDelegate {
    
    @Binding var exp: Double
    @Binding var level: Int
    @Binding var total: Double
    @Binding var food: Int
    @Binding var isUpLevel: Bool
    
    
    func performDrop(info: DropInfo) -> Bool {
        guard food > 0 else {
            return true
        }
        food -= 1
        self.exp += 20
        
        if exp > total {
            level += 1
            total += 40
            exp = 0
            isUpLevel.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                isUpLevel.toggle()
            }
        }
        return true
    }
}
struct WhaleView_Previews: PreviewProvider {
    static var previews: some View {
        WhaleView()
    }
}
