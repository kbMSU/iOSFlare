//
//  FlareTableViewCell.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/17/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class FlareTableViewCell: UITableViewCell {
    
    let oneDayTimeInterval : Double = 24*60*60
    
    @IBOutlet weak var flareImageView: UIImageView!
    @IBOutlet weak var flareNameLabel: UILabel!
    @IBOutlet weak var flareDateLabel: UILabel!
    @IBOutlet weak var flareMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        flareImageView.clipsToBounds = true
        flareImageView.layer.cornerRadius = flareImageView.frame.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadDate(date : NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year , .Hour , .Minute], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        let hour = components.hour
        let minute = components.minute
        
        var displayDate : String
        if NSDate().timeIntervalSinceDate(date) < oneDayTimeInterval {
             displayDate = "\(hour):\(minute)"
        } else {
            displayDate = "\(day):\(month):\(year)"
        }
        flareDateLabel.text = displayDate
    }
}
