//
//  main.swift
//  3D 2048 Command Line
//
//  Created by Andrew Palombo on 02/01/2021.
//

import Foundation

enum Direction: CaseIterable {
	case none
	case left
	case right
	case inFront
	case behind
	case above
	case below
}

func playGame() {
	print("Welcome to 3D 2048 Command Line")
	let game = GameModel()
	var playing = true
	var valid = false
	while !valid {
		print("Enter to start or (q)uit >>> ")
		let response = readLine()!
		if response == "" {
			valid = true
		} else if response == "q" {
			valid = true
			playing = false
		}
	}
	while playing {
		let newTiles = game.newGame()
		game.printMatrix()
		var askedToQuitAfterWin = false
		game:
		while !game.gameOver {
			var directionKey = ""
			var valid = false
			while !valid {
				print("Enter move wasdqe (q/e = up/down) >>> ")
				let response = readLine()!
				if ["w", "a", "s", "d", "q", "e"].contains(response) {
					valid = true
					directionKey = response
				} else if response == ":q" {
					break game
				}
			}
			var userDirection: Direction = .none
			switch directionKey {
			case "w":
				userDirection = .behind
			case "a":
				userDirection = .left
			case "s":
				userDirection = .inFront
			case "d":
				userDirection = .right
			case "q":
				userDirection = .above
			case "e":
				userDirection = .below
			default:
				break
			}
			let moveResults = game.playMove(userDirection: userDirection)
			if moveResults.translations.isEmpty {
				print("Move had no effect.")
			}
			game.printMatrix()
			print("Moves: \(game.moves)")
			print("Score: \(game.score)")
			if game.gameWon && !askedToQuitAfterWin {
				askedToQuitAfterWin = true
				print("Congratulations, you win!")
				valid = false
				while !valid {
					print("Continue y/n? >>> ")
					let response = readLine()!
					if response == "y" {
						valid = true
					} else if response == "n" {
						valid = true
						break game
					}
				}
			}
			if game.gameOver {
				print("Game over.")
			}
		}
		var valid = false
		while !valid {
			print("Play again y/n")
			let response = readLine()!
			if response == "y" {
				valid = true
			} else if response == "n" {
				valid = true
				playing = false
			}
		}
	}
	print("Quitting...")
}

playGame()
