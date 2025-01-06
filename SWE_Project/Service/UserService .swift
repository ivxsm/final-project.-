//
//  UserService .swift
//  Virtual Investing Project
//
//  Created by khalid doncic on 06/03/1446 AH.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class UserService: ObservableObject  {
  
    static let shared = UserService()
    @Published var user: UserModel = .init()

    
    let auth: Auth
    let firestore: Firestore
    let reliabilityDB: CollectionReference // Add this
    

    init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.reliabilityDB = firestore.collection("reliability_metrics")

    }


    
    func fetchUser() async throws {
        guard let userID = auth.currentUser?.uid else {
            ReliabilityService.shared.recordRequest(success: false)
            throw URLError(.badURL)
        }
        
        let docRef = firestore.collection("Users").document(userID)
        
        do {
            let docSnap = try await docRef.getDocument()
            guard let user = try? docSnap.data(as: UserModel.self) else {
                ReliabilityService.shared.recordRequest(success: false)
                throw URLError(.badURL)
            }
            DispatchQueue.main.async {
                self.user = user
            }
            ReliabilityService.shared.recordRequest(success: true)
        } catch {
            ReliabilityService.shared.recordRequest(success: false)
            throw error
        }
    }
    

    

   
}

