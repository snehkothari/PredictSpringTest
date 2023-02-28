//
//  DownloadTask.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 22/09/22.
//

import Foundation


class DownloadTask: NSObject, ObservableObject, URLSessionDownloadDelegate {
    
    var urlString: String = "https://drive.google.com/uc?id=11TbQgdejtIGdEeYUcnnkoOru800D44mR&export=download"
    
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    @Published var userTask: URLSessionDownloadTask?
    @Published var downloadTaskSession: URLSessionDownloadTask!
    @Published var downloadProgress: CGFloat = 0
    @Published var downloadTotal: CGFloat = 1
    @Published var csvUrl: URL?
    @Published var downloadComplete: Bool = false
    init(url: String) {
        self.urlString = url
    }
    
    override init() {
        super.init()
    }
    
    func startDownload() {
        guard let validUrl = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        autoreleasepool {
            let fileManager = FileManager.default
            let location = directory.appendingPathComponent(validUrl.lastPathComponent)
            
            if fileManager.fileExists(atPath: location.path) {
                DispatchQueue.main.async {
                    self.downloadComplete = true
                    self.csvUrl = location
                }
            } else {
                let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
                downloadTaskSession = session.downloadTask(with: validUrl)
                downloadTaskSession.resume()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let url = downloadTask.originalRequest?.url else {
            print("error")
            return
        }
        
        
        let destinationURL = directory.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            
            try FileManager.default.copyItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.downloadComplete = true
                self.csvUrl = destinationURL
            }
        } catch {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = CGFloat(totalBytesWritten)
        
        DispatchQueue.main.async {
            self.downloadProgress = progress
            self.downloadTotal = CGFloat(totalBytesExpectedToWrite)
        }
    }
}
