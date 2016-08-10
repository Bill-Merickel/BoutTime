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
    var copyOfListOfInventions: [Invention] = []
    var randomInvention1: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention2: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention3: Invention = Invention(event: "", year: 0, url: "")
    var randomInvention4: Invention = Invention(event: "", year: 0, url: "")
    var answer1: String = ""
    var answer2: String = ""
    var answer3: String = ""
    var answer4: String = ""
    
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
    @IBOutlet weak var TimerLabel: UILabel!
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
    @IBOutlet weak var InformationLabel: UILabel!
    
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
        swapInventions(firstPlace: InventionListed1, secondPlace: InventionListed2)
    }
    @IBAction func View2Up(sender: UIButton) {
        swapInventions(firstPlace: InventionListed2, secondPlace: InventionListed1)
    }
    @IBAction func View2Down(sender: UIButton) {
        swapInventions(firstPlace: InventionListed2, secondPlace: InventionListed3)
    }
    @IBAction func View3Up(sender: UIButton) {
        swapInventions(firstPlace: InventionListed3, secondPlace: InventionListed2)
    }
    @IBAction func View3Down(sender: UIButton) {
        swapInventions(firstPlace: InventionListed3, secondPlace: InventionListed4)
    }
    @IBAction func View4Up(sender: UIButton) {
        swapInventions(firstPlace: InventionListed4, secondPlace: InventionListed3)
    }
    
    @IBAction func SuccessNextRound() {
        getListOfInventions()
        displaySetOfInventions()
    }
    @IBAction func FailureNextRound() {
        getListOfInventions()
        displaySetOfInventions()
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
        setOfInventions.sort({$0.year < $1.year})
        
        answer1 = setOfInventions[0].event
        answer2 = setOfInventions[1].event
        answer3 = setOfInventions[2].event
        answer4 = setOfInventions[3].event
    }
    
    func displaySetOfInventions() {
        getListOfInventions()
        resetTimer()
        beginTimer()
        updateTimer()
        hideEndButtons()
        
        TimerLabel.text = "0:\(timeLeft)"
        
        InventionListed1.titleLabel?.text = randomInvention1.event
        InventionListed2.titleLabel?.text = randomInvention2.event
        InventionListed3.titleLabel?.text = randomInvention3.event
        InventionListed4.titleLabel?.text = randomInvention4.event
        
        if roundsPlayed == roundsPerGame {
            gameOver()
        }
    }
    
    func checkAnswer() {
        timer.invalidate()
        roundsPlayed += 1
        TimerLabel.hidden = true
        
        if InventionListed1.titleLabel?.text == answer1 && InventionListed2.titleLabel?.text == answer2 && InventionListed3.titleLabel?.text == answer3 && InventionListed4.titleLabel?.text == answer4 {
            RoundSuccess.hidden = false
            InformationLabel.text = "Tap an event to learn more"
            roundsCorrect += 1
            playCorrectSound()
        } else {
            RoundFailure.hidden = false
            InformationLabel.text = "Tap an event to learn more"
            playIncorrectSound()
        }
    }
    
    func gameOver() {
        // MARK: End game
    }
    
    func swapInventions(firstPlace firstPlace: UIButton, secondPlace: UIButton) {
        let firstInvention = firstPlace.titleLabel?.text
        let secondInvention = secondPlace.titleLabel?.text
        firstPlace.titleLabel?.text = secondInvention
        secondPlace.titleLabel?.text = firstInvention
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
            checkAnswer()
        }
    }
    
    func resetTimer() {
        timeLeft = 45
        counter = 45
        timerRunning = false
        beginTimer()
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