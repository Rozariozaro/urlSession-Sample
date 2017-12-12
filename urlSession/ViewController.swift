//
//  ViewController.swift
//  urlSession
//
//  Created by Rozario on 12/6/17.
//  Copyright © 2017 VisionReached. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        callGetMethod()
//        callPostMethod()
        callMultipartPOSTMethod()
    }
    
    func callGetMethod() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {return}
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let dataDict = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
                    print(dataDict)
                } catch {
                    print(error.localizedDescription)
                }
            }
            }.resume()
    }
    
    func callPostMethod() {
        let parameters = ["username": "@kilo_loco", "tweet": "HelloWorld"]

        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {return}
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted]) else {return}
        request.httpBody = httpBody
        
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let dataDict = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
                    print(dataDict)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func callHubPost() {
//        guard let url = URL(string: "http://184.175.94.146/HubSystem-Internal/api/") else {return}
        
    }
    
    func callMultipartPOSTMethod() {
        let parameters = ["name": "MyTestFile123321",
                          "description": "My tutorial test file for MPFD uploads"]
        
        let mediaImage = Media(withData: UIImageJPEGRepresentation(#imageLiteral(resourceName: "image"), 0.7)!, forKey: "image", mimeType: "image/jpeg", filename: NSUUID().uuidString + ".jpeg")
        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID 24ab4e4b138a29a", forHTTPHeaderField: "Authorization")

        let dataBody = createBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBody(withParameters parameters: [String: String]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init(withData data: Data, forKey key:String, mimeType mime: String, filename name:String) {
        self.key = key
        self.data = data
        self.mimeType = mime
        self.filename = name
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
