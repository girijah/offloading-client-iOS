//
//  DetailViewController.swift
//  Offloading-Client
//
//  Created by Girijah Nagarajah on 5/7/18.
//  Copyright © 2018 Core Sparker. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeDown))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDownGesture)
    }

    @objc func respondToSwipeDown(gesture: UIGestureRecognizer) {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "Home")
        //        self.present(controller, animated: true, completion: nil)
        
        performSegue(withIdentifier: "showHomeFromDetail", sender: nil)
    }


}
