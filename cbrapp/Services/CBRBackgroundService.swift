//
//  CBRBackgroundService.swift
//  cbrapp
//
//  Created by Nikita Fedorenko on 06.08.2021.
//

import Foundation

class CBRBackgroundService: NSObject {
    
    var elementName = ""
    var idString = ""
    var valueString = ""
    var currentRate: Double = 0
    
    var backgroundCompletionHandler: (() -> Void)?
    var notificationService: NotificationService?
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "cbr_session")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func start() {
        let url = URL(string: "http://www.cbr.ru/scripts/XML_daily.asp")!
        let backgroundTask = urlSession.downloadTask(with: url)
        backgroundTask.earliestBeginDate = Date().addingTimeInterval(3600 * 24)
        backgroundTask.resume()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let backgroundCompletionHandler = self.backgroundCompletionHandler else { return }
            backgroundCompletionHandler()
        }
    }
    
    func checkCourse(currentRate: Double) {
        if currentRate > GlobalSettings.currentRate,
           let service = notificationService{
            service.sendNotification(title: "Currency rate changed", body: "Current rate is: \(currentRate)")
        }
    }
    
    func parseData(data: Data){
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse(){
            checkCourse(currentRate: currentRate)
        }
    }
}

extension CBRBackgroundService: URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog(#function)
        
        do{
            let data = try Data(contentsOf: location)
            NSLog(String(data.count))
            parseData(data: data)
            start()
        }catch{
            NSLog(error.localizedDescription)
        }
    }
}

extension CBRBackgroundService: XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "Valute"{
            if let id = attributeDict["ID"], id == "R01235"{
                idString = id
            }else{
                idString = ""
            }
            valueString = ""
        }
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Valute", !idString.isEmpty {
            print(valueString)
            if let value = Double(valueString.replacingOccurrences(of: ",", with: ".")){
                currentRate = value
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty{
            if self.elementName == "Value", !idString.isEmpty{
                valueString += data
            }
        }
    }
    
}
