//
//  ImageAPI.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-11-05.
//

import Foundation

class PexelsAPI {
    
    static func fetchRandomProfileImage(completion: @escaping (String?) -> Void) {
        let query = "abstract"  //Specify the category or keyword
        let pexelsAPIURL = "https://api.pexels.com/v1/search?query=\(query)&per_page=20"
            
        guard let url = URL(string: pexelsAPIURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("myapikey", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching Pexels API data: \(error)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let pexelsResponse = try JSONDecoder().decode(PexelsResponse.self, from: data)
                    if !pexelsResponse.photos.isEmpty {
                        let randomIndex = Int.random(in: 0..<pexelsResponse.photos.count)
                        let photo = pexelsResponse.photos[randomIndex]
                        if let imageURL = photo.src.medium {
                            completion(imageURL)
                        }
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("Error decoding Pexels API response: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
        }.resume()
    }
}

struct PexelsResponse: Codable {
    struct Photo: Codable {
        struct PhotoSource: Codable {
            let medium: String?
        }
        
        let src: PhotoSource
    }
    
    let photos: [Photo]
}


import SwiftUI
import Combine



class ImageLoader: ObservableObject {
    @Published var image: Image?
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }
}
