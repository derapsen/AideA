//
//  UserdefaultsManager.swift
//  AideA
//
//  Created by AppCircle on 2017/12/15.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//
import Foundation

enum UserSettings: String
{
    case name = "UserName"
    case myword = "UserMyword"
    case carryLists = "UserCarryLists"
    case login = "UserLogin"
    case theme = "UserTheme"
    
    func set(value: Int)
    {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func integer() -> Int
    {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    func set(value: Float)
    {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func float() -> Float
    {
        return UserDefaults.standard.float(forKey: self.rawValue)
    }
    
    func set(value: Double)
    {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func double() -> Double
    {
        return UserDefaults.standard.double(forKey: self.rawValue)
    }
    
//    func string() -> String?
//    {
//        return UserDefaults.standard.string(forKey: self.rawValue)
//    }
    
//    func stringArray() -> [String]?
//    {
//        return UserDefaults.standard.stringArray(forKey: self.rawValue)
//    }
    
    func set(value: Bool)
    {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func bool() -> Bool
    {
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    func set(value: Any)
    {
        UserDefaults.standard.set(value, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func object() -> Any?
    {
        return UserDefaults.standard.object(forKey: self.rawValue)
    }
    
    func setData(value: Any)
    {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: value)
        self.set(value: data)
    }
    
//    func string() -> String
//    {
//        guard let string = UserDefaults.standard.object(forKey: self.rawValue) as? String else
//        {
//            return ""
//        }
//        return string
//    }
}
