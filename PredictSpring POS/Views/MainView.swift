//
//  MainView.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 29/09/22.
//

import SwiftUI

struct MainView: View {
    @State var searchText: String = ""
    @ObservedObject var databaseManager: DatabaseManager
    var body: some View {
        VStack {
            SearchBar(searchText: $searchText, databaseManager: databaseManager)
            ScrollView {
                LazyVStack{
                    ForEach(databaseManager.result) {product in
                        RowCard(product: product)
                            .onAppear {
                                databaseManager.loadNext(id: product.id, inputString: searchText)
                            }
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(databaseManager: DatabaseManager())
    }
}
