//
//  ViewController.swift
//  Ind02_Pathem_SaiVishwas
//
//  Created by Sai Vishwas Pathem on 2/24/24.
//

import UIKit

// Struct to record an image's center position and a boolean value to track a blank image
struct ImageCoordinates{
    
    var x: CGFloat
    var y: CGFloat
    var isValid: Bool
    
}

class ViewController: UIViewController {
    
    var imageTiles: [UIImageView] = [] // Array for all the image tiles on screen
    
    var tileState: [UIImageView] = [] // Array to keep track of current position of image tiles when they are moved
    
    var originalPositions: [CGPoint] = [] // Array that tracks the coordinates of original position of image tiles
    
    var updatedPositions: [CGPoint] = [] // Array to hold updated position of all the images
    
    var blankTile: UIImageView! // ImageView of the blank image tile
    
    var isScreenLocked: Bool = true // Boolean variable to block user clicking on image tiles when they click show answer button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load all the image tiles and store their center positions in an array
        
        var xMid = 67
        var yMid = 200
        var x = 1
        for _ in 0...4 {
            for _ in 0...3 {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tileTapped))
                let imageView = UIImageView(frame: CGRect(x: xMid, y: yMid, width: 93, height: 93))
                imageView.image = UIImage(named: "\(x).jpg")
                let centerPoint = CGPoint(x: xMid, y: yMid)
                originalPositions.append(centerPoint)
                imageView.center = centerPoint
                imageView.addGestureRecognizer(tapRecognizer)
                imageView.isUserInteractionEnabled = true
                imageTiles.append(imageView)
                view.addSubview(imageView)
                xMid += 93
                x += 1
            }
            xMid = 67
            yMid += 93
        }
        
        tileState = imageTiles
        blankTile = imageTiles[0]
    }

    // Tap gesture functionality for each image tile
    @objc func tileTapped(_ sender: UITapGestureRecognizer) {
        // Check if the tapped view is not the blank image tile and if the screen is not locked
        if sender.view != blankTile && isScreenLocked {
            // Get updated coordinates for the tapped image tile
            let result: ImageCoordinates = updatedCoordinates(sender.view as! UIImageView)
            
            // Check if the updated coordinates are valid for swapping the image tiles
            if result.isValid {
                // Swap the empty image tile with the image tile touched by user in its adjacent position
                swapTiles(currentTile: sender.view as! UIImageView)
                
                // Check if the puzzle is solved or not
                if isPuzzleSolved() {
                    // Create a new alert to show if the puzzle is solved
                    let dialogMessage = UIAlertController(title: "Solved", message: "Click Ok to Play Again!!", preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    })
                    
                    // Add OK button to the dialog message
                    dialogMessage.addAction(ok)
                    
                    // Present the alert to the user
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }

    // Function to swap the image tiles with the blank image tile
    func swapTiles(currentTile: UIImageView) {
        // Get the index of blank image tile and the image tile to be swapped
        guard let i = tileState.firstIndex(of: blankTile),
              let j = tileState.firstIndex(of: currentTile)
        else {
            return
        }
        
        // Swap the positions of the image tiles
        let tempCenter = blankTile.center
        blankTile.center = currentTile.center
        currentTile.center = tempCenter
        
        // Swap the image tiles in the tileState array
        tileState.swapAt(i, j)
        
        // Animate the swapping of image tiles
        UIView.transition(with: currentTile, duration: 0.25, options: .transitionFlipFromRight, animations: {}, completion: nil)
    }
    
    // Fetching the coordinates of image tiles that are tapped
    func updatedCoordinates(_ view: UIImageView) -> ImageCoordinates {
        let currentGridX = view.frame.origin.x
        let currentGridY = view.frame.origin.y
        
        let currentGridXLeft = currentGridX - 93
        let currentGridYLeft = currentGridY
        
        let currentGridXRight = currentGridX + 93
        let currentGridYRight = currentGridY
        
        let upGridXPosition = currentGridX
        let upGridYPosition = currentGridY - 93
        
        let downGridXPosition = currentGridX
        let downGridYPosition = currentGridY + 93
        
        if (currentGridXLeft == blankTile.frame.origin.x && currentGridYLeft == blankTile.frame.origin.y) {
            return ImageCoordinates(x: currentGridXLeft, y: currentGridYLeft, isValid: true)
        }
        if (currentGridXRight == blankTile.frame.origin.x && currentGridYRight == blankTile.frame.origin.y) {
            return ImageCoordinates(x: currentGridXRight, y: currentGridYRight, isValid: true)
        }
        if (upGridXPosition == blankTile.frame.origin.x && upGridYPosition == blankTile.frame.origin.y) {
            return ImageCoordinates(x: upGridXPosition, y: upGridYPosition, isValid: true)
        }
        if (downGridXPosition == blankTile.frame.origin.x && downGridYPosition == blankTile.frame.origin.y) {
            return ImageCoordinates(x: downGridXPosition, y: downGridYPosition, isValid: true)
        }
        return ImageCoordinates(x: downGridXPosition, y: downGridYPosition, isValid: false)
    }

    // Shuffle functionality to shuffle all the image tiles
    @IBAction func shuffleTiles(_ sender: Any) {
        let randomShuffleCount = Int.random(in: 10..<25)
        
        for _ in 0..<randomShuffleCount {
            let currentTile = shuffleTilesAdjacentToBlank()
            swapTiles(currentTile: currentTile)
        }
    }
    
    // Function to get the randomised image tiles on screen
    func shuffleTilesAdjacentToBlank() -> UIImageView {
        var validTiles: [UIImageView] = []
        let emptyTileXPosition = blankTile.frame.origin.x
        let emptyTileYPosition = blankTile.frame.origin.y
        
        let leftTilePosition = CGPoint(x: emptyTileXPosition - 93, y: emptyTileYPosition)
        let rightTilePosition = CGPoint(x: emptyTileXPosition + 93, y: emptyTileYPosition)
        let upTilePosition = CGPoint(x: emptyTileXPosition, y: emptyTileYPosition - 93)
        let downTilePosition = CGPoint(x: emptyTileXPosition, y: emptyTileYPosition + 93)
        
        for index in 0..<imageTiles.count {
            if imageTiles[index].frame.origin == leftTilePosition || imageTiles[index].frame.origin == rightTilePosition ||
                imageTiles[index].frame.origin == upTilePosition || imageTiles[index].frame.origin == downTilePosition {
                validTiles.append(imageTiles[index])
            }
        }
        
        guard let randomTile = validTiles.randomElement() else {
            fatalError("There are no valid tiles to shuffle.")
        }
        return randomTile
    }

    // Function to save the current positions of image tiles
    func saveCurrentState() {
        for i in 0..<tileState.count {
            updatedPositions.append(tileState[i].center)
        }
    }
    
    // Show answer button functionality to display the original image in the image tiles
    @IBAction func showAnswer(_ sender: Any) {
        if let title = (sender as AnyObject).titleLabel?.text {
            if title == "Show Answer" {
                isScreenLocked = false
                saveCurrentState()
                
                for i in 0..<imageTiles.count {
                    imageTiles[i].center = originalPositions[i]
                }
                (sender as AnyObject).setTitle("Hide", for: .normal)
            } else if title == "Hide" {
                for i in 0..<imageTiles.count {
                    if i < updatedPositions.count {
                        tileState[i].center = updatedPositions[i]
                    }
                }
                (sender as AnyObject).setTitle("Show Answer", for: .normal)
                isScreenLocked = true
                updatedPositions = []
            }
        }
    }
    
    // Function to check if puzzle is solved or not
    func isPuzzleSolved() -> Bool {
        for i in 0..<imageTiles.count {
            if tileState[i] != imageTiles[i] {
                return false
            }
        }
        return true
    }
}
