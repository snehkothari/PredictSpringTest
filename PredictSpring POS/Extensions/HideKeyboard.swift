//
//  HideKeyboard.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 29/09/22.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
