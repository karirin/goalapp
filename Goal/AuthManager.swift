//
//  AuthManager.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct UserDuration {
    let id: String
    let userName: String
    let duration: TimeInterval
}

class DurationManager {
    private var dbRef: DatabaseReference!

    init() {
        dbRef = Database.database().reference()
    }

    func saveDuration(userId: String, duration: TimeInterval) {
        let durationDict = ["duration": duration]
        dbRef.child("users/\(userId)/duration").setValue(durationDict) // ここを変更
    }
    
    func fetchDuration(userId: String, completion: @escaping (TimeInterval?) -> Void) {
        dbRef.child("users/\(userId)/duration").observeSingleEvent(of: .value) { snapshot in
            if let durationDict = snapshot.value as? [String: TimeInterval],
               let duration = durationDict["duration"] {
                completion(duration)
            } else {
                completion(nil)
            }
        }
    }
}

class AuthManager: ObservableObject {
    @Published var user: User?
    private var dbRef: DatabaseReference!

    static let shared = AuthManager()
    
    init() {
        user = Auth.auth().currentUser
       
        if user == nil {
            anonymousSignIn()
        }
    }

    let durationManager = DurationManager()

    func userExistsInDatabase(userId: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func anonymousSignIn() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                print("Signed in anonymously with user ID: \(result.user.uid)")
                self.user = result.user
            }
        }
    }
    
    func saveUserName(userId: String, userName: String) {
        let ref = Database.database().reference()
        ref.child("users").child(userId).setValue(["userName": userName])
    }
    
    func saveDurationIfFaster(userId: String, duration: TimeInterval) {
        durationManager.fetchDuration(userId: userId) { latestDuration in
            if let latestDuration = latestDuration {
                if duration < latestDuration {
                    self.durationManager.saveDuration(userId: userId, duration: duration)
                }
            } else {
                // If there's no latest duration, save the new duration
                self.durationManager.saveDuration(userId: userId, duration: duration)
            }
        }
    }
    func fetchUserName(userId: String, completion: @escaping (String?) -> Void) {
        dbRef.child("users/\(userId)/username").observeSingleEvent(of: .value) { snapshot in
            if let userName = snapshot.value as? String {
                completion(userName)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchAllUsersAndDurations(completion: @escaping ([UserDuration]) -> Void) {
        let ref = Database.database().reference().child("users")

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var userDurations: [UserDuration] = []

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let durationSnapshot = childSnapshot.childSnapshot(forPath: "duration/duration").value as? Double,
                   let userNameSnapshot = childSnapshot.childSnapshot(forPath: "userName").value as? String {
                   
                    let userDuration = UserDuration(id: childSnapshot.key, userName: userNameSnapshot, duration: durationSnapshot)
                    userDurations.append(userDuration)
                }
            }
            completion(userDurations)
        })
    }


}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn()
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}

