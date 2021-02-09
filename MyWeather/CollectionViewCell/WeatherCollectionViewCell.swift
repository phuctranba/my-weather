//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by ZipEnter on 08/02/2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell",
                     bundle: nil)
    }

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    func configure(with model: HourlyWeatherEntry) {
        self.tempLabel.text = "\(model.temperature)°"
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(named: "clear")
        self.timeLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: inputDate)
    }

}
