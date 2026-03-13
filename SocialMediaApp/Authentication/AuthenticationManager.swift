import Foundation
import SwiftUI

// Scaleify Authentication Manager
// Connects to Scaleify's secure authentication backend
// No Firebase setup required!

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://scaleify-46vjft6nr-scaleify-570fb2c5.vercel.app/api/auth"
    private let appId = "SocialMediaApp"
    
    init() {
        checkAuthenticationState()
    }
    
    func checkAuthenticationState() {
        // Check for stored token
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            Task {
                await verifyToken(token)
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(baseURL)/signup")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": email,
                "password": password,
                "displayName": name,
                "appId": appId
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                if result.success {
                    self.user = result.user
                    self.isAuthenticated = true
                    // Store ID token for session verification
                    if let token = result.idToken {
                        UserDefaults.standard.set(token, forKey: "authToken")
                    }
                } else {
                    self.errorMessage = result.error ?? "Signup failed"
                }
            } else {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.errorMessage = result.error ?? "Signup failed"
            }
        } catch {
            self.errorMessage = "Network error. Please check your connection."
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(baseURL)/login")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": email,
                "password": password,
                "appId": appId
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                if result.success {
                    self.user = result.user
                    self.isAuthenticated = true
                    // Store token
                    if let token = result.idToken {
                        UserDefaults.standard.set(token, forKey: "authToken")
                    }
                } else {
                    self.errorMessage = result.error ?? "Login failed"
                }
            } else {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.errorMessage = result.error ?? "Invalid email or password"
            }
        } catch {
            self.errorMessage = "Network error. Please check your connection."
        }
        
        isLoading = false
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        self.user = nil
        self.isAuthenticated = false
        self.errorMessage = nil
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(baseURL)/reset-password")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["email": email]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            let result = try JSONDecoder().decode(AuthResponse.self, from: data)
            if httpResponse.statusCode != 200 || !result.success {
                self.errorMessage = result.error ?? "Unable to send reset email"
            }
        } catch {
            self.errorMessage = "Network error. Please check your connection."
        }
        
        isLoading = false
    }
    
    private func verifyToken(_ token: String) async {
        do {
            let url = URL(string: "\(baseURL)/verify-token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["idToken": token]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                // Token invalid, sign out
                signOut()
                return
            }
            
            let result = try JSONDecoder().decode(AuthResponse.self, from: data)
            if result.success {
                self.user = result.user
                self.isAuthenticated = true
            } else {
                signOut()
            }
        } catch {
            signOut()
        }
    }
}

// MARK: - Models

struct AppUser: Codable {
    let uid: String
    let email: String
    let displayName: String?
}

struct AuthResponse: Codable {
    let success: Bool
    let user: AppUser?
    let customToken: String?
    let idToken: String?
    let refreshToken: String?
    let error: String?
    let message: String?
}

enum AuthError: Error {
    case invalidResponse
    case networkError
}
