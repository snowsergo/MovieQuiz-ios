//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей on 18.08.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    private let delegate: QuestionFactoryDelegate
    
    private let questions: [QuizQuestion] = [
    QuizQuestion(image: "Deadpool_000", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        let index = (0..<questions.count).randomElement() ?? 0
        let question = questions[safe: index]
        delegate.didReceiveNextQuestion(question: question)                   
    }
}
