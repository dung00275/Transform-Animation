//
//  ViewController.swift
//  Transform-Animation
//
//  Created by dungvh on 3/30/16.
//  Copyright © 2016 dungvh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewTransform: TransfromView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewTransform.runAnimationAuto()
    }

    @IBAction func didChangeSlider(sender: UISlider) {
        self.viewTransform.transformToPercent(CGFloat(sender.value))
    }

}

