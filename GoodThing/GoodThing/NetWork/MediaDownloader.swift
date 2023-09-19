//
//  MediaDownloader.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/19.
//

import UIKit
import AVFoundation

class MediaDownloader {
    
    static let shared = MediaDownloader() // Singleton
    
    private init() {}
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("Download Image Task Fail: \(error!.localizedDescription)")
                    completion(nil)
                } else if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }.resume()
        }
    }
    
}

extension MediaDownloader {
    func downloadAudio(from urlString: String, completion: @escaping (URL?) -> Void) {
        if let url = URL(string: urlString) {
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url.lastPathComponent)
            
            URLSession.shared.downloadTask(with: url) { (location, response, error) in
                if error != nil {
                    print("Download Audio Task Fail: \(error!.localizedDescription)")
                    completion(nil)
                } else if let location = location {
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        DispatchQueue.main.async {
                            completion(destinationURL)
                        }
                    } catch {
                        print("File Error: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }.resume()
        }
    }
}
