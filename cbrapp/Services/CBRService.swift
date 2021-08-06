//
//  RecordService.swift
//  cbrapp
//
//  Created by Nikita Fedorenko on 04.08.2021.
//

import Foundation

class CBRService: NSObject {
    
    var records: [Record] = []
    var elementName = ""
    var dateString = ""
    var valueString = ""
    
    func fetch(completion: @escaping ([Record]) -> Void) {
        
        if let range = getRange(format: "dd/MM/yyyy"){
            
            let url = URL(string: "http://cbr.ru/scripts/XML_dynamic.asp?date_req1=\(range.from)&date_req2=\(range.to)&VAL_NM_RQ=R01235")!
            
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data{
                    
                    let parser = XMLParser(data: data)
                    parser.delegate = self
                    if parser.parse(){
                        completion(self.records)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func getRange(format: String) -> (from: String, to: String)? {
        let dateTo = Date()
        var components = DateComponents()
        components.month = -1
        if let dateFrom = Calendar.current.date(byAdding: components, to: dateTo){
            return (dateFrom.getFormattedDate(format: format), dateTo.getFormattedDate(format: format))
        }
        return nil
    }
    
    func sortedByDateDesc(records: [Record]) -> [Record] {
        return records.sorted(by: { $0.date > $1.date })
    }
}

extension CBRService: XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "Record"{
            
            if let date = attributeDict["Date"]{
                dateString = date
            }
            valueString = ""
        }
        
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Record"{
            
            if let date = dateString.getFormattedDate(format: "dd.MM.yyyy"),
               let value = Double(valueString.replacingOccurrences(of: ",", with: ".")){
                let record = Record(date: date, value: value)
                records.append(record)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty{
            if self.elementName == "Value"{
                valueString += data
            }
        }
    }
}
