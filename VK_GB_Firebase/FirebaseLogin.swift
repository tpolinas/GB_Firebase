//
//  FirebaseLogin.swift
//  VK_GB_Firebase
//
//  Created by Polina Tikhomirova on 24.03.2022.
//

import Foundation
import Firebase

final class FirebaseLogin {
    let name: String
    let reference: DatabaseReference?
    
    init(name: String) {
        self.name = name
        self.reference = nil
    }
      
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let name = value["name"] as? String
        else { return nil }
        self.reference = snapshot.ref
        self.name = name
    }
    
    func toAnyObject() -> [String: Any] {
        ["name": name]
    }
}
    

