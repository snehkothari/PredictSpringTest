//
//  SearchBar.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 28/09/22.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @ObservedObject var databaseManager: DatabaseManager
    var body: some View {
        HStack {
            TextField("Search Id...", text: $searchText)
                .keyboardType(.numberPad)
                .border(.black)
                .padding(.leading)
                .font(.title2)
            Button(action: {
                self.hideKeyboard()
                databaseManager.newSearch(id: "", inputString: searchText)
            }){
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFit()
                    .foregroundColor(.black)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""), databaseManager: DatabaseManager())
    }
}
