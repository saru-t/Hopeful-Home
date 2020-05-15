//
//  Keychain.swift
//  Teens in ai sn done
//
//  Created by Gnanasuntharam Thivyarajah on 14/05/2020.
//  Copyright © 2020 [Company]. All rights reserved.
//

import Foundation

//_ = try? storeKeychain(username: "Calculators", password: newCode)

//guard let code = try? getKeychain() else {
//    print("No Code")
//    return
//}
//print("Code: \(code)")


class Keychain {
    struct Credentials {
        var username: String
        var password: String
    }
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    
    public func clearKeychain(username: String) throws -> Any?{
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: username
//        ]
        let query: [String: Any] = [kSecClass as String:  kSecClassGenericPassword]
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
        print("Clear Keychain")
        return status
    }
    
    public func updateKeychain(username: String, password: String) throws -> Any?{
        let credentials = Credentials.init(username: username, password: password)
        let data = credentials.password.data(using: .utf8)!
        
        // store password as data and if you want to store username
//        let query: [String: Any] = [kSecClass as String:  kSecClassGenericPassword,
//                                    kSecAttrAccount as String: username,
//                                    kSecValueData as String: data]
        let query: [String: Any] = [kSecClass as String:  kSecClassGenericPassword]

        let fields: [String: Any] = [
            kSecAttrAccount as String: username,
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, fields as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status) }
        print("Updated Password")
        return status
    }
    
    public func storeKeychain(username: String, password: String) throws -> Any? {
        let credentials = Credentials.init(username: username, password: password)
        let data = credentials.password.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String:  kSecClassGenericPassword,
                                    kSecAttrAccount as String: username,
                                    kSecValueData as String: data]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status) }
        return status
    }
    
    public func getKeychain()throws ->String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError.unexpectedPasswordData
        }
        _ = Credentials(username: account, password: password)
        return password
    }
}
