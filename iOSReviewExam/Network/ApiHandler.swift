//
//  ApiHandler.swift
//  iOSReviewExam
//
//  Created by Adi Mizrahi on 03/06/2020.
//  Copyright © 2020 Tap.pm. All rights reserved.
//

import Foundation
import SwiftyJSON
class ApiHandler {
    static let sharedInstance = ApiHandler()
    
    
    func pullAssetsFromServer(completionHandler: @escaping (_ succes: Bool) -> Void) {
        let url = URL(string: "https://y0.com/cdn2/test/images.json?f")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSON(data: data)
                if let firstImage = json["NewsPaper"]["image"].string {
                    ImagesHolder.sharedInstance.images.append(firstImage)
                }
                if let secondImage = json["StayHome"]["image"].string {
                    ImagesHolder.sharedInstance.images.append(secondImage)
                }
                completionHandler(true)
            } catch {
                completionHandler(false)
                print("error")
            }
            
        }

        task.resume()
    }
}
