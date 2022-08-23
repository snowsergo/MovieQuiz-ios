//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей on 19.08.2022.
//
import UIKit
import Foundation

class ResultAlertPresenter: ResultAlertPresenterProtocol  {
    var title: String
    var text: String
    var buttonText: String
    var controller: UIViewController
    
    init(title: String, text: String, buttonText: String, controller: UIViewController) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.controller = controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func showResult(callback: @escaping () -> Void) {
//        noButton.isUserInteractionEnabled = false
//        yesButton.isUserInteractionEnabled = false
        let alert = UIAlertController(
            title: self.title,
            message: self.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: self.buttonText,
            style: .default, handler: {_ in
            callback()
            })
        alert.addAction(action)

        controller.present(alert, animated: true, completion: nil)
    }
}
