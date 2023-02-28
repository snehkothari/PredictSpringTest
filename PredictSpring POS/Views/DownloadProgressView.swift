//
//  DownloadProgressView.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 29/09/22.
//

import SwiftUI

struct DownloadProgressView: View {
    @ObservedObject var downloadTask: DownloadTask
    @Binding var currentState: appState
    var body: some View {
        ProgressView(currentState.rawValue, value: downloadTask.downloadProgress, total: downloadTask.downloadTotal)
            .padding()
            .onAppear {
                downloadTask.startDownload()
            }
            .onChange(of: downloadTask.downloadComplete) {complete in
                if complete {
                    currentState = .SavingToDatabase
                }
            }
    }
}

struct DownloadProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadProgressView(downloadTask: DownloadTask(), currentState: .constant(.Downloading))
    }
}
