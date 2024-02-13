//
//  UIView+Constraints.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

//MARK: - Constraints

internal extension UIView {
	
	func addConstraints(format: String, options: NSLayoutConstraint.FormatOptions = [], metrics: [String: AnyObject]? = nil, views: [String: UIView]) {
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views))
	}
	
	func addUniversalConstraints(format: String, options: NSLayoutConstraint.FormatOptions = [], metrics: [String: AnyObject]? = nil, views: [String: UIView]) {
		addConstraints(format: "H:\(format)", options: options, metrics: metrics, views: views)
		addConstraints(format: "V:\(format)", options: options, metrics: metrics, views: views)
	}
	
}



//MARK: - Bounds

internal extension UIView {
	
	var windowFrame: CGRect? {
		return superview?.convert(frame, to: nil)
	}
	
}

internal extension UIWindow {
    
    static func visibleWindow() -> UIWindow? {
        var currentWindow: UIWindow?
        
        // Use the scene's windows if available
        if let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first {
            
            currentWindow = windowScene.windows.first { $0.isKeyWindow }
        }
        
        // If no key window is found in the active scene, fallback to searching through all windows
        if currentWindow == nil {
            let frontToBackWindows = Array(UIApplication.shared.windows.reversed())
            currentWindow = frontToBackWindows.first { $0.windowLevel == UIWindow.Level.normal }
        }
        
        return currentWindow
    }
    
}
