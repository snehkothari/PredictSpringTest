//
//  Product.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 28/09/22.
//

import Foundation

struct Product: Codable, Identifiable {
    var productId: String
    var title: String
    var listPrice: Double
    var salesPrice: Double
    var color: String
    var size: String
    var id: String { productId}
}
