//
//  DataManager.swift
//  DrinkVote MessagesExtension
//
//  Created by Quoc Nguyen on 2018/10/24.
//  Copyright © 2018 Quoc Nguyen. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    var myUUID: UUID!
    var voteData: VoteData!

    init() {
    }
}
