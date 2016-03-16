//
//  DRCleverBot.swift
//  Pods
//
//  Created by Sergei Klimov on 3/15/16.
//
//

// thanks to https://github.com/folz/cleverbot.py
import NSURL_QueryDictionary
import CryptoSwift
import AGQueryString


extension Dictionary {
    func queryString() -> String {
        var comps = [NSURLQueryItem]()
        for (key, val) in self {
            comps.append(NSURLQueryItem(name: key as! String, value: val as! String))
        }
        let components = NSURLComponents()
        components.queryItems = comps
        return components.query!
    }
}

let HOST = "www.cleverbot.com"
let PROTOCOL = "http://"
let RESOURCE = "/webservicemin"
let API_URL = PROTOCOL + HOST + RESOURCE


public class DRCleverBot {
    var data:[String:String] = [
        "stimulus": "",
        "start": "y",  // Never modified
        "sessionid": "",
        "vText8": "",
        "vText7": "",
        "vText6": "",
        "vText5": "",
        "vText4": "",
        "vText3": "",
        "vText2": "",
        "icognoid": "wsf",  // Never modified
        "icognocheck": "",
        "fno": "0",  // Never modified
        "prevref": "",
        "emotionaloutput": "",  // Never modified
        "emotionalhistory": "",  // Never modified
        "asbotname": "",  // Never modified
        "ttsvoice": "",  // Never modified
        "typing": "",  // Never modified
        "lineref": "",
        "sub": "Say",  // Never modified
        "islearning": "1",  // Never modified
        "cleanslate": "False",  // Never modified
    ]
    var conversation = [String]()
    var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    public init(){

    }
    
    public func startSession(completion:() -> ()) {
        let request = NSURLRequest(URL: NSURL(string: PROTOCOL+HOST)!);
    
        let task = session.dataTaskWithRequest(request) { (data, resp, err) -> Void in
            if let httpResponse = resp as? NSHTTPURLResponse {
                if let headerFields = httpResponse.allHeaderFields as? [String: String] {
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: resp!.URL!)

                }
            }

            
            completion()
        }
        task.resume()
    }
    
    public func ask(question:String, completion:(String?) -> Void) {
        self.data["stimulus"] = question
        
        _send(completion)
        
        self.conversation.append(question)
        

    }
    func makeRequest()->NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: API_URL)!)
        request.setValue("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)", forHTTPHeaderField: "User-Agent")
        request.setValue("ISO-8859-1,utf-8;q=0.7,*;q=0.7", forHTTPHeaderField: "Accept-Charset")
        request.setValue( "en-us,en;q=0.8,en-us;q=0.5,en;q=0.3", forHTTPHeaderField: "Accept-Language")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.setValue(HOST, forHTTPHeaderField: "Host")
        request.setValue(PROTOCOL + HOST + "/", forHTTPHeaderField: "Referer")
        request.addValue("text/html,application/xhtml+xml,", forHTTPHeaderField: "Accept")
        request.addValue("application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        return request
    }
    
    func _parseResponse(response:String, completion:(String?) -> Void) {
        let parsed = response.componentsSeparatedByString("\r\r\r\r\r\r").map() { $0.componentsSeparatedByString("\r") }
        
        if parsed[0][1] == "DENIED" {
            completion(nil)
            return
        }
        
        completion(parsed[0][0])
    }
    
    func _send(completion:(String?) -> Void) {
        if (self.conversation != []) {
            var linecount = 1
            for line in self.conversation.reverse() {
                linecount += 1
                self.data["vText"+String(linecount)] = line
                if (linecount == 8) {
                    break
                }
            }
        }
        
        
        let encData = self.data.queryString()
        let digestTxt = encData.substringWithRange(Range<String.Index>(start: encData.startIndex.advancedBy(9), end: encData.startIndex.advancedBy(35)))
        let token = digestTxt.md5()
        self.data["icognocheck"] = token
        
        let encDataWithToken = self.data.queryString()


        let request = makeRequest()
        request.HTTPMethod = "POST"
        request.HTTPBody = encDataWithToken.dataUsingEncoding(NSUTF8StringEncoding)


        let task = self.session.dataTaskWithRequest(request) { (data, resp, error) -> Void in
            let responseStr = String(data: data!, encoding: NSUTF8StringEncoding)
            self._parseResponse(responseStr!, completion: completion)
        }
        task.resume()
        
        
    }
}

