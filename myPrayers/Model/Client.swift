//
//  Client.swift
//  myPrayers
//
//  Created by Bill Clark on 8/4/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit

let session = URLSession.shared
var returnArray: [String:String] = [:]
var calendarDay: Int = 1

func getVOTD(completion: @escaping (Bool,[String:String])->()){
    
    //get caldenar day to use in URL string
    calendarDay = getCalendarDayForVOTD()
    
    let finalURLString = "\(YouVersionConstants.youVersionBaseAPI)\(calendarDay)\(YouVersionConstants.bibleVersion)"
    //print(finalURLString)
    
    var request = URLRequest(url: URL(string: finalURLString)!)
    request.httpMethod = YouVersionConstants.gMethod
    request.addValue(YouVersionConstants.token, forHTTPHeaderField: "x-youversion-developer-token")
    request.addValue(YouVersionConstants.accept, forHTTPHeaderField: "accept")
    request.addValue("myPrayers", forHTTPHeaderField: "user-agent")
    
    let task = session.dataTask(with: request) { data, response, error in
        if error != nil && response != nil  {
            print(error?.localizedDescription ?? "Error")
            completion(false,[:])
        }
        if data != nil{
            
            let range = (0..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            //print(String(data: newData!, encoding: .utf8)!)

            do{
                if let parsedResult = try JSONSerialization.jsonObject(with: newData!, options: []) as? [String: Any]{
                    for (key, value) in parsedResult{
                        if key == "verse"{
                            if let verseArray:[String: Any] = value as? [String: Any]{
                                //print(verseArray["text"] as! String)
                                returnArray["VerseText"] = verseArray["text"] as? String
                            }
                        }
                        if key == "image"{
                            if let verseImage:[String: Any] = value as? [String: Any]{
                                //print(verseImage["url"] as! String)
                                returnArray["ImgURL"] = verseImage["url"] as? String
                            }
                        }
                    }
                    //save calendar day to array to store later in core data along with image and verse
                    returnArray["day"] = "\(calendarDay)"
                    completion(true, returnArray)
                    return
                }
                
            }catch{
                print("Could not parse JSON data.")
                completion(false,[:])
                return
            }
        }
        completion(false,[:])
        return
    }
    task.resume()
}
