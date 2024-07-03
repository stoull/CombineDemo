//
//  LoginViewController.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var bindings = Set<AnyCancellable>()
    
    private let viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LoginViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        setupBindings()
    }

    @IBAction func loginAction(_ sender: Any) {
        if let uName = usernameTextField.text, !uName.isEmpty {
            viewModel.login()
        } else {
            // set up a default user for testing
            viewModel.username = "Leo"
            viewModel.password = "299792458"
        }
    }
    
    @IBAction func bgTapAction(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    
    private func setupBindings() {
        func bindViewToViewModel() {
            
            usernameTextField.publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.username, on: viewModel)
                .store(in: &bindings)
            
            passwordTextField.publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.password, on: viewModel)
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            
            viewModel.$username
                .receive(on: DispatchQueue.main)
                .map({ $0 as? String})
                .assign(to: \.text, on: usernameTextField)
                .store(in: &bindings)
            
            viewModel.$password
                .receive(on: DispatchQueue.main)
                .map({ $0 as? String})
                .assign(to: \.text, on: passwordTextField)
                .store(in: &bindings)
            
            viewModel.$isLoading
                .receive(on: RunLoop.main)
                .sink { [weak self] isLoading in
                    if isLoading {
                        self?.activeIndicator.startAnimating()
                        self?.activeIndicator.isHidden = false
                    } else {
                        self?.activeIndicator.stopAnimating()
                        self?.activeIndicator.isHidden = true
                    }
                }
                .store(in: &bindings)
            
            viewModel.isInputValid
                .receive(on: DispatchQueue.main)
                .assign(to: \.isValid, on: loginButton)
                .store(in: &bindings)
            
            viewModel.loginResultSubject
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure:
                        return
                    }
                } receiveValue: {[weak self] msg in
                    self?.navigateToHomeVC()
                }
                .store(in: &bindings)

        }
        
        bindViewModelToView()
        bindViewToViewModel()
    }
    
    private func navigateToHomeVC() {
        self.performSegue(withIdentifier: "showHomeVC", sender: self)
    }
}

