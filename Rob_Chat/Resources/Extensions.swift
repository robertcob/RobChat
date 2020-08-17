//
//  Extensions.swift
//  Rob_Chat
//
//  Created by Robert O'Brien on 16/08/2020.
//  Copyright © 2020 Robert O'Brien. All rights reserved.
//

import Foundation
import UIKit

//extending the UIView class to add some repetitive BS
extension UIView {
    
    public var width: CGFloat {
        self.frame.size.width
        
    }
    
    public var height: CGFloat {
        self.frame.size.height
        
    }
    
    public var top: CGFloat {
        self.frame.origin.y
        
    }
    
    public var bottom: CGFloat {
        self.frame.size.height + self.frame.origin.y
        
    }
    
    public var left: CGFloat {
        self.frame.origin.x
        
    }
    
    public var right: CGFloat {
        self.frame.size.width + self.frame.origin.x
        
    }
    
    
}

extension UIColor {
    func colorFromHex(_ hex : String) -> UIColor {
        var hexString =  hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        assert(hexString.count == 6, "invalid hex code used")

        
//        if hexString.count != 6 {
//            return UIColor.link
//        }
        
        var rgb : UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
    }
}
