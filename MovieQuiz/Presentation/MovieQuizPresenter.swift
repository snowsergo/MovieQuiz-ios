import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func createStepModel(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage.checkmark,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.viewController?.showNextQuestionOrResults()
        }
    }
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.viewController?.showNextQuestionOrResults()
        }
    }
}
