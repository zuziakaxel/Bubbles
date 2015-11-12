//
//  BubbleView+Scroll.swift
//  Bubbles
//
//  Created by Axel Zuziak on 12.11.2015.
//  Copyright © 2015 zuziakaxel. All rights reserved.
//

import UIKit

private enum ScrollDirection {
    case Left, Right, None
}

extension BubbleView: UIScrollViewDelegate {
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        var direction: ScrollDirection = .None
        if lastContentOffset.x > scrollView.contentOffset.x {
            direction = .Right
        } else if lastContentOffset.x < scrollView.contentOffset.x {
            direction = .Left
        }
        if direction == .None { return }
        for bubble in bubbles {
            let velocityIncrement = direction == .Left ? 0.005 : -0.005
            bubble.v.x.value += velocityIncrement
        }
    }
}
