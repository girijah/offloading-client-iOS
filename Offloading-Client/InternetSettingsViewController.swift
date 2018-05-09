//
//  InternetSettingsViewController.swift
//  Offloading-Client
//
//  Created by Girijah Nagarajah on 5/7/18.
//  Copyright © 2018 Core Sparker. All rights reserved.
//

import UIKit

class InternetSettingsViewController: UIViewController {
    
    static let kREMOTE_CONNECTIVITY_ENDPOINT = "/test"
    static let kIP_ADDRESS = "IP"
    static let kPORT = "PORT"
    
    private let urlSession = URLSession.shared
    
    @IBOutlet weak var ipAddressTextField: UITextField!
    
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var remoteAvailability: Int!
    var endPoint: String!
    var ip: String!
    var port: String!
    var cameFrom: Int! // 1 - Main View, 2 - IR View
    static var isIPAddressCorrect: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeLeft))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector( viewTapped))
        self.view.addGestureRecognizer(tap)
        
        ip = UserDefaults.standard.object(forKey: InternetSettingsViewController.kIP_ADDRESS) as? String ?? ""
        port = UserDefaults.standard.object(forKey: InternetSettingsViewController.kPORT) as? String ?? "8181"
        
        self.ipAddressTextField.text! = ip!
        self.portTextField.text! = port!
    }
    
    @objc func viewTapped() {
        self.view.endEditing(true)
    }

    @objc func respondToSwipeLeft(gesture: UIGestureRecognizer) {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "Settings")
        //        self.present(controller, animated: true, completion: nil)
        
        performSegue(withIdentifier: "showMainFromInternet", sender: nil)
    }
    
    func saveEnteredRemoteAddress() {
        // Successful endpoint saved to UserDefaults
        UserDefaults.standard.set(ipAddressTextField.text!, forKey: InternetSettingsViewController.kIP_ADDRESS)
        UserDefaults.standard.set(portTextField.text!, forKey: InternetSettingsViewController.kPORT)
    }

    @IBAction func connectButtonTapped(_ sender: UIButton) {
        endPoint = "http://\(String(describing: ipAddressTextField.text!)):\(String(describing: portTextField.text!))\(InternetSettingsViewController.kREMOTE_CONNECTIVITY_ENDPOINT)"
        
        self.saveEnteredRemoteAddress()
        
        self.connectButton.setTitle("", for: UIControlState.normal)
        self.connectButton.loadingIndicator(true)
        self.errorLabel.text = ""

        // remote availability
        checkRemoteAvailability()
        
        connectionStatusUpdate()

    }
    
    func checkRemoteAvailability() {
        
        let parameters = ["test" : "hi"]
        
        guard let urlToExecute = URL(string: endPoint) else {
            self.remoteAvailability = 4
            self.connectionStatusUpdate()
            return
        }
        
        InternetSettingsViewController.isIPAddressCorrect = true
        
        var webRequest = URLRequest(url: urlToExecute)
        webRequest.httpMethod = "POST"
        webRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-type")
        
        let urlParams =  parameters.compactMap { (key, value) -> String? in
            "\(key)=\(value)"
            }.joined(separator: "&")
        
        webRequest.httpBody = urlParams.data(using: .utf8, allowLossyConversion: true)
        
        let dataTask = urlSession.dataTask(with: webRequest) {
            (data, response, error) in
            
            guard let data = data, let _ = response, error == nil else {
                print("Connection unavailable!!")
                self.remoteAvailability = 1
                self.connectionStatusUpdate()
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let result = jsonResponse?["remote_says"] as? String else {
                    return
                }
                
                print("Connection available!")
                
                DispatchQueue.main.async {[unowned self] in
                    if result == "hello from remote" {
                        self.remoteAvailability = 2
                        self.connectionStatusUpdate()
                    }
                    else {
                        self.remoteAvailability = 3
                        self.connectionStatusUpdate()

                    }
                }
            }
            catch {
                print (error.localizedDescription)
            }
        }
        
        dataTask.resume()
    }
    
    func connectionStatusUpdate() {
        if remoteAvailability == 1 {
            self.connectButton.loadingIndicator(false)
            self.connectButton.setTitle("Connect", for: UIControlState.normal)
            self.errorLabel.text = "Could not connect to the server. Server stopped running!"
            remoteAvailability = 0
        }
        else if remoteAvailability == 2 {
            self.connectButton.loadingIndicator(false)
            self.connectButton.setTitle("Connected!", for: UIControlState.normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 1 second delay
                if self.cameFrom == 1 {
                    self.performSegue(withIdentifier: "showMainFromInternet", sender: nil)
                }
                else if self.cameFrom == 2 {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "Home") as! IRViewController
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        else if remoteAvailability == 3 {
            self.connectButton.loadingIndicator(false)
            self.connectButton.setTitle("Pending", for: UIControlState.normal)

        }
        else if remoteAvailability == 4 {
            self.connectButton.loadingIndicator(false)
            self.connectButton.setTitle("Connect", for: UIControlState.normal)
            self.errorLabel.text = "Endpoint error!"
            remoteAvailability = 0
        }
        
    }
    
}

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
