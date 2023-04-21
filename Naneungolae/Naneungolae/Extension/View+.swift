//
//  View+.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/14.
//

import Foundation
import SwiftUI

// MARK: - 빈 공간 터치로 키보드를 내리기 위한 View Extension
/// 필요한 View에서 onTapGesture를 통해 사용
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil
        )
    }
}
