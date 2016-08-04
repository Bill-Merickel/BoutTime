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
    var setOfInventions: [InventionSet] = []
    var copyOfListOfInventions: [Invention] = []
    var randomInvention1: InventionSet = InventionSet(invention: Invention(event: "", year: 0, url: ""), order: 0, position: 1)
    var randomInvention2: InventionSet = InventionSet(invention: Invention(event: "", year: 0, url: ""), order: 0, position: 2)
    var randomInvention3: InventionSet = InventionSet(invention: Invention(event: "", year: 0, url: ""), order: 0, position: 3)
    var randomInvention4: InventionSet = InventionSet(invention: Invention(event: "", year: 0, url: ""), order: 0, position: 4)
    
    // Timer Mechanics
    var timer = NSTimer()
    var counter: NSTimeInterval = 45
    var timeLeft = 45
    var timerRunning = false
    
    // Sound Mechanics
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    
    // Connections to View
    
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var View4: UIView!
    
    @IBOutlet weak var InventionListed1: UILabel!
    @IBOutlet weak var InventionListed2: UILabel!
    @IBOutlet weak var InventionListed3: UILabel!
    @IBOutlet weak var InventionListed4: UILabel!
    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var InformationLabel: UILabel!
    
    @IBOutlet weak var View1DownSelected: UIImageView!
    @IBOutlet weak var View2UpSelected: UIImageView!
    @IBOutlet weak var View2DownSelected: UIImageView!
    @IBOutlet weak var View3UpSelected: UIImageView!
    @IBOutlet weak var View3DownSelected: UIImageView!
    @IBOutlet weak var View4UpSelected: UIImageView!
    
    @IBOutlet weak var RoundSuccess: UIButton!
    @IBOutlet weak var RoundFailure: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile("Inventions", ofType: "plist")
            self.listOfInventions = PlistUnarchiver.createListFromArray(array)
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCorrectSound()
        loadIncorrectSound()
        setupAppUI()
        getListOfInventions()
        displaySetOfInventions()
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
    @IBAction func View2Up(sender: UIButton) {
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
    
    func setupAppUI() {
        hideEndButtons()
        
        View1.layer.cornerRadius = 5
        View2.layer.cornerRadius = 5
        View3.layer.cornerRadius = 5
        View4.layer.cornerRadius = 5
    }
    
    func getListOfInventions() {
        var randomIndex1 = 0
        var randomIndex2 = 0
        var randomIndex3 = 0
        var randomIndex4 = 0
        randomIndex1 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention1.invention = listOfInventions[randomIndex1]
        listOfInventions.removeAtIndex(randomIndex1)
        randomIndex2 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention2.invention = listOfInventions[randomIndex2]
        listOfInventions.removeAtIndex(randomIndex2)
        randomIndex3 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention3.invention = listOfInventions[randomIndex3]
        listOfInventions.removeAtIndex(randomIndex3)
        randomIndex4 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention4.invention = listOfInventions[randomIndex4]
        listOfInventions.removeAtIndex(randomIndex4)
        
        setOfInventions.append(randomInvention1); setOfInventions.append(randomInvention2); setOfInventions.append(randomInvention3); setOfInventions.append(randomInvention4)
    }
    
    func displaySetOfInventions() {
        getListOfInventions()
        resetTimer()
        beginTimer()
        hideEndButtons()
        
        TimerLabel.text = "0:\(timeLeft)"
        
        InventionListed1.text = randomInvention1.invention.event
        InventionListed2.text = randomInvention2.invention.event
        InventionListed3.text = randomInvention3.invention.event
        InventionListed4.text = randomInvention4.invention.event
        
    }
    
    func beginTimer() {
        if timerRunning == false {
            counter = 45
            timeLeft = 45
            timerRunning = true
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