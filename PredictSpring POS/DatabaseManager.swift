//
//  DatabaseManager.swift
//  PredictSpring POS
//
//  Created by Sneh Kothari on 23/09/22.
//

import Foundation
import SQLite3
class DatabaseManager:ObservableObject {
    
    let dbName = "myDB.sqlite"
    let chunkSize = 20
    let filePath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    var db: OpaquePointer?
    @Published var result: [Product] = []
    @Published var progress: CGFloat = 0
    @Published var total: CGFloat = 1
    @Published var databaseSaveComplete = false
    @Published var noMoreDataInDB = false
    var dataFetched = true
    typealias FinishedSaving = () -> ()
    
    func checkDBExists() -> Bool {
        guard (filePath?.appendingPathComponent(dbName)) != nil else {
            print("DB path not available")
            return false
        }
        return true
    }
    
    func saveToDatabaseBatchProcessing(data: [String]) {
        let rowInsertString = "INSERT INTO PRODUCTS VALUES(?,?,?,?,?,?);"
        var insertPointer: OpaquePointer?
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil);
        if sqlite3_prepare_v2(db, rowInsertString, -1, &insertPointer, nil) ==
            SQLITE_OK {
            for content in data {
                let columns = content.split(separator: ",")
                let id = columns[0] as NSString
                let title = columns[1] as NSString
                let color = columns[4] as NSString
                let size = columns[5] as NSString
                if let listPrice = Double(columns[2]), let salesPrice = Double(columns[3]) {
                    sqlite3_bind_text(insertPointer, 1, id.utf8String, -1, nil)
                    sqlite3_bind_text(insertPointer, 2, title.utf8String, -1, nil)
                    sqlite3_bind_double(insertPointer, 3, listPrice)
                    sqlite3_bind_double(insertPointer, 4, salesPrice)
                    sqlite3_bind_text(insertPointer, 5, color.utf8String, -1, nil)
                    sqlite3_bind_text(insertPointer, 6, size.utf8String,-1, nil)
                    if !(sqlite3_step(insertPointer) == SQLITE_DONE) {
                        print("Could not insert row")
                    }
                }
                sqlite3_reset(insertPointer)
            }
        } else {
            print(sqlite3_prepare_v2(db, rowInsertString, -1, &insertPointer, nil))
        }
        sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil);
        sqlite3_finalize(insertPointer)
    }
    
    func getRowCount() -> Int {
        let getCountString = "SELECT count(*) from PRODUCTS;"
        var getCountPointer: OpaquePointer?
        var count = 0
        if sqlite3_prepare(db, getCountString, -1, &getCountPointer, nil) == SQLITE_OK{
              while(sqlite3_step(getCountPointer) == SQLITE_ROW){
                   count = Int(sqlite3_column_int(getCountPointer, 0))
              }
        }
        return count
    }
    
    func checkTableExists() -> Bool {
        let tableExistString = "SELECT name FROM sqlite_master WHERE type='table' AND name='PRODUCTS';"
        var tablePointer: OpaquePointer?
        if sqlite3_prepare_v2(db, tableExistString, -1, &tablePointer, nil) == SQLITE_OK {
            if sqlite3_step(tablePointer) == SQLITE_ROW {
                sqlite3_finalize(tablePointer)
                return true
            }
        }
        sqlite3_finalize(tablePointer)
        return false
    }
    
    func createTable() {
        var tablePointer: OpaquePointer?
        
        let createTableString: String = """
        CREATE TABLE PRODUCTS(productId VARCHAR(255) PRIMARY KEY NOT NULL,
        title VARCHAR(255),
        listPrice,
        salesPrice SNEH,
        color VARCHAR(255),
        size VARCHAR(255));
        """
        if sqlite3_prepare_v2(db, createTableString, -1, &tablePointer, nil) == SQLITE_OK {
            if sqlite3_step(tablePointer) == SQLITE_DONE {
                print("\n PRODUCTS table created")
            } else {
                print("Table cannot be created")
            }
        } else {
            print("Create Table cannot be prepared")
        }
        sqlite3_finalize(tablePointer)
    }

    func openDatabase() {
        guard let dBPath = filePath?.appendingPathComponent(dbName) else {
            print("DB path not available")
            return
        }
        if sqlite3_open(dBPath.path, &db) == SQLITE_OK {
            print("Successfully connected to the DB")
        } else {
            print("Unable to open database")
            return
        }
    }
    
    func getData(productId: String) {
        if db == nil {
            openDatabase()
        }
        let getDataString = """
        SELECT *
        FROM PRODUCTS
        WHERE
        productId LIKE ?
        LIMIT ?
        OFFSET ?;
        """
        if noMoreDataInDB {
            return
        }

        let id = "%\(productId)%" as NSString
        var getPointer: OpaquePointer?
        var tempResult: [Product] = []
        if sqlite3_prepare_v2(db, getDataString, -1, &getPointer, nil) ==
            SQLITE_OK {
            sqlite3_bind_text(getPointer, 1, id.utf8String, -1, nil)
            sqlite3_bind_int(getPointer, 2, Int32(chunkSize))
            sqlite3_bind_int(getPointer, 3, Int32(result.count))
            while(sqlite3_step(getPointer) == SQLITE_ROW) {
                let id = String(describing: String(cString: sqlite3_column_text(getPointer, 0)))
                let title = String(describing: String(cString: sqlite3_column_text(getPointer, 1)))
                let listPrice = sqlite3_column_double(getPointer, 2)
                let salesPrice = sqlite3_column_double(getPointer, 3)
                let color = String(describing: String(cString: sqlite3_column_text(getPointer, 4)))
                let size = String(describing: String(cString: sqlite3_column_text(getPointer, 5)))
                
                tempResult.append(Product(productId: id, title: title, listPrice: listPrice, salesPrice: salesPrice, color: color, size: size))

            }
            if tempResult.count != chunkSize {
                DispatchQueue.main.async {
                    self.noMoreDataInDB = true
                }
            }
            DispatchQueue.main.async {
                self.result += tempResult
                self.dataFetched = true
            }
            print(result.count)
        } else {
            print(sqlite3_prepare_v2(db, getDataString, -1, &getPointer, nil))
        }
        sqlite3_finalize(getPointer)
    }
    
    func getSizeOfFile(path: String) -> Int {
        let key = "FileSize"
        let size = UserDefaults.standard.integer(forKey: key)
        if size != 0 {
            return size
        }
        guard let file = freopen(path, "r", stdin) else {
            print("Cannot read file")
            exit(0)
        }
        defer {
            fclose(file)
        }
        var lines = 0
        _ = readLine()
        while readLine() != nil {
            lines += 1
        }
        if lines == 0 {
            print("No items in file")
            exit(0)
        }
        UserDefaults.standard.set(lines, forKey: key)
        return lines
    }
    
    func performDBSetupChecks() {
        if db == nil {
            openDatabase()
        }
        
        if !checkTableExists() {
            createTable()
        }
    }
    
    func saveDataFromCSV(url: URL?) {
        performDBSetupChecks()
        guard let url = url else {
            print("File not found at location")
            return 
        }

        let path = url.path
        let fileSize = getSizeOfFile(path: path)
        if  fileSize == getRowCount() {
            DispatchQueue.main.async {
                self.databaseSaveComplete = true
            }
            return
        }
        DispatchQueue.main.async {
            self.total = CGFloat(fileSize)
            self.progress = CGFloat(0)
        }
        
        
        guard let file = freopen(path, "r", stdin) else {
            print("Cannot read file")
            return
        }
        defer {
            fclose(file)
        }
        
        // Skip first line
        _ = readLine()
        
        var lines: [String] = []
        var lineCounter = 0
        let chunkSize = 5000
        while let line = readLine() {
            lines.append(line)
            lineCounter += 1
            if ((lineCounter % chunkSize) == 0) {
                DispatchQueue.main.async {
                    self.progress += CGFloat(chunkSize)
                }
                autoreleasepool{
                    saveToDatabaseBatchProcessing(data: lines)
                    lines = []
                }
            }
        }
        saveToDatabaseBatchProcessing(data: lines)
        DispatchQueue.main.async {
            self.databaseSaveComplete = true
        }
    }
    
    func loadNext(id: String, inputString: String) {
        if dataFetched {
            let loadWhenItemsLeft = 5
            if id == "" || id == result[result.count - loadWhenItemsLeft].id {
                dataFetched = false
                DispatchQueue.global().async {
                    self.getData(productId: inputString)
                }
            }
        }
    }
    
    func newSearch(id: String, inputString: String) {
        result = []
        noMoreDataInDB = false
        dataFetched = true
        loadNext(id: "", inputString: inputString)
    }
    
}
