import UIKit

enum AppConfig {
    static let applicationId = "com.test.test"
    static let pixverseBearerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJzaGFyb3ZfMTk5OUBsaXN0LnJ1Iiwicm9sZSI6IkFETUlOIiwiZXhwIjo0OTM1MjA4NjcxLCJpYXQiOjE3ODE2MDg2NzEsInR5cGUiOiJhY2Nlc3MifQ.0GRnZq1LZA__0G0tYEsPER8lQiCiX_myE6_T_nMwUmc"
    
    static let userId: String = {
        if let savedUserId = UserDefaults.standard.string(forKey: "app_user_id") {
            return savedUserId
        } else {
            let newUserId = UUID().uuidString
            UserDefaults.standard.set(newUserId, forKey: "app_user_id")
            return newUserId
        }
    }()
    
    static let appId = "com.test.test"
}
