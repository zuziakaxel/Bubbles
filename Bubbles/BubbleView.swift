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


public let DT = 0.001
class BubbleView: UIScrollView, UICollisionBehaviorDelegate {

    //MARK: Private -
    private var timer: NSTimer!
    private var animator: UIDynamicAnimator!
    private var collision: UICollisionBehavior!
    
    private var view: UIView!
    //MARK: Scroll
    var lastContentOffset = CGPointZero
    
    //MARK: Public -
    var bubbles: [Bubble] = []
    var bubbleDelegate: BubbleViewDelegate? {
        didSet {
            reload()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.contentSize = CGSizeMake(400, 400)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.contentSize = CGSizeMake(400, 400)
    }
    
    
    func reload() {
        if bubbleDelegate == nil { return }
        removeSubviews()

        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTap:")
        
        
        view = UIView(frame: CGRectMake(0, 0, calculateContentSize().width, calculateContentSize().width))
        self.contentSize = calculateContentSize()
        self.addSubview(view)
        animator = UIDynamicAnimator(referenceView: view)
        
        let NoBubbles = (bubbleDelegate?.numberOfBubbles())!
        for i in 0...NoBubbles-1 {
            var bubble = createBubble(i)
            while isBubbleAmbigous(bubble, bubbles: bubbles) {
                bubble = createBubble(i)
            }
            bubbles.append(bubble)
            self.view.addSubview(bubble)
            animator.addBehavior(bubble.movement)
        }

        //        gravity = UIGravityBehavior(items: [square])
        //        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: bubbles)
        collision.collisionDelegate = self
        collision.collisionMode = .Everything
        // add a boundary that has the same frame as the barrier
        collision.addBoundaryWithIdentifier("barrier", forPath: UIBezierPath(rect: self.view.frame))
        collision.addBoundaryWithIdentifier("barrierDown", fromPoint: CGPointMake(self.view.frame.origin.x, view.frame.height), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, view.frame.height))
        collision.addBoundaryWithIdentifier("barrierBottom", fromPoint: CGPointMake(self.view.frame.origin.x, 480), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 480))
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        let itemBehaviour = UIDynamicItemBehavior(items: bubbles)
        itemBehaviour.elasticity = 1.0
        animator.addBehavior(itemBehaviour)
//        addSubviews()
    }
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
            print("Boundary contact occurred - \(identifier)")
    }

    func update() {
        print("Update: \(NSDate())")
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
                bubble.update()
//            }
        }
    }
    
    
    
    private func removeSubviews() {
        for bubble in bubbles {
            bubble.removeFromSuperview()
        }
    }
    
    private func addSubviews() {
        for bubble in bubbles {
            self.view.addSubview(bubble)
        }
    }
    
    private func createBubbles(No: Int) {
        for i in 0...No-1 {
            bubbles.append(createBubble(i))
        }
    }
    
    private func createBubble(index: Int) -> Bubble {
        let radius = getRadius(index)
        
        let randomX = arc4random_uniform(UInt32(Int(contentSize.width)-Int(radius))) + UInt32(radius)
        let randomY = arc4random_uniform(UInt32(Int(contentSize.height)-Int(radius))) + UInt32(radius)
        return Bubble(radius: CGFloat(radius), center: CGPoint(x: Double(randomX), y: Double(randomY)))
    }
    
    private func getRadius(index: Int) -> Double {
        if bubbleDelegate == nil { return 1.0 }
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
//        let width = self.frame.width * 3.0
        let NoBubbles = (bubbleDelegate?.numberOfBubbles())!
        var width = 0.0
        for i in 0...NoBubbles-1 {
            width += getRadius(i)
        }
        width += 40 // spacing
        let maxWidth = width
        
        return CGSizeMake(CGFloat(maxWidth), height)
        
    }
    
    
    //MARK: Helpers:
    
    private func isBubbleAmbigous(newBubble: Bubble, bubbles: [Bubble]) -> Bool {
        for bubble in bubbles {
            if newBubble == bubble {
                return true
            }
        }
        return false
    }
}
