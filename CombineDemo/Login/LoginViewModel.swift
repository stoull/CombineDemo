//
//  LoginViewModel.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import Foundation
import Combine

final class LoginViewModel {
    var currentUser: LoginUser?
    
    @Published var username: String = ""
    @Published var password: String = ""
    
    private(set) lazy var isInputValid = Publishers.CombineLatest($username, $password)
        .map({$0.count > 1 && $1.count > 4})
        .eraseToAnyPublisher()
    
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    
    let loginResultSubject = PassthroughSubject<String, Error>()
    
    func login() {
        isLoading = true
        authorize(username: username, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(_):
                self?.loginResultSubject.send("successful")
            case .failure(let failure):
                self?.loginResultSubject.send(completion: .failure(failure))
            }
        }
    }
}

protocol AuthorizationProtocol {
    func authorize(username: String, password: String, result: @escaping (Result<String, Error>) -> Void )
}

extension LoginViewModel: AuthorizationProtocol {
    func authorize(username: String, password: String, result: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
            result(.success("successful"))
        }
    }
}
