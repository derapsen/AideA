//
//  OperationAlphabets.swift
//  AideA_support
//
//  Created by AppCircle on 2017/11/01.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//

import Foundation

public class OperationAlphabets: NSObject
{
    private let alphabets = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "r", "s", "t", "u", "v", "w", "z"]
    var carryingAlphabets: [String] = []
    
    override init()
    {
        guard let data = UserSettings.carryLists.object() as? Data else
        {
            print("Could not convert Data : carryLists")
            return
        }
        guard let list = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] else
        {
            print("Could not unarchive Array : carryLists")
            return
        }
        self.carryingAlphabets = list
    }
    
    func returnWithWildcardAlphabets() -> [String]
    {
        let wildcardAlphabets = self.alphabets + ["?", "*"]
        return wildcardAlphabets
    }
    
    func selectAlphabetAtRandom() -> String
    {
        let length = self.alphabets.count
        let index = Int(arc4random_uniform(UInt32(length)))
        let selectAlphabet = self.alphabets[index]
        return selectAlphabet
    }
    
    func notFoundAlphabet(word: String) -> Bool
    {
        if let _ = self.carryingAlphabets.index(of: word)
        {
            return false
        }
        return true
    }
}
