//
//  UserFriendLetterDetailViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit

class UserFriendLetterDetailViewController: UIViewController {

    
    var friend: GoodThingUser?
    var selectedLetter: GoodThingLetter?
    
    @IBOutlet weak var letterDetailPenNameButton: UIButton!
    @IBOutlet weak var letterTitleLabel: UILabel!
    @IBOutlet weak var letterCreatedTimeLabel: UILabel!
    @IBOutlet weak var letterContentLabel: UITextView!
    @IBOutlet weak var letterDetailSendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLetterDetails()
    }
    
    @IBAction func letterDetailSendButtonTapped(_ sender: UIButton) {
        
    }
    
    func setupLetterDetails() {
        guard let letter = selectedLetter else { return }
            letterTitleLabel.text = letter.title
            letterCreatedTimeLabel.text = letter.createdTime
            letterContentLabel.text = letter.content
            letterDetailPenNameButton.setTitle(friend?.userName, for: .normal)
    }
}

extension UserFriendLetterDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromLetterDetailVCToWriteVC", let destinationVC = segue.destination as? UserLetterWritingViewController {
            if let friendValue = friend {
                print("Friend value is set and its user name is: \(friendValue.userId )")
                destinationVC.friend = friendValue
            } else {
                print("Friend value is NOT set!")
            }
        }
    }
}
