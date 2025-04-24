//
//  NotificationViewController.swift
//  ContentService
//
//  Created by Nguyen Ngoc Tuyen on 24/4/25.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    
   @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        print(notification.request.content.userInfo)
        if let imageURL = notification.request.content.userInfo["image"] as? String {
            print(imageURL)
                downloadImage(from: imageURL)
            }
    }
    
    private func downloadImage(from link: String) {
        guard let url = URL(string: link) else { return }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        task.resume()
    }

}
