//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей on 22.08.2022.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int // кол-во правильных ответов
    let total: Int // кол-во вопросов квиза
    let date: Date // дата завершения раунда
    func isNewRecord(current:Int) -> Bool {
        return current > self.correct
    }
}
protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    var totalAccuracy: Double = 0.0
    var gamesCount: Int = 0
    
    private (set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        if self.bestGame.isNewRecord(current: count){
            self.bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
        gamesCount += 1
        totalAccuracy = (totalAccuracy + Double(count)/Double(amount)) / Double(gamesCount)
    }
    
}
