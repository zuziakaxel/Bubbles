//
//  ViewController.swift
//  Bubbles
//
//  Created by Axel Zuziak on 10.11.2015.
//  Copyright © 2015 zuziakaxel. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, BubbleViewDelegate {


    @IBOutlet weak var bubbleView: BubbleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bubbleView.bubbleDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: BubbleView Delegate:
    
    func numberOfBubbles() -> Int {
        return 30
    }
    
    func radiusForBubbleAtIndex(index: Int) -> BubbleRadius {
        return BubbleRadius.Specified(radius: 40)
    }
    

}

