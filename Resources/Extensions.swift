//
//  Extensions.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import Foundation
import UIKit

/// Makes  it easier to access View size attributes
extension UIView {
    
    public var width : CGFloat {
        return frame.width
    }
    
    public var height : CGFloat {
        return frame.height
    }
    
    public var top : CGFloat {
        return frame.origin.y
    }
    
    public var bottom : CGFloat {
        return frame.origin.y + height
    }
    
    public var left : CGFloat {
        return frame.origin.x
    }
    
    public var right : CGFloat {
        return frame.origin.x + width
    }
    
}

/// Creates a placeholder with a background color
extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}

