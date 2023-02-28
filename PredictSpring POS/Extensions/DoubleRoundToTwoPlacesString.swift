//
//  DoubleRoundToTwoPlacesString.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 28/09/22.
//

import Foundation

extension Double {
    var roundToTwoPlacesString:String {
        return String(format: "%.2f", self)
    }
}
