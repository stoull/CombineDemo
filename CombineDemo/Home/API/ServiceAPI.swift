//
//  ServiceAPI.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import Foundation
import Combine

enum ServiceAPIError: Error {
    case url(URLError)
    case urlRequest
    case network
    case decode
}

protocol ServiceAPIProtocol {
    func getFlower(keywords: String?) -> AnyPublisher<[Flower], Error>
}

final class ServiceAPI: ServiceAPIProtocol {
    func getFlower(keywords: String?) -> AnyPublisher<[Flower], Error> {
        var dataTask: URLSessionDataTask?
        
        let onSubscription: (Subscription) -> Void = {_ in dataTask?.resume()}
        let onCancel: () -> Void = { dataTask?.cancel() }
        
        return Future<[Flower], Error> { [weak self] promise in
            
            // for local test
            if let json_path = Bundle.main.path(forResource: "flowers", ofType: "json"),
               let jsonData = FileManager.default.contents(atPath: json_path),
               let flowers = try? JSONDecoder().decode([Flower].self, from: jsonData) {
                promise(.success(flowers))
            } else {
                promise(.failure(ServiceAPIError.decode))
            }
            
            guard let request = self?.getUrlRequest(keywords: keywords) else {
                promise(.failure(ServiceAPIError.urlRequest))
                return
            }
            return
            
            // for network api
            dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, res, error in
                guard let data = data else {
                    promise(.failure(ServiceAPIError.network))
                    return
                }
                
                do {
                    let flowers = try JSONDecoder().decode([Flower].self, from: data)
                    promise(.success(flowers))
                } catch {
                    promise(.failure(ServiceAPIError.decode))
                }
            })
        }
        .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
        .eraseToAnyPublisher()
    }
    
    private func getUrlRequest(keywords: String?) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 5001
        components.path = "/api/v1/flowers"
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20.0
        
        return request
    }
    
    
}
