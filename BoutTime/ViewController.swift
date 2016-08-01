//
//  ViewController.swift
//  BoutTime
//
//  Created by Bill Merickel on 7/31/16.
//  Copyright © 2016 Bill Merickel. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    // Game Mechanics
    var listOfInventions: [Invention] = []
    let roundsPerGame = 6
    var roundsPlayed = 0
    var roundsCorrect = 0
    var setOfInventions: [Invention] = []
    var randomInvention1: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention2: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention3: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention4: Invention = Invention(event: "", year: 0, url: "")
    // Timer Mechanics
    var timer = NSTimer()
    var counter: NSTimeInterval = 45
    var timeLeft = 45
    var timerRunning = false
    
    // Sound Mechanics
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    
    // Connections to View
    @IBOutlet weak var InventionListed1: UILabel!
    @IBOutlet weak var InventionListed2: UILabel!
    @IBOutlet weak var InventionListed3: UILabel!
    @IBOutlet weak var InventionListed4: UILabel!
    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var InformationLabel: UILabel!
    
    @IBOutlet weak var RoundSuccess: UIButton!
    @IBOutlet weak var RoundFailure: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistConverter.dictionaryFromFile("Inventions", ofType: "plist")
            let listOfInventions = try PlistUnarchiver.createListFromDictionary(dictionary)
            self.listOfInventions = listOfInventions
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Enable portrait mode only.
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func View1Down(sender: UIButton) {
    }
    @IBAction func View1Up(sender: UIButton) {
    }
    @IBAction func View2Down(sender: UIButton) {
    }
    @IBAction func View3Up(sender: UIButton) {
    }
    @IBAction func View3Down(sender: UIButton) {
    }
    @IBAction func View4Up(sender: UIButton) {
    }
    @IBAction func SuccessNextRound() {
    }
    @IBAction func FailureNextRound() {
    }
    
    func getListOfInventions() {
        var randomIndex1 = 0
        var randomIndex2 = 0
        var randomIndex3 = 0
        var randomIndex4 = 0
        randomIndex1 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention1 = listOfInventions[randomIndex1]
        listOfInventions.removeAtIndex(randomIndex1)
        randomIndex2 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention2 = listOfInventions[randomIndex2]
        listOfInventions.removeAtIndex(randomIndex2)
        randomIndex3 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention3 = listOfInventions[randomIndex3]
        listOfInventions.removeAtIndex(randomIndex3)
        randomIndex4 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention4 = listOfInventions[randomIndex4]
        listOfInventions.removeAtIndex(randomIndex4)
        
        setOfInventions.append(randomInvention1); setOfInventions.append(randomInvention2); setOfInventions.append(randomInvention3); setOfInventions.append(randomInvention4)
    }
    
    func displaySetOfInventions() {
        getListOfInventions()
        resetTimer()
        beginTimer()
        hideEndButtons()
        
        TimerLabel.text = "0:\(timeLeft)"
        
        InventionListed1.text = randomInvention1.event
        InventionListed2.text = randomInvention2.event
        InventionListed3.text = randomInvention3.event
        InventionListed4.text = randomInvention4.event
        
    }
    
    func beginTimer() {
        if timerRunning == false {
            counter = 45
            timeLeft = 45
            timer = NSTimer.init(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func updateTimer() {
        timeLeft -= 1
        TimerLabel.text = "0:\(timeLeft)"
        
        if timeLeft == 0 {
            timer.invalidate()
            // Add after round stuff
        }
    }
    
    func resetTimer() {
        timeLeft = 45
        counter = 45
        timerRunning = false
        beginTimer()
    }
    
    func checkRound() {
        
    }
    
    func hideEndButtons() {
        RoundSuccess.hidden = true
        RoundFailure.hidden = true
    }
    
    func loadCorrectSound() {
        let pathToSoundFile = NSBundle.mainBundle().pathForResource("CorrectDing", ofType: "wav")
        let soundURL = NSURL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL, &correctSound)
    }
    
    func playCorrectSound() {
        AudioServicesPlaySystemSound(correctSound)
    }
    
    func loadIncorrectSound() {
        let pathToSoundFile = NSBundle.mainBundle().pathForResource("IncorrectBuzz", ofType: "wav")
        let soundURL = NSURL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL, &incorrectSound)
    }
    
    func playIncorrectSound() {
        AudioServicesPlaySystemSound(incorrectSound)
    }
    
}