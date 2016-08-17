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
import SafariServices

class ViewController: UIViewController {
    
    // Game Mechanics
    var listOfInventions: [Invention] = []
    var roundsPlayed = 0
    var roundsCorrect = 0
    let totalRounds = 6
    var setOfInventions: [Invention] = []
    var setOfInventionsInOrder: [Invention] = []
    var copyOfListOfInventions: [Invention] = []
    var randomInvention1 = Invention(event: "", year: 0, url: "")
    var randomInvention2 = Invention(event: "", year: 0, url: "")
    var randomInvention3 = Invention(event: "", year: 0, url: "")
    var randomInvention4 = Invention(event: "", year: 0, url: "")
    let successImage = UIImage(named: "next_round_success")
    let failImage = UIImage(named: "next_round_fail")
    var alertHasShown = false
    var newGame = false
    
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
    @IBOutlet weak var View1Down: UIButton!
    @IBOutlet weak var View2Up: UIButton!
    @IBOutlet weak var View2Down: UIButton!
    @IBOutlet weak var View3Up: UIButton!
    @IBOutlet weak var View3Down: UIButton!
    @IBOutlet weak var View4Up: UIButton!
    
    // Collect the data from the plist and store it in an array
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
    
    // Pre-load game Sounds/Set up UI
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCorrectSound()
        loadIncorrectSound()
        setupAppUI()
    }
    
    // When the view pops up
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Show the alert and reset the timer
        showAlert()
        resetTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Connect the score mechanics between the two segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameOver" {
            if let controller = segue.destinationViewController as? GameOverController {
                controller.roundsCorrect = self.roundsCorrect
                controller.roundsPlayed = self.roundsPlayed
            }
        }
    }
    
    // Enable portrait mode only.
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Enable app for motion detection
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
        swapInventions(&setOfInventions[0], secondInvention: &setOfInventions[1])
    }
    @IBAction func View2Up(sender: UIButton) {
        swapInventions(&setOfInventions[1], secondInvention: &setOfInventions[0])
    }
    @IBAction func View2Down(sender: UIButton) {
        swapInventions(&setOfInventions[1], secondInvention: &setOfInventions[2])
    }
    @IBAction func View3Up(sender: UIButton) {
        swapInventions(&setOfInventions[2], secondInvention: &setOfInventions[1])
    }
    @IBAction func View3Down(sender: UIButton) {
        swapInventions(&setOfInventions[2], secondInvention: &setOfInventions[3])
    }
    @IBAction func View4Up(sender: UIButton) {
        swapInventions(&setOfInventions[3], secondInvention: &setOfInventions[2])
    }
    
    // Next round button
    @IBAction func PlayNextRound(sender: AnyObject) {
        // Get new list of inventions, reset and start the timer, and display the list of inventions
        breakSetOfInventions()
        getListOfInventions()
        displaySetOfInventions()
        self.TimerLabel.setBackgroundImage(nil, forState: .Normal)
    }
    
    // When a round is over, click on an invention to pull up a Wikipedia page with SafariViewController
    @IBAction func Invention1URL(sender: UIButton) {
        let sfViewController = SFSafariViewController(URL: NSURL(string: setOfInventions[0].url)!, entersReaderIfAvailable: true)
        self.presentViewController(sfViewController, animated: true, completion: nil)
    }
    @IBAction func Invention2URL(sender: UIButton) {
        let sfViewController = SFSafariViewController(URL: NSURL(string: setOfInventions[1].url)!, entersReaderIfAvailable: true)
        self.presentViewController(sfViewController, animated: true, completion: nil)
    }
    @IBAction func Invention3URL(sender: UIButton) {
        let sfViewController = SFSafariViewController(URL: NSURL(string: setOfInventions[2].url)!, entersReaderIfAvailable: true)
        self.presentViewController(sfViewController, animated: true, completion: nil)
    }
    @IBAction func Invention4URL(sender: UIButton) {
        let sfViewController = SFSafariViewController(URL: NSURL(string: setOfInventions[3].url)!, entersReaderIfAvailable: true)
        self.presentViewController(sfViewController, animated: true, completion: nil)
    }
    
    // Round edges and reset text box in each invention view
    func setupAppUI() {
        View1.layer.cornerRadius = 5
        View2.layer.cornerRadius = 5
        View3.layer.cornerRadius = 5
        View4.layer.cornerRadius = 5
        
        InventionListed1.setTitle(nil, forState: .Normal)
        InventionListed2.setTitle(nil, forState: .Normal)
        InventionListed3.setTitle(nil, forState: .Normal)
        InventionListed4.setTitle(nil, forState: .Normal)
    }
    
    // Get a random set of inventions. This function runs once every round.
    func getListOfInventions() {
        var randomIndex1: Int
        var randomIndex2: Int
        var randomIndex3: Int
        var randomIndex4: Int
        
        // Get a random number, assign the first random invention with the listOfInventions[randomIndex], and repeat the process with every random invention
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
        
        // If the game is over...
        if roundsPlayed == 6 {
            // Show your score in a new controller and reset the game data
            presentGameOverController()
            roundsPlayed = 0
            roundsCorrect = 0
        // Else if the game hasn't started
        } else if roundsPlayed == 0 {
            // Refresh the list of inventions
            listOfInventions = copyOfListOfInventions
        }
        
        // Create two arrays, one with the inventions and one with the inventions in order.
        setOfInventions.append(randomInvention1); setOfInventions.append(randomInvention2); setOfInventions.append(randomInvention3); setOfInventions.append(randomInvention4)
        setOfInventionsInOrder.append(randomInvention1); setOfInventionsInOrder.append(randomInvention2); setOfInventionsInOrder.append(randomInvention3); setOfInventionsInOrder.append(randomInvention4)
        setOfInventionsInOrder.sortInPlace({$0.year < $1.year})
        
        // Prepare the round for use
        resetTimer()
        beginTimer()
        TimerLabel.setTitle("0:\(timeLeft)", forState: .Normal)
        InformationLabel.text = "Shake to Complete"
        disableURLEvents()
        enableSwapButtons()
        hideNextRoundButtons()
    }
    
    // Show the inventions in the views
    func displaySetOfInventions() {
        InventionListed1.setTitle(setOfInventions[0].event, forState: .Normal)
        InventionListed2.setTitle(setOfInventions[1].event, forState: .Normal)
        InventionListed3.setTitle(setOfInventions[2].event, forState: .Normal)
        InventionListed4.setTitle(setOfInventions[3].event, forState: .Normal)
    }
    
    // Take two inventions and swap their order in the setOfInventions array
    func swapInventions(inout firstInvention: Invention, inout secondInvention: Invention) {
        let tempFirstInvention = firstInvention
        firstInvention = secondInvention
        secondInvention = tempFirstInvention
        // Update the display
        displaySetOfInventions()
    }

    // Check the answer
    func checkAnswer() {
        // Set up game for answer viewing
        timer.invalidate()
        TimerLabel.enabled = true
        TimerLabel.setTitle("", forState: .Normal)
        roundsPlayed += 1
        TimerLabel.enabled = true
        enableURLEvents()
        disableSwapButtons()
        
        // If the order of the inventions in the two arrays are identical (the answer is correct)...
        if setOfInventions[0].event == setOfInventionsInOrder[0].event && setOfInventions[1].event == setOfInventionsInOrder[1].event && setOfInventions[2].event == setOfInventionsInOrder[2].event && setOfInventions[3].event == setOfInventionsInOrder[3].event {
            // Show the user they got the answer correct
            self.InformationLabel.text = "Tap an event to learn more"
            self.roundsCorrect += 1
            self.playCorrectSound()
            self.TimerLabel.setBackgroundImage(successImage, forState: .Normal)
        } else {
            // Show the user they got the answer incorrect
            self.InformationLabel.text = "Tap an event to learn more"
            self.playIncorrectSound()
            self.TimerLabel.setBackgroundImage(failImage, forState: .Normal)
        }
    }
    
    // Create a new alert that gives the player instructions on how to play the game. This function will only be called when the game loads.
    func showAlert() {
        if alertHasShown == false {
            alertHasShown = true
            let alertController = UIAlertController(title: "Welcome to Bout Time!", message: "In this game, you are given a list of inventions which you have to sort by the order of the invention, oldest on top. You have 6 rounds.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: dismissAlert)
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Show the player their score in a new view controller
    func presentGameOverController() {
        self.performSegueWithIdentifier("gameOver", sender: self)
    }
    
    // Begin the game when the user taps "OK" on the alert
    func dismissAlert(sender: UIAlertAction) {
        getListOfInventions()
        displaySetOfInventions()
    }
    
    // MARK: Helper methods
    
    // Allow the player to view the inventions in a web browser
    func enableURLEvents() {
        InventionListed1.enabled = true
        InventionListed2.enabled = true
        InventionListed3.enabled = true
        InventionListed4.enabled = true
    }
    
    // Don't allow the player to view the inventions in a web browser
    func disableURLEvents() {
        InventionListed1.enabled = false
        InventionListed2.enabled = false
        InventionListed3.enabled = false
        InventionListed4.enabled = false
    }
    
    // Allow the player to swap the inventions
    func enableSwapButtons() {
        View1Down.enabled = true
        View2Up.enabled = true
        View2Down.enabled = true
        View3Up.enabled = true
        View3Down.enabled = true
        View4Up.enabled = true
    }
    
    // Don't allow the player to swap the inventions
    func disableSwapButtons() {
        View1Down.enabled = false
        View2Up.enabled = false
        View2Down.enabled = false
        View3Up.enabled = false
        View3Down.enabled = false
        View4Up.enabled = false
    }
    
    // Show the normal timer
    func hideNextRoundButtons() {
        TimerLabel.setImage(nil, forState: .Normal)
        TimerLabel.hidden = false
        TimerLabel.enabled = false
    }
    
    // Start the timer
    func beginTimer() {
        if timerRunning == false {
            counter = 60
            timeLeft = 60
            timerRunning = true
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    // Update the timer every second
    func updateTimer() {
        timeLeft -= 1
        TimerLabel.setTitle("0:\(timeLeft)", forState: .Normal)
        
        // If the timer runs out of time
        if timeLeft == 0 {
            // Stop the timer and check the answer
            timer.invalidate()
            checkAnswer()
            TimerLabel.setTitle("", forState: .Normal)
        }
        
        // Make the timer look regular with one digit of time left
        if timeLeft <= 9 && timeLeft >= 1 {
            TimerLabel.setTitle("0:0\(timeLeft)", forState: .Normal)
        }
    }
    
    // Reset the timer's properties
    func resetTimer() {
        timeLeft = 60
        counter = 60
        timerRunning = false
    }
    
    // Break the set of Inventions
    func breakSetOfInventions() {
        setOfInventions.removeAll()
        setOfInventionsInOrder.removeAll()
    }
    
    // Load both the correct and incorrect sounds for the game. Also create functions to play the sounds.
    
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