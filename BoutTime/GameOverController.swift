//
//  GameOverController.swift
//  BoutTime
//
//  Created by Bill Merickel on 8/16/16.
//  Copyright © 2016 Bill Merickel. All rights reserved.
//

import UIKit

class GameOverController: UIViewController {
    
    var roundsCorrect = 0
    var roundsPlayed = 0
    let totalRounds = 6
    
    // Hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Enable portrait mode only.
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showScore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var gameScore: UILabel!
    
    func showScore() {
        gameScore.text = "\(roundsCorrect)/\(totalRounds)"
    }
    
    @IBAction func PlayAgain(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
