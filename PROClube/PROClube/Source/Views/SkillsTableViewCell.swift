//
//  SkillsTableViewCell.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/26/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class SkillsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textLabelSkill: UILabel!
    @IBOutlet weak var switchSkill: UISwitch!
    
    let user = PFUser.currentUser()
    
    @IBAction func switchSkill(sender: AnyObject) {
        if switchSkill.on {
            if user!["skills"]!.count < 5 {
                user?.addUniqueObject(textLabelSkill.text!, forKey: "skills")
            } else {
                switchSkill.setOn(false, animated: true)
            }
        } else {
            user?.removeObject(textLabelSkill.text!, forKey: "skills")
        }
        user?.saveInBackground()
    }

}
