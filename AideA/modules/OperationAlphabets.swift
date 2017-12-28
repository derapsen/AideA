//
//  OperationAlphabets.swift
//  AideA_support
//
//  Created by AppCircle on 2017/11/01.
//  Copyright © 2017年 NichibiAppCircle. All rights reserved.
//

import Foundation

class OperationAlphabets
{
    let alphabets = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "r", "s", "t", "u", "v", "w", "z"]
    
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
}
