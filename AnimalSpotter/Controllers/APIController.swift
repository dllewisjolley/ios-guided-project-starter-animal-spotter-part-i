//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 BloomTech. All rights reserved.
//

import Foundation
import UIKit

final class APIController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case noData
        case failedSignUp
        case failedSignIn
        case noToken
    }
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.herokuapp.com/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    var bearer: Bearer?
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping(Result<Bool, NetworkError>) -> Void) {
        
        print("signUpURL = \(signUpURL.absoluteString)")
        
        var request = postRequest(for: signUpURL)
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                //ALWAYS HANDLE YOUR ERROR FIRST
                if let error = error {
                    print("Sign up fail with error: \(error)")
                    completion(.failure(.failedSignUp))
                    return
                }
                
                //HANDLE RESPONSE
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("Sign up was unsuccessful")
                    completion(.failure(.failedSignUp))
                    return
                }
                
                completion(.success(true))
            }
            
            task.resume()
            
        } catch {
            completion(.failure(.failedSignUp))
            
            
        }
    }
    
    //helper method for post method
    private func postRequest(for url: URL) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    // create function for sign in
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var request = URLRequest(url: signInURL)
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Sign in failed with error: \(error)")
                    completion(.failure(.failedSignIn))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("sign in was unsuccessful")
                    completion(.failure(.failedSignIn))
                    return
                }
                
                guard let data = data else {
                    print("Data was not recieved")
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    self.bearer = try JSONDecoder().decode(Bearer.self, from: data)
                    completion(.success(true))
                }   catch {
                    completion(.failure(.noToken))
                }
            }
            task.resume()
                
            
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignIn))
        }
        
    }
    
    // create function for fetching all animal names
    
    // create function for fetching animal details
    
    // create function to fetch image
}
