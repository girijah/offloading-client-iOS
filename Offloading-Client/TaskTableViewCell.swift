//
//  TaskTableViewCell.swift
//  Offloading-Client
//
//  Created by Girijah Nagarajah on 5/7/18.
//  Copyright © 2018 Core Sparker. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
//    @IBAction func switchValueChanged(_ sender: UISwitch) {
//        switchOnChange()
//    }
//
//    @IBAction func switchTapped(_ sender: UISwitch) {
//        switchOnChange()
//    }
//
//    func switchOnChange() {
//        if self.switchControl.isOn {
//            self.statusLabel.text = "Remote Execution: ON"
//        }
//        else {
//            self.statusLabel.text = "Remote Execution: OFF \t \t Local Execution"
//        }
//    }
    
}
