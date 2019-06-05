//
//  GameViewController.swift
//  Rushhour
//
//  Created by Andy Lochan on 5/1/19.
//  Copyright © 2019 Andy Lochan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

struct MyVar {
    static var Startflag = 0; //Used to fix aspect ratio issue
}

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true //debug
            view.showsNodeCount = true //debug
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    //Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
