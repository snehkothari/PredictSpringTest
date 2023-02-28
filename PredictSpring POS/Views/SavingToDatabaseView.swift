//
//  SavingToDatabaseView.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 29/09/22.
//

import SwiftUI

struct SavingToDatabaseView: View {
    @ObservedObject var databaseManager: DatabaseManager
    @Binding var currentState: appState
    var url: URL?
    var body: some View {
        ProgressView(currentState.rawValue, value: databaseManager.progress, total: databaseManager.total)
            .padding()
            .onAppear {
                DispatchQueue.global().async {
                    databaseManager.saveDataFromCSV(url: url)
                }
            }
            .onChange(of: databaseManager.databaseSaveComplete) {complete in
                if complete {
                    currentState = .Ready
                }
            }

    }
}

struct SavingToDataBaseView_Previews: PreviewProvider {
    static var previews: some View {
        SavingToDatabaseView(databaseManager: DatabaseManager(), currentState: .constant(.SavingToDatabase))
    }
}
