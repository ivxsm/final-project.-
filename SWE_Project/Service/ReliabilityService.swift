//
//  x.swift
//  SWE_Project
//
//  Created by Khalid R on 05/07/1446 AH.
//

// ReliabilityService.swift
// ReliabilityService.swift
import Foundation
import FirebaseFirestore
import FirebaseAnalytics

class ReliabilityService {
    static let shared = ReliabilityService()
    private var requests: [(timestamp: Date, success: Bool)] = []
    private let startTime: Date
    private let db = Firestore.firestore()
    
    private init() {
        self.startTime = Date()
        createCollectionIfNeeded()
    }
    
    private func createCollectionIfNeeded() {
        // Create a test document to ensure collection exists
        db.collection("reliability_metrics").addDocument(data: [
            "test": true,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error creating reliability_metrics collection: \(error)")
            } else {
                print("reliability_metrics collection created/verified")
            }
        }
    }
    
    func recordRequest(success: Bool) {
        requests.append((timestamp: Date(), success: success))
        print("DEBUG: Request recorded - Total: \(requests.count), Success: \(success)")
        
        // Log analytics event for each request
        Analytics.logEvent("api_request", parameters: [
            "success": success,
            "total_requests": requests.count
        ])
        
        if requests.count >= 200 {
            calculateMetrics()
        }
    }
    
    private func calculateMetrics() {
        let totalRequests = requests.count
        let failedRequests = requests.filter { !$0.success }.count
        
        let pofod = Double(failedRequests) / Double(totalRequests)
        let timeInHours = Date().timeIntervalSince(startTime) / 3600
        let rocof = Double(failedRequests) / timeInHours
        let mtbf = calculateMTBF()
        let availability = Double(totalRequests - failedRequests) / Double(totalRequests)
        
        let metrics: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "probabilityOfFailureOnDemand": pofod,
            "rateOfOccurrenceOfFailures": rocof,
            "meanTimeBetweenFailures": mtbf,
            "availability": availability,
            "totalRequests": totalRequests,
            "measurementPeriod": Date().timeIntervalSince(startTime)
        ]
        
        print("DEBUG: Storing metrics to Firebase...")
        
        db.collection("reliability_metrics").addDocument(data: metrics) { error in
            if let error = error {
                print("DEBUG: Error storing metrics: \(error)")
            } else {
                print("DEBUG: Metrics stored successfully")
            }
        }
    }
    
    private func calculateMTBF() -> TimeInterval {
        let failures = requests.enumerated().filter { !$0.element.success }
        guard failures.count >= 2 else { return 0 }
        
        var totalTime: TimeInterval = 0
        for i in 0..<failures.count - 1 {
            let current = failures[i].element.timestamp
            let next = failures[i + 1].element.timestamp
            totalTime += next.timeIntervalSince(current)
        }
        
        return totalTime / Double(failures.count - 1)
    }
}
