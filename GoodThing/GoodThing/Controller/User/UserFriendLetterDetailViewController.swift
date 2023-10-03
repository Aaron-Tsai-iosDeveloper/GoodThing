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
        performSegue(withIdentifier: "FromLetterDetailVCToWriteVC", sender: friend)
    }
    
    func setupLetterDetails() {
        guard let letter = selectedLetter else { return }
            letterTitleLabel.text = letter.title
            letterCreatedTimeLabel.text = letter.CreatedTime
            letterContentLabel.text = letter.content
            letterDetailPenNameButton.setTitle(friend?.userName, for: .normal)
    }
}

extension UserFriendLetterDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromLetterDetailVCToWriteVC", let destinationVC = segue.destination as? UserLetterWritingViewController, let friend = sender as? GoodThingUser {
            destinationVC.friend = friend
        }
    }
}
