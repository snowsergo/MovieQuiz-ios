import UIKit

protocol MovieQuizViewControllerProtocol: UIViewController {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func hideImageBorder()
    func showStep(quize step: QuizStepViewModel)
}
