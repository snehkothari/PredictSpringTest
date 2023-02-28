//
//  RowCard.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 28/09/22.
//

import SwiftUI

struct RowCard: View {
    var product: Product
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(product.title)
                Spacer()
            }
                .padding()
                .background(Color.gray)
            
            VStack(alignment: .leading) {
                Text("ID: \(product.productId)")
                
                HStack {
                    VStack(alignment: .leading){
                        Text("List Price:" +  product.listPrice.roundToTwoPlacesString)
                        Text("Color: \(product.color)")
                    }
                    Spacer()
                    VStack(alignment: .leading){
                        Text("Sales Price: " + product.salesPrice.roundToTwoPlacesString)
                        
                        Text("Size: \(product.size)")
                    }
                }
            }.padding()
        }
        .background(Color(UIColor.systemGray6))
        .shadow(radius: 2)
        .padding()
            
    }
}

struct RowCard_Previews: PreviewProvider {
    static var previews: some View {
        RowCard(product: Product(productId: "99000025001002", title: "NK XY Core Vent Comp Shor", listPrice: 14.97, salesPrice: 14.97, color: "Black", size: "MD"))
    }
}
