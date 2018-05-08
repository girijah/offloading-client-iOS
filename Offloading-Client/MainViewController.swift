//
//  MainViewController.swift
//  Offloading-Client
//
//  Created by Girijah Nagarajah on 5/7/18.
//  Copyright © 2018 Core Sparker. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableViewTitles = ["Image Recognition"]
    @IBOutlet weak var networkButton: UIButton!
    
    @IBOutlet weak var tasksTableView: UITableView!
    var isOffloadingEnabled: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeRight))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        let xib = UINib.init(nibName: "TaskTableViewCell", bundle: nil)
        self.tasksTableView.register(xib, forCellReuseIdentifier: "taskCell")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tasksTableView.reloadData()
    }

    @objc func respondToSwipeRight(gesture: UIGestureRecognizer) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "Home")
//        self.present(controller, animated: true, completion: nil)
        
        performSegue(withIdentifier: "showHome", sender: nil)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchOnChange(sender)
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        switchOnChange(sender)
    }
    
    func switchOnChange(_ sender: UISwitch) {
        if sender.isOn {
            self.isOffloadingEnabled = true
        }
        else {
            self.isOffloadingEnabled = false
        }
        
        self.tasksTableView.reloadData()
    }
    
    @IBAction func networkButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showNetwork", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHome" {
            
            let vc = segue.destination as! IRViewController
            
            if self.isOffloadingEnabled == true {
                vc.switcher = 2
            }
            else if self.isOffloadingEnabled == false {
                vc.switcher = 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.taskLabel.text = tableViewTitles[indexPath.row]
        
        if self.isOffloadingEnabled == true {
            cell.statusLabel.text = "- Remote Execution"
        }
        else if self.isOffloadingEnabled == false {
            cell.statusLabel.text = "- Local Execution"
        }
        else { // case: isOffloadingEnabled == nil
            if cell.switchControl.isOn {
                self.isOffloadingEnabled = true
                cell.statusLabel.text = "- Remote Execution"
            }
            else if cell.switchControl.isOn == false {
                self.isOffloadingEnabled = false
                cell.statusLabel.text = "- Local Execution"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showHome", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
