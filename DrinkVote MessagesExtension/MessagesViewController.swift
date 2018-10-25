//
//  MessagesViewController.swift
//  DrinkVote MessagesExtension
//
//  Created by Quoc Nguyen on 2018/10/23.
//  Copyright © 2018 Quoc Nguyen. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.

        // Use this method to configure the extension and restore previously stored state.
        presentViewController(for: conversation, with: presentationStyle)
    }

    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.

        // Use this method to trigger UI updates in response to the message.
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        removeAllChildViewControllers()
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        guard let conversation = activeConversation else {
            fatalError("Expected a conversation")
        }
        DataManager.shared.myUUID = conversation.localParticipantIdentifier
        DataManager.shared.voteData = VoteData(message: conversation.selectedMessage) ?? VoteData(maxVote: 2)
        presentViewController(for: conversation, with: presentationStyle)
    }

    private func removeAllChildViewControllers() {
        for child in self.children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }

    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        // Remove any child view controllers that have been presented.
        removeAllChildViewControllers()

        let controller: UIViewController
        if presentationStyle == .compact {
            controller = self.storyboard!.instantiateViewController(withIdentifier: "MenuCollectionViewController")
            (controller as! MenuCollectionViewController).didSelectAddBeer = { [weak self] beer in
                if beer == 1 {
                    self?.requestPresentationStyle(.expanded)
                } else {
                    let voteData = VoteData(maxVote: beer)
                    voteData.voted = [conversation.localParticipantIdentifier]
                    DataManager.shared.voteData = voteData
                    self?.sendMessage()
                }
            }
        } else {
            controller = voteViewController()
        }

        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        controller.didMove(toParent: self)
    }

    private func voteViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VoteViewController") as? VoteViewController else {
            fatalError()
        }
        controller.sendDrinkVoteMessage = { [unowned self] in
            self.sendMessage()
        }
        return controller
    }

}

private extension MessagesViewController {
    @objc func sendMessage() {
        guard let conversation = activeConversation else {
            fatalError("Expected a conversation")
        }
        guard let voteData = DataManager.shared.voteData else {
            fatalError("No Vote data")
        }
        let message = composeMessage(with: voteData, session: conversation.selectedMessage?.session)
        conversation.insert(message) { (err) in
            if let error = err {
                print("Error occurred", error.localizedDescription)
            }
        }
        dismiss()
    }

    func composeMessage(with voteData: VoteData, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = voteData.toURLQueryItem()

        let caption = voteData.message + " (\(voteData.voted.count)/\(voteData.maxVote))"
        let layout = MSMessageTemplateLayout()
        layout.image = #imageLiteral(resourceName: "beer.png")
        layout.caption = caption

        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout

        return message
    }
}
