//
//  SessionDelegate.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import Foundation

final class SessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, nil)
    }
}
