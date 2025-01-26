//
//  AuthViewModel.swift
//  Virtual Investing Project
//
//  Created by Khalid R on 06/03/1446 AH.
//
import Foundation
import FirebaseAnalytics


class AuthViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    // In AuthViewModel.swift

    @MainActor
    func createUser() async throws {
        if email.isEmpty || password.isEmpty  {
            ReliabilityService.shared.recordRequest(success: false)  // Record invalid input as failure
            throw AuthError.invalidInput
        }
        do {
            let authResult = try await UserService.shared.auth.createUser(withEmail: email, password: password)
            let user = authResult.user
            do {
                try await user.sendEmailVerification()
                
            } catch  {
                ReliabilityService.shared.recordRequest(success: false)  // Record email verification failure
                throw AuthError.customError(message: "Failed to send verification email.")
            }
            
            let newUser = UserModel(username: userName, email: email, password: password)
            try UserService.shared.firestore.collection("Users").document(user.uid).setData(from: newUser)
            
            // Record successful user creation
            ReliabilityService.shared.recordRequest(success: true)
            
            Analytics.logEvent("sign_up", parameters: [
                "email": email,
                "username": userName
            ])
        } catch  {
            ReliabilityService.shared.recordRequest(success: false)  // Record failure
            throw AuthError.customError(message: "Failed to create user account. \(error.localizedDescription)")
        }
    }

    @MainActor
    func logIn() async throws {
        if email.isEmpty || password.isEmpty {
            ReliabilityService.shared.recordRequest(success: false)  // Record invalid input as failure
            throw AuthError.invalidInput
        }
        do {
            let authResult = try await UserService.shared.auth.signIn(withEmail: email, password: password)
            let user = authResult.user

//            // Check if the user's email is verified
//            guard user.isEmailVerified else {
//                ReliabilityService.shared.recordRequest(success: false)  // Record unverified email as failure
//                Analytics.logEvent("sign_in_failure", parameters: [
//                    "reason": "email_not_verified",
//                    "user_id": user.uid
//                ])
//                throw AuthError.customError(message: "Email Not Verified")
//            }

            // Record successful login
            ReliabilityService.shared.recordRequest(success: true)
            
            Analytics.logEvent("user_sign_in", parameters: [
                "user_id": user.uid,
                "email": email
            ])
        } catch {
            ReliabilityService.shared.recordRequest(success: false)  // Record failure
            Analytics.logEvent("sign_in_failure", parameters: [
                "error_message": error.localizedDescription
            ])
            throw AuthError.customError(message: error.localizedDescription)
        }
    }

    
    @MainActor
    func logOut() async throws {
        do {
            try UserService.shared.auth.signOut()
            ReliabilityService.shared.recordRequest(success: true)
        } catch {
            ReliabilityService.shared.recordRequest(success: false)
            throw AuthError.customError(message: "Failed to log out: \(error.localizedDescription)")
        }
    }

}
