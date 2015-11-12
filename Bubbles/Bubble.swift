//
//  Bubble.swift
//  Bubbles
//
//  Created by Axel Zuziak on 10.11.2015.
//  Copyright © 2015 zuziakaxel. All rights reserved.
//

import UIKit


class Bubble: UIView {
//MARK: IBOoutlets -
    
//MARK: Physical Properties -
    var a = Acceleration(x: 0, y: -G_VALUE)
    var v = Velocity(x: 1.0, y: 1.0)
    var m: Double
    var r: Double
    var updated = false
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init(radius: CGFloat, center: CGPoint) {
        r = Double(radius)
        let frame = CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius)
        m = Double(radius)
        super.init(frame: frame)
        self.layer.cornerRadius = radius
        self.backgroundColor = UIColor.redColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func didCollideWithTopBottomWall(wall: CGFloat) -> Bool {
        let centerY: Double = Double(center.y)
        let height = Double(wall)
        if centerY + r >= height || centerY - r <= 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func didCollideWithSideWall(wall: CGFloat) -> Bool {
        let centerX: Double = Double(center.x)
        let wallX = Double(wall)
        
        if centerX + r >= wallX || centerX - r <= 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func didCollidedWithBubble(bubble: Bubble) -> Bool {
        let d = sqrt(pow(bubble.center.x - center.x, 2) + pow(bubble.center.y - center.y, 2))
        if Double(d) <= (r+bubble.r) {
            return true
        } else {
            return false
        }
    }
    
    func update() {
        
    }
    
}

func == (left: Bubble, right: Bubble) -> Bool {
    let d = sqrt(pow(left.center.x - right.center.x, 2) + pow(left.center.y - right.center.y, 2))
    print("d=\(d), r+r = \(left.r + right.r)")
    if Double(d) <= (left.r + right.r) {
        return true
    } else {
        return false
    }
}


class BubbleHelper {
    
    func createBubbles(no: Int, containerSize: CGSize) -> [Bubble] {
        var bubbles: [Bubble] = []
        for _ in 1...no {
            var bubble = createBubble(containerSize)
            while isBubbleAmbigous(bubble, bubbles: bubbles) {
                bubble = createBubble(containerSize)
            }
            bubbles.append(bubble)
        }
        
        return bubbles
    }
    
    
    
    private func createBubble(containerSize: CGSize) -> Bubble {
        let randomRadius = arc4random_uniform(10) + 30
        let randomX = arc4random_uniform(UInt32(Int(containerSize.width)-Int(randomRadius))) + randomRadius
        let randomY = arc4random_uniform(UInt32(Int(containerSize.height)-Int(randomRadius))) + randomRadius
        let bubble = Bubble(radius: CGFloat(randomRadius), center: CGPoint(x: CGFloat(randomX), y: CGFloat(randomY)))
        print("(\(bubble.center.x),\(bubble.center.x)), r = \(bubble.r)")
        return bubble
    }
    
    private func isBubbleAmbigous(newBubble: Bubble, bubbles: [Bubble]) -> Bool {
        for bubble in bubbles {
            if newBubble == bubble {
                return true
            }
        }
        return false
    }
    
    
}

class BubbleView: UIScrollView {
    
    var timer: NSTimer!
    private var bubbles: [Bubble] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSize = CGSizeMake(400, 400)
        bubbles = BubbleHelper().createBubbles(10, containerSize: contentSize)
        timer = NSTimer.scheduledTimerWithTimeInterval(DT, target: self, selector: "update", userInfo: nil, repeats: true)
        for bubble in bubbles {
            addSubview(bubble)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.contentSize = CGSizeMake(400, 400)
    }
    
    func update() {
        for bubble in bubbles {
            bubble.updated = false
            if bubble.didCollideWithTopBottomWall(contentSize.height) {
                bubble.v.y.value = -bubble.v.y.value
                bubble.frame.origin.x += CGFloat(2*bubble.v.x.value)
                bubble.frame.origin.y += CGFloat(2*bubble.v.y.value)
                bubble.updated = true
            }
            if bubble.didCollideWithSideWall(contentSize.width) {
                bubble.v.x.value = -bubble.v.x.value
                bubble.frame.origin.x += CGFloat(2*bubble.v.x.value)
                bubble.frame.origin.y += CGFloat(2*bubble.v.y.value)
                bubble.updated = true
            }
            for secondBubble in bubbles {
                if bubble === secondBubble { break}
                if bubble.didCollidedWithBubble(secondBubble) {
                    let newVelX1 = (bubble.v.x.value * (bubble.m - secondBubble.m) + (2 * secondBubble.m * secondBubble.v.x.value)) / (bubble.m + secondBubble.m);
                    let newVelY1 = (bubble.v.y.value * (bubble.m - secondBubble.m) + (2 * secondBubble.m * secondBubble.v.y.value)) / (bubble.m + secondBubble.m);
                    let newVelX2 = (secondBubble.v.x.value * (secondBubble.m - bubble.m) + (2 * bubble.m * bubble.v.x.value)) / (bubble.m + secondBubble.m);
                    let newVelY2 = (secondBubble.v.y.value * (secondBubble.m - bubble.m) + (2 * bubble.m * bubble.v.y.value)) / (bubble.m + secondBubble.m);
                    if bubble.updated == false {
                        bubble.v = Velocity(x:newVelX1, y: newVelY1)
                        bubble.updated = true
                        bubble.frame.origin.x += CGFloat(bubble.v.x.value)
                        bubble.frame.origin.y += CGFloat(bubble.v.y.value)
                    }
                    if secondBubble.updated == false {
                        secondBubble.v = Velocity(x: newVelX2, y: newVelY2)
                        secondBubble.updated = true
                        bubble.frame.origin.x += CGFloat(bubble.v.x.value)
                        bubble.frame.origin.y += CGFloat(bubble.v.y.value)
                    }

                }
            }
//            if bubble.updated == false {
                bubble.frame.origin.x += CGFloat(bubble.v.x.value)
                bubble.frame.origin.y += CGFloat(bubble.v.y.value)
//            }
        }
    }
    
    
    
}


public let DT = 0.01
public let G_VALUE: Double = 9.82