//
//  UnitTestDownloadTask.swift
//  PredictSpring POSTests
//
//  Created by Sneh Kothari on 29/09/22.
//

import XCTest
@testable import PredictSpring_POS

final class UnitTestDownloadTask: XCTestCase {
    
    func test_UnitTestDownloadTask_invalid_URL() {
        let urlsToTest = ["", " ", "www.google", "google", "snehkothari1@gmail.com"]
        
        for url in urlsToTest {
            let downloadManager = DownloadTask(url: url)
            XCTAssertNil(downloadManager.csvUrl)
        }
    }
    
    //10 seconds delay added to check if download is complete by then
    func test_UnitTestDownloadTask_No_URL() {
        let downloadManager = DownloadTask()
        let timeToWaitForDownload = 10.0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWaitForDownload) {
            XCTAssertNotNil(downloadManager.csvUrl)
        }
    }

    func test_UnitTestDownloadTask_downloadProgressUpdatedToOne() {
        let downloadManager = DownloadTask()
        downloadManager.startDownload()
        let timeToWaitForDownload = 10.0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWaitForDownload) {
            XCTAssertEqual(downloadManager.downloadProgress, 1)
            XCTAssertTrue(downloadManager.downloadComplete)
        }
    }

    func test_UnitTestDownloadTask_checkFileNotNone() {
        let downloadManager = DownloadTask()
        downloadManager.startDownload()
        let timeToWaitForDownload = 10.0
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWaitForDownload) {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let location = directory.appendingPathComponent(downloadManager.csvUrl!.path)
            XCTAssertFalse(FileManager.default.fileExists(atPath: location.path))
        }
    }
}
