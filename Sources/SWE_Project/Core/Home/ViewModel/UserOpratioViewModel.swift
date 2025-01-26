//
//  UserOpratioViewModel.swift
//  SWE_Project
//
//  Created by Khalid R on 30/03/1446 AH.
//

import Foundation
import FirebaseAnalytics
class UserOprtionViewModel: ObservableObject {
    
    @Published  var user = UserService.shared.user
    @Published var savedPlaces: [PlaceModel] = []
    @Published var resrvations: [PlaceModel] = []
    init() {
        fetchBookmarks()
        fetchResrvations()
    }
    
    private func addToWatchList(place: PlaceModel) {
        guard let userID = UserService.shared.auth.currentUser?.uid else {
            ReliabilityService.shared.recordRequest(success: false)
            return
        }

        do {
            // Add the place as a new document in the bookmarks collection
            let bookmarkRef = UserService.shared.firestore
                .collection("Users")
                .document(userID)
                .collection("bookmarks")
                .document(place.id.uuidString) // Use the place's ID as the document ID

            try bookmarkRef.setData(from: place) // Save the place model as a document
            ReliabilityService.shared.recordRequest(success: true)

            // Log Analytics Event
              Analytics.logEvent("bookmark_place", parameters: [
                  "place_name": place.name ?? "Unknown",
                  "place_id": place.id.uuidString,
                  "city": place.city?.title ?? "Unknown"
              ])
        } catch {
            ReliabilityService.shared.recordRequest(success: false)

            print("DEBUG: error while adding to watch list \(error.localizedDescription)")
        }
    }


    private func removeFromWatchList(place: PlaceModel) {
        guard let userID = UserService.shared.auth.currentUser?.uid else {
            ReliabilityService.shared.recordRequest(success: false)
            return
        }

        // Remove the place from the bookmarks collection
        let bookmarkRef = UserService.shared.firestore
            .collection("Users")
            .document(userID)
            .collection("bookmarks")
            .document(place.id.uuidString) // Use the place's ID as the document ID

        bookmarkRef.delete { error in
            ReliabilityService.shared.recordRequest(success: true)

            if let error = error {
                print("DEBUG: error while removing from watch list \(error.localizedDescription)")
            } else {
                
                // Log Analytics Event
                  Analytics.logEvent("delete_bookmark_place", parameters: [
                      "place_name": place.name ?? "Unknown",
                      "place_id": place.id.uuidString,
                      "city": place.city?.title ?? "Unknown"
                  ])
                print("DEBUG: Successfully removed place from watch list")
            }
        }
    }


    
    func updateWatchListState(place: PlaceModel, existed: Bool){
        
        if existed {
            removeFromWatchList(place: place)
            
        } else {
            addToWatchList(place: place)
            
        }
        
    }
    
    func fetchBookmarks() {

        guard let userID = UserService.shared.auth.currentUser?.uid else {
            ReliabilityService.shared.recordRequest(success: false)
            return
        }
            
            let bookmarkCollection = UserService.shared.firestore
                .collection("Users")
                .document(userID)
                .collection("bookmarks")
            
            bookmarkCollection.getDocuments { [weak self] snapshot, error in
                // Record the request result
                ReliabilityService.shared.recordRequest(success: error == nil)
                
                if let error = error {
                    print("DEBUG: error while fetching reservations \(error.localizedDescription)")
                    return
                }
            
            if let snapshot = snapshot {
                let places = snapshot.documents.compactMap { doc -> PlaceModel? in
                    return try? doc.data(as: PlaceModel.self)
                }
                DispatchQueue.main.async {
                    self?.user.bookmarks = places
                    self?.savedPlaces =  places
                }
                
                
                // Log Analytics Events for each reservation
                for place in places {
                    Analytics.logEvent("fetch_bookmark", parameters: [
                        "place_name": place.name ?? "Unknown",
                        "place_id": place.id.uuidString,
                        "city": place.city?.title ?? "Unknown"
                    ])
                }
            }
        }
    }

    
    // Resrvation Section

     func bookPlace(place: PlaceModel) {
        guard let userID = UserService.shared.auth.currentUser?.uid else {
            ReliabilityService.shared.recordRequest(success: false)
            return
        }
         
         if checkAvalibliaty() == false {
             ReliabilityService.shared.recordRequest(success: false)
             print("Sorry Place is full you can reach them by: \(String(describing: place.number))")
             return
         }

        do {
            // Add the place as a new document in the bookmarks collection
            let bookmarkRef = UserService.shared.firestore
                .collection("Users")
                .document(userID)
                .collection("reservations")
                .document(place.id.uuidString) // Use the place's ID as the document ID

            try bookmarkRef.setData(from: place) // Save the place model as a document
            ReliabilityService.shared.recordRequest(success: true)

            Analytics.logEvent("reserve_place", parameters: [
                  "place_name": place.name ?? "Unknown",
                  "place_id": place.id.uuidString,
                  "city": place.city?.title ?? "Unknown",
                  "price": place.price ?? 0.0
              ])
            
        } catch {
            print("DEBUG: error while adding to resrvations list \(error.localizedDescription)")
        }
    }
    
    func checkAvalibliaty() -> Bool {
        return true
    }
    func fetchResrvations() {
        guard let userID = UserService.shared.auth.currentUser?.uid else { 
            ReliabilityService.shared.recordRequest(success: false)
            return
        }

        let bookmarkCollection = UserService.shared.firestore
            .collection("Users")
            .document(userID)
            .collection("reservations")

        bookmarkCollection.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: error while fetching reservations \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                ReliabilityService.shared.recordRequest(success: error == nil)
                let places = snapshot.documents.compactMap { doc -> PlaceModel? in
                    return try? doc.data(as: PlaceModel.self)
                }
                DispatchQueue.main.async {
                    self.user.reservations = places
                    self.resrvations =  places
                }
                
                
                // Log Analytics Events for each reservation
                for place in places {
                    Analytics.logEvent("fetch_reservation", parameters: [
                        "place_name": place.name ?? "Unknown",
                        "place_id": place.id.uuidString,
                        "city": place.city?.title ?? "Unknown"
                    ])
                }
            }
        }
    }

    
    
}
