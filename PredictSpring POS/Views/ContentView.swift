//
//  ContentView.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 22/09/22.
//

import SwiftUI
enum appState: String {
    case Downloading = "Downloading"
    case SavingToDatabase = "Loading Database"
    case Ready = "Ready"
    
}
struct ContentView: View {
    @ObservedObject var downloadTask = DownloadTask()
    @ObservedObject var databaseManager = DatabaseManager()
    
    @State var currentState: appState = .Downloading
    
    var body: some View {
        switch currentState {
        case .Downloading:
            DownloadProgressView(downloadTask: downloadTask, currentState: $currentState)
        case .SavingToDatabase:
            SavingToDatabaseView(databaseManager: databaseManager, currentState: $currentState, url: downloadTask.csvUrl)
        case .Ready:
            MainView(databaseManager: databaseManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
