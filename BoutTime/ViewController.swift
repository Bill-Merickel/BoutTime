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
    var setOfInventions: [RandomInvention] = []
    var setOfInventionsInOrder: [RandomInvention] = []
    var copyOfListOfInventions: [Invention] = []
    var randomInvention1 = RandomInvention(invention: Invention(event: "", year: 0, url: ""), index: 0)
    var randomInvention2 = RandomInvention(invention: Invention(event: "", year: 0, url: ""), index: 0)
    var randomInvention3 = RandomInvention(invention: Invention(event: "", year: 0, url: ""), index: 0)
    var randomInvention4 = RandomInvention(invention: Invention(event: "", year: 0, url: ""), index: 0)
    
    // Timer Mechanics
    var timer = NSTimer()
    var counter: NSTimeInterval = 60
    var timeLeft = 60
    var timerRunning = false
    
    // Sound Mechanics
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 1
    
    // Connections to View
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    @IBOutlet weak var View4: UIView!
    @IBOutlet weak var InventionListed1: UIButton!
    @IBOutlet weak var InventionListed2: UIButton!
    @IBOutlet weak var InventionListed3: UIButton!
    @IBOutlet weak var InventionListed4: UIButton!
    @IBOutlet weak var View1DownSelected: UIImageView!
    @IBOutlet weak var View2UpSelected: UIImageView!
    @IBOutlet weak var View2DownSelected: UIImageView!
    @IBOutlet weak var View3UpSelected: UIImageView!
    @IBOutlet weak var View3DownSelected: UIImageView!
    @IBOutlet weak var View4UpSelected: UIImageView!
    @IBOutlet weak var TimerLabel: UIButton!
    @IBOutlet weak var InformationLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let array = try PlistConverter.arrayFromFile("Inventions", ofType: "plist")
            self.listOfInventions = PlistUnarchiver.createListFromArray(array)
            self.copyOfListOfInventions = PlistUnarchiver.createListFromArray(array)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        showAlert()
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Check answer when device is shaken
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            checkAnswer()
        }
    }
    
    // Buttons to swap events
    @IBAction func View1Down(sender: UIButton) {
        swapInventions(setOfInventions[0], secondInvention: setOfInventions[1])
    }
    @IBAction func View2Up(sender: UIButton) {
        swapInventions(setOfInventions[1], secondInvention: setOfInventions[0])
    }
    @IBAction func View2Down(sender: UIButton) {
        swapInventions(setOfInventions[1], secondInvention: setOfInventions[2])
    }
    @IBAction func View3Up(sender: UIButton) {
        swapInventions(setOfInventions[2], secondInvention: setOfInventions[1])
    }
    @IBAction func View3Down(sender: UIButton) {
        swapInventions(setOfInventions[2], secondInvention: setOfInventions[3])
    }
    @IBAction func View4Up(sender: UIButton) {
        swapInventions(setOfInventions[3], secondInvention: setOfInventions[1])
    }
    @IBAction func PlayNextRound(sender: AnyObject) {
        
    }
    
    func setupAppUI() {
        View1.layer.cornerRadius = 5
        View2.layer.cornerRadius = 5
        View3.layer.cornerRadius = 5
        View4.layer.cornerRadius = 5
        
        InventionListed1.setTitle("", forState: .Normal)
        InventionListed2.setTitle("", forState: .Normal)
        InventionListed3.setTitle("", forState: .Normal)
        InventionListed4.setTitle("", forState: .Normal)
    }
    
    func getListOfInventions() {
        var randomIndex1: Int
        var randomIndex2: Int
        var randomIndex3: Int
        var randomIndex4: Int
        randomIndex1 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention1.invention = listOfInventions[randomIndex1]
        listOfInventions.removeAtIndex(randomIndex1)
        randomInvention1.index = 0
        randomIndex2 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention2.invention = listOfInventions[randomIndex2]
        randomInvention2.index = 1
        listOfInventions.removeAtIndex(randomIndex2)
        randomIndex3 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention3.invention = listOfInventions[randomIndex3]
        listOfInventions.removeAtIndex(randomIndex3)
        randomIndex4 = GKRandomSource.sharedRandom().nextIntWithUpperBound(listOfInventions.count)
        randomInvention4.invention = listOfInventions[randomIndex4]
        listOfInventions.removeAtIndex(randomIndex4)
        
        setOfInventions.append(randomInvention1); setOfInventions.append(randomInvention2); setOfInventions.append(randomInvention3); setOfInventions.append(randomInvention4)
        setOfInventionsInOrder.append(randomInvention1); setOfInventions.append(randomInvention2); setOfInventions.append(randomInvention3); setOfInventions.append(randomInvention4)
        setOfInventionsInOrder.sortInPlace({$0.invention.year < $1.invention.year})
    }
    
    func displaySetOfInventions() {
        getListOfInventions()
        resetTimer()
        beginTimer()
        disableURLEvents()
        TimerLabel.hidden = false
        TimerLabel.titleLabel?.text = "0:\(timeLeft)"
        InformationLabel.text = "\(setOfInventions.count)"
        InventionListed1.setTitle(setOfInventions[0].invention.event, forState: .Normal)
        InventionListed2.setTitle(setOfInventions[1].invention.event, forState: .Normal)
        InventionListed3.setTitle(setOfInventions[2].invention.event, forState: .Normal)
        InventionListed4.setTitle(setOfInventions[3].invention.event, forState: .Normal)
        
        if roundsPlayed == roundsPerGame {
            gameOver()
        }
    }
    
    func swapInventions(firstInvention: RandomInvention, secondInvention: RandomInvention) {
        let firstInventionIndex = firstInvention.index
        let secondInventionIndex = secondInvention.index
        
        swap(&setOfInventions[firstInventionIndex], &setOfInventions[secondInventionIndex])
    }
    
    func checkAnswer() {
        timer.invalidate()
        roundsPlayed += 1
        TimerLabel.hidden = true
        enableURLEvents()
        breakListOfInventions()
        
        if setOfInventions[0].index == setOfInventionsInOrder[0].index && setOfInventions[1].index == setOfInventionsInOrder[1].index && setOfInventions[2].index == setOfInventionsInOrder[2].index && setOfInventions[3].index == setOfInventionsInOrder[3].index {
            self.InformationLabel.text = "Tap an event to learn more"
            self.roundsCorrect += 1
            self.playCorrectSound()
        } else {
            self.InformationLabel.text = "Tap an event to learn more"
            self.playIncorrectSound()
        }
    }
    
    func gameOver() {
        // MARK: End game
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Welcome to Bout Time!", message: "In this game, you are given a list of inventions which you have to sort by the order of the invention, oldest on top. You have 6 rounds.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: dismissAlert)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert(sender: UIAlertAction) {
        displaySetOfInventions()
    }
    
    func enableURLEvents() {
        InventionListed1.enabled = true
        InventionListed2.enabled = true
        InventionListed3.enabled = true
        InventionListed4.enabled = true
    }
    
    func disableURLEvents() {
        InventionListed1.enabled = false
        InventionListed2.enabled = false
        InventionListed3.enabled = false
        InventionListed4.enabled = false
    }
    
    func beginTimer() {
        if timerRunning == false {
            counter = 60
            timeLeft = 60
            timerRunning = true
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func updateTimer() {
        timeLeft -= 1
        TimerLabel.titleLabel?.text = "0:\(timeLeft)"
        
        if timeLeft == 0 {
            timer.invalidate()
            checkAnswer()
        }
        
        if timeLeft <= 9 {
            TimerLabel.titleLabel?.text = "0:0\(timeLeft)"
        }
    }
    
    func resetTimer() {
        timeLeft = 45
        counter = 45
        timerRunning = false
    }
    
    func breakListOfInventions() {
        setOfInventions.removeAll()
        setOfInventionsInOrder.removeAll()
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