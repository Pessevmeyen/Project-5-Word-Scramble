//
//  ViewController.swift
//  Project5
//
//  Created by Furkan Eruçar on 31.03.2022.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]() // We’re going to use the first one to hold all the words in the input file
    var usedWords = [String]() // and the second one will hold all the words the player has currently used in the game.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer)) // That created a new UIBarButtonItem using the "add" system item, and configured it to run a method called promptForAnswer() when tapped
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") { // Finding a path to a file is something you'll do a lot, because even though you know the file is called "start.txt" you don't know where it might be on the filesystem. So, we use a built-in method of Bundle to find it: path(forResource:). This takes as its parameters the name of the file and its path extension, and returns a String? – i.e., you either get the path back or you get nil if it didn’t exist. Before we get onto the code, there are two things you should know: path(forResource:) and creating a String from the contents of a file both return String?, which means we need to check and unwrap the optional using if let syntax. Bunun anlamı Bundle'da ne aradığımızı bulduk ve aşağıda onu yükleyeceğiz.
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n") // we need to split our single string into an array of strings based on wherever we find a line break (\n). This is as simple as another method call on String: components(separatedBy:). Tell it what string you want to use as a separator (for us, that's \n), and you'll get back an array.
            }
        }
        
        if allWords.isEmpty { // Eğer start words url'i bulamazsak bu olsun
            allWords = ["silkworm"]
        }
        
        startGame()
        
        
        
    }
    
    
    func startGame() {
        title = allWords.randomElement() // sets our view controller's title to be a random word in the array, which will be the word the player has to find.
        usedWords.removeAll(keepingCapacity: true) // removes all values from the usedWords array, which we'll be using to store the player's answers so far. We aren't adding anything to it right now, so removeAll() won't do anything just yet.
        tableView.reloadData() // is the interesting part: "it calls the reloadData() method of tableView". That table view is given to us as a property because our ViewController class comes from UITableViewController, and calling reloadData() forces it to call numberOfRowsInSection again, as well as calling cellForRowAt repeatedly. Our table view doesn't have any rows yet, so this won't do anything for a few moments.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert) // yukarda çıkan eklediğimiz + butonuna tıklayınca ne olacağını gösteriyor.
        ac.addTextField() // The addTextField() method just adds an editable text input field to the UIAlertController. // kullanıcıdan text alıyoruz.
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction) // The addAction() method is used to add a UIAlertAction to a UIAlertController. We used this in project 2 also.
        present(ac, animated: true)
        
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }


}

