//
//  GigaPowerCounter.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/09/21.
//

import UIKit

class GigaPowerCounter: UIView {
    
    private let maxCount = 5
    var numberOfGigaPowers: Int {
        didSet {
            setCount(number: numberOfGigaPowers)
        }
    }
    
    private lazy var gigaPowerIcons: [UIImageView] = {
        var icons: [UIImageView] = []
        for index in 1...maxCount {
            let icon = UIImageView(image: #imageLiteral(resourceName: "icons8-mega-ball-48"))
            icon.heightAnchor.constraint(equalToConstant: 16).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
            icons.append(icon)
        }
        return icons
    }()
    
    private lazy var plusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 12)
        return label
    }()
    
    init(count: Int) {
        numberOfGigaPowers = min(count, maxCount)
        
        super.init(frame: .zero)
        
        let icon = gigaPowerIcons[0]
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        var previousIcon: UIImageView = icon
        
        for index in 1...maxCount-1 {
            let icon = gigaPowerIcons[index]
            addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: previousIcon.rightAnchor).isActive = true
            icon.isHidden = true
            previousIcon = icon
        }
        
        gigaPowerIcons.last?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        setCount(number: numberOfGigaPowers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCount(number: Int) {
        for index in 0..<maxCount {
            if index < number {
                gigaPowerIcons[index].isHidden = false
            } else {
                gigaPowerIcons[index].isHidden = true
            }
        }
        if number > maxCount {
            plusLabel.text = "+\(maxCount-number)"
        }
    }
}
