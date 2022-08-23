//
//  QuizFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей on 19.08.2022.
//

import Foundation
protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
