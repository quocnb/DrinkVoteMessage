//
//  VoteViewController.swift
//  DrinkVote MessagesExtension
//
//  Created by Quoc Nguyen on 2018/10/24.
//  Copyright © 2018 Quoc Nguyen. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var voteConditionSetView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var confititiView: SAConfettiView!
    @IBOutlet weak var voteMaxControl: UISegmentedControl!

    var sendDrinkVoteMessage: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        isShowView(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
}

// MARK: - ACTIONS
private extension VoteViewController {
    @IBAction func didSelectDrinkButton(_ sender: Any) {
        self.textField.resignFirstResponder()
        guard let voteData = DataManager.shared.voteData, let myUUID = DataManager.shared.myUUID else {
            return
        }
        if !voteData.voted.contains(myUUID) {
            voteData.voted.append(myUUID)
        }
        reloadView()
        self.perform(#selector(sendMessage), with: nil, afterDelay: 0.2)
    }

    @IBAction func didChangeValue(_ sender: UISegmentedControl) {
        DataManager.shared.voteData.maxVote = sender.selectedSegmentIndex + 2
    }

    @objc func sendMessage() {
        self.sendDrinkVoteMessage?()
    }
}

extension VoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty == false {
            DataManager.shared.voteData.message = text
        }
    }
}

private extension VoteViewController {
    func countText(current: Int, max: Int) -> NSAttributedString {
        let enoughFlag = current >= max
        let totalAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60)]
        let countAttributes = [
            NSAttributedString.Key.foregroundColor: enoughFlag ? UIColor.green : UIColor.red,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: enoughFlag ? 80 : 50)]
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: "\(current)", attributes: countAttributes))
        result.append(NSAttributedString(string: " / "))
        result.append(NSAttributedString(string: "\(max)", attributes: totalAttributes))
        return result
    }

    func isShowView(_ show: Bool) {
        self.drinkButton.isHidden = !show
        self.textField.isHidden = !show
        self.voteConditionSetView.isHidden = !show
        self.countLabel.isHidden = !show
    }

    func reloadView() {
        guard let voteData = DataManager.shared.voteData, let myUUID = DataManager.shared.myUUID else {
            return
        }
        let isCreated = voteData.voted.isEmpty
        if isCreated {
            self.textField.placeholder = "rủ rê đi"
            self.textField.isEnabled = true
            self.textField.becomeFirstResponder()
            self.countLabel.isHidden = true
            self.voteConditionSetView.isHidden = false
            self.drinkButton.setTitle("ANNOUNCE", for: UIControl.State.normal)
        } else {
            if voteData.voted.contains(myUUID) {
                self.drinkButton.isEnabled = false
                self.drinkButton.backgroundColor = UIColor.lightGray
                self.drinkButton.setTitle("GJ BRO", for: UIControl.State.disabled)
            }
            self.drinkButton.setTitle("YOLO", for: UIControl.State.normal)
            self.countLabel.isHidden = false
            self.voteConditionSetView.isHidden = true
            self.textField.text = voteData.message
            self.countLabel.attributedText = countText(current: voteData.voted.count, max: voteData.maxVote)
            if voteData.voted.count >= voteData.maxVote {
                showConfititi()
            }
        }
        self.drinkButton.isHidden = false
        self.textField.isHidden = false
    }

    func showConfititi() {
        self.confititiView.isHidden = false
        self.confititiView.intensity = 1
        self.confititiView.type = SAConfettiView.ConfettiType.star
        self.confititiView.startConfetti()
    }
}
