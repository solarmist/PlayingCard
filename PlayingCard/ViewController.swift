//
//  ViewController.swift
//  PlayingCard
//
//  Created by Joshua Olson on 10/5/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for _ in 1...10 {
            if let card = deck.draw() {
                print("\(card)")
            }
        }
    }
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardSclae))
            playingCardView.addGestureRecognizer(swipe)
            playingCardView.addGestureRecognizer(pinch)
        }
    }

    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
            case .ended:
                playingCardView.isFaceUp = !playingCardView.isFaceUp
            default: break
        }
    }
    @objc func nextCard() {
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }


}

