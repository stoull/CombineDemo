//
//  HomeViewModel.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import Foundation
import Combine

enum HomeViewModelError: Error {
    case cancelled
    var des: String {
        switch self {
        case .cancelled:
            return "Some reason failed"
        }
    }
}

enum HomeViewModelStatus {
    case loading
    case finishedLoading
    case error(HomeViewModelError)
}


final class HomeViewModel {
    
    @Published var status: HomeViewModelStatus = .loading
    @Published var flowers: [Flower] = []
    
    private var currentSearchKeywords: String = ""
    
    let serviceAPI: ServiceAPIProtocol
    
    private var bindings = Set<AnyCancellable>()
    
    init(serviceAPI: ServiceAPI = ServiceAPI()) {
        self.serviceAPI = serviceAPI
    }
    
    func search(keywords: String) {
        currentSearchKeywords = keywords
        getFlower(with: keywords)
    }
    
    func retrySearch() {
        getFlower(with: currentSearchKeywords)
    }
}

extension HomeViewModel {
    private func getFlower(with keywords: String) {
        status = .loading
        
        let completionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
            switch completion {
            case .finished:
                self?.status = .finishedLoading
            case .failure:
                self?.status = .error(.cancelled)
            }
        }
        
        let receivedHandler: ([Flower]) -> Void = { [weak self] newValue in
            self?.flowers = newValue
        }
        
        serviceAPI.getFlower(keywords: keywords)
        // the map below is a fake
            .map({ newValues in
                if keywords.isEmpty {
                    return newValues
                } else {
                    return newValues.filter({ $0.name.lowercased().contains(keywords.lowercased()) })
                }
            })
            .sink(receiveCompletion: completionHandler, receiveValue: receivedHandler)
            .store(in: &bindings)

    }
}
