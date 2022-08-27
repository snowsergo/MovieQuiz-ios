import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var resultAlertPresenter: ResultAlertPresenterProtocol?
    private var currentQuestionIndex: Int = 0
    private var rightAnswerCount: Int = 0
    private var quizeCount: Int = 0
    private var totalRightAnswerCount: Int = 0
    private var answersRecord: Int = 0
    private var recordDate: Date = Date()
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true

        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Невозможно загрузить данные",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Попробовать еще раз",
            style: .default, handler: {_ in
                self.questionFactory?.loadData()
            })
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    private func showStep(quize step: QuizStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func createStepModel(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
//            image: UIImage(named: model.image) ?? UIImage(),
            image: UIImage(data: model.image) ?? UIImage.checkmark,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func showAnswerResult(isCorrect: Bool) {
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
        movieImageView.layer.borderWidth = 8
        movieImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            rightAnswerCount += 1
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

    private func startNewQuiz() -> Void  {
        self.currentQuestionIndex = 0
        self.rightAnswerCount = 0
        self.questionFactory?.requestNextQuestion()
    }
    private func showNextQuestionOrResults() {
        movieImageView.layer.borderWidth = 0
        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: rightAnswerCount, total: questionsAmount)
            totalRightAnswerCount += self.rightAnswerCount
            quizeCount += 1
            resultAlertPresenter = ResultAlertPresenter(
                title: "Этот раунд окончен",
                text: getResultMessage(),
                buttonText: "Сыграть еще раз",
                controller: self
            )
            resultAlertPresenter?.showResult(callback: startNewQuiz)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.showNextQuestionOrResults()
        }
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.showNextQuestionOrResults()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.cornerRadius = 20
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        questionFactory?.loadData()
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
            }
            currentQuestion = question
            let viewModel = createStepModel(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showStep(quize: viewModel)
        }
    }

    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
