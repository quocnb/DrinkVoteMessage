//
//  VoteData.swift
//  DrinkVote MessagesExtension
//
//  Created by Quoc Nguyen on 2018/10/23.
//  Copyright © 2018 Quoc Nguyen. All rights reserved.
//

import Foundation
import Messages

class VoteData {
    var maxVote = 4
    var message: String = "Nhậu đê"
    var voted = [UUID]()

    init(maxVote: Int) {
        self.maxVote = maxVote
    }

    init?(message: MSMessage?) {
        guard let messageURL = message?.url else {
            return nil
        }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        guard let queryItems = urlComponents.queryItems else {
            return nil
        }
        for item in queryItems {
            if item.name == "voted", let value = item.value {
                self.voted = value.components(separatedBy: ",").filter({ (str) -> Bool in
                    return !str.isEmpty
                }).map({ (string) -> UUID in
                    return UUID(uuidString: string) ?? UUID(uuid: UUID_NULL)
                })
            }
            if item.name == "maxVote" {
                self.maxVote = Int(item.value ?? "") ?? 0
            }
            if item.name == "message", let value = item.value {
                self.message = value
            }
        }
    }

    func toURLQueryItem() -> [URLQueryItem] {
        var query = [URLQueryItem]()
        let votedString = self.voted.map { (uuid) -> String in
            return uuid.uuidString
        }.joined(separator: ",")
        query.append(URLQueryItem(name: "maxVote", value: "\(maxVote)"))
        query.append(URLQueryItem(name: "message", value: message))
        query.append(URLQueryItem(name: "voted", value: votedString))
        return query
    }
}
