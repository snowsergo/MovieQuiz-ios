//
//  ResultAlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Сергей on 19.08.2022.
//

import Foundation
protocol ResultAlertPresenterProtocol {
    var title: String { get }
    var text: String { get }
    var buttonText: String { get }
    func showResult(callback: @escaping () -> Void)
}
