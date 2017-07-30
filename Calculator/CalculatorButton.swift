//
//  CalculatorButton.swift
//  Calculator
//
//  Created by aishwarya pant on 29/07/17.
//  Copyright © 2017 aishwarya. All rights reserved.
//

import UIKit

class CalculatorButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var borderColor: CGColor = UIColor.lightText.cgColor
    var borderWidth: CGFloat = 1
    var cornerRadius: CGFloat = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = borderColor
        self.layer.borderWidth = borderWidth
//        self.layer.cornerRadius = cornerRadius
    }

}
