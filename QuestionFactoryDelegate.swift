//
//  QuizFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей on 19.08.2022.
//

import Foundation
protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
