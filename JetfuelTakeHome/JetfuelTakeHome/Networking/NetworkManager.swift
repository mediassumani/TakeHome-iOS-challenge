//
//  CampaignService.swift
//  JetfuelTakeHome
//
//  Created by Medi Assumani on 7/2/19.
//  Copyright © 2019 Medi Assumani. All rights reserved.
//

import Foundation
import UIKit

struct NetworkManager {
    
    static let shared = NetworkManager()
    
    /// Fetche all the campaigns from the API
    func fetchCampaigns(completion: @escaping(Result<[Campaign], NetworkError>) -> ()){
        
        let url = URL(string: "https://www.plugco.in/public/take_home_sample_feed")
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if(error == nil && data != nil) {
                
                guard let unwrappedResponse = response as? HTTPURLResponse, let unwrappedData = data else { return }
                
                if (unwrappedResponse.statusCode == 200){
                    
                    if let results = try? JSONDecoder().decode(Campaigns.self, from: unwrappedData) {
                        
                        let campaigns = results.campaigns
                        completion(.success(campaigns))
                    } else {
                        completion(.failure(.decodingFailed))
                    }
                } else {
                    completion(.failure(.unsuccessfulResponse))
                }
            } else {
                completion(.failure(.badRequest))
            }
        }.resume()
    }
    
    
    /// Download video from a remote data storage
    func downloadMedia(urlString: String) {
        
        DispatchQueue.main.async {
            ViewController.downloadingIndicator.startAnimating()
        }
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                guard let url = URL(string: urlString) else { return }
                let _ = try Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    
                    ViewController.downloadingIndicator.stopAnimating()
                    let alert = Helper.createAlert(title: "Downloaded", message: "The Media has been successfully downloaded", mainActionMessage: "Ok", mainActionStyle: .default)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    
                    ViewController.downloadingIndicator.stopAnimating()
                    let alert = Helper.createAlert(title: "Download Failed", message: "The Media has been not downloaded", mainActionMessage: "Ok", mainActionStyle: .default)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
