//
//  StaticBubble.swift
//  Bubbles
//
//  Created by Axel Zuziak on 12.11.2015.
//  Copyright © 2015 zuziakaxel. All rights reserved.
//

import UIKit

enum BubbleRadius {
    case RandomBetween(min: Double, max: Double)
    case Random
    case Specified(radius: Double)
}

protocol BubbleViewDelegate {
    func numberOfBubbles() -> Int
    func radiusForBubbleAtIndex(index: Int) -> BubbleRadius
}



class StaticBubbleView: UIScrollView {

    var bubbles: [Bubble] = []
    var bubbleDelegate: BubbleViewDelegate? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSize = CGSizeMake(400, 400)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.contentSize = CGSizeMake(400, 400)
    }
    
    
    func reload() {
        if delegate == nil { return }
        removeSubviews()
        self.contentSize = calculateContentSize()
        let NoBubbles = (bubbleDelegate?.numberOfBubbles())!
        
        addSubviews()
    }
    
    private func removeSubviews() {
        for bubble in bubbles {
            bubble.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        for bubble in bubbles {
            addSubview(bubble)
        }
    }
    
    private func createBubbles(No: Int) {
        for i in 0...No-1 {
            bubbles.append(createBubble(i))
        }
    }
    
    private func createBubble(index: Int) -> Bubble {
        let radius = getRadius(index)
        if index == 0 {
            return Bubble(radius: radius, center: CGPoint(x: <#T##CGFloat#>, y: <#T##CGFloat#>))
        }
    }
    
    private func getRadius(index: Int) -> Double {
        if delegate == nil { return 1.0 }
        let rad = bubbleDelegate?.radiusForBubbleAtIndex(index)
        switch rad! {
        case .Random:
            return Double(arc4random_uniform(10) + 30)
        case .RandomBetween(let min, let max):
            return Double(arc4random_uniform(UInt32(max-min)) + UInt32(min))
        case .Specified(let userRadius):
            return userRadius
        }
    }
    
    private func calculateContentSize() -> CGSize {
        let height = self.frame.height
        let NoBubbles = (bubbleDelegate?.numberOfBubbles())!
        var width = 0.0
        for i in 0...NoBubbles-1 {
            width += getRadius(i)
        }
        width += 40 // spacing
        let maxWidth = width
        
        return CGSizeMake(CGFloat(maxWidth), height)
        
    }
}
