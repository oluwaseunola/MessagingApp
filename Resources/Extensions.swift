//
//  Extensions.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import Foundation
import UIKit

extension UIView {
    
    public var width : CGFloat {
        return self.frame.width
    }
    
    public var height : CGFloat {
        return self.frame.height
    }
    
    public var top : CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom : CGFloat {
        return self.frame.origin.y + height
    }
    
    public var left : CGFloat {
        return self.frame.origin.x
    }
    
    public var right : CGFloat {
        return self.frame.origin.x + width
    }
}
