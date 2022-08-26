//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей on 18.08.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    private let moviesLoader: MoviesLoading
    private let delegate: QuestionFactoryDelegate
    init( moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }

    private var movies: [MostPopularMovie] = []

//    private let questions: [QuizQuestion] = [
//    QuizQuestion(image: "Deadpool_000", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//    QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
//    ]
//    func requestNextQuestion() {
//        let index = (0..<questions.count).randomElement() ?? 0
//        let question = questions[safe: index]
//        delegate.didReceiveNextQuestion(question: question)
//    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

           do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating) ?? 0

            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7

            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate.didReceiveNextQuestion(question: question)
            }
        }
    }
    func loadData() {
          moviesLoader.loadMovies { [weak self] result in
              guard let self = self else { return }
              switch result {
              case .success(let mostPopularMovies):
                  DispatchQueue.main.async {
                      self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                      self.delegate.didLoadDataFromServer() // сообщаем, что данные загрузились
                  }

              case .failure(let error):
                  DispatchQueue.main.async {
                      self.delegate.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                  }
              }
          }
      }
}
