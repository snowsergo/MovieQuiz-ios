import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    let moviesLoader = MoviesLoader()
    var questionFactory: QuestionFactoryProtocol?
    var rightAnswerCount: Int = 0
    private var resultAlertPresenter: ResultAlertPresenterProtocol?

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

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return

        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
     }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func requestQuestion() {
        self.questionFactory?.requestNextQuestion()
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            resultAlertPresenter = ResultAlertPresenter(
                title: "Что-то пошло не так",
                text: "Не удалось загрузить вопрос",
                buttonText: "Попробовать еще раз",
                controller: viewController!
            )
            resultAlertPresenter?.showAlert(callback: requestQuestion)
            return
        }
        currentQuestion = question
        let viewModel = createStepModel(model: question)
        viewController?.hideLoadingIndicator()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showStep(quize: viewModel)
        }
    }
    private func getResultMessage() -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd.MM.yyyy hh:mm"
        let result: String = "Ваш результат: \(rightAnswerCount)/\(questionsAmount)."
        let quize: String = "Количество сыгранных квизов: \(statisticService.gamesCount)."
        let record: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let statistic: String = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        return result + "\n" + quize + "\n" + record + "\n" + statistic
    }

    private func startNewQuiz() {
//        self.currentQuestionIndex = 0
        resetQuestionIndex()
        rightAnswerCount = 0
        questionFactory?.requestNextQuestion()
    }
    func showNextQuestionOrResults() {
//        movieImageView.layer.borderWidth = 0
//        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
        if self.isLastQuestion() {
            statisticService.store(correct: rightAnswerCount, total: questionsAmount)
            resultAlertPresenter = ResultAlertPresenter(
                title: "Этот раунд окончен",
                text: getResultMessage(),
                buttonText: "Сыграть еще раз",
                controller: viewController!
            )
            resultAlertPresenter?.showAlert(callback: startNewQuiz)
        } else {
//            currentQuestionIndex += 1
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
