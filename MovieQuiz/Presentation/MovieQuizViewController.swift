import UIKit

extension UIColor {
    static var ypRed: UIColor { UIColor(named: "YP Red")! }
    static var ypGreen: UIColor { UIColor(named: "YP Green")! }
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    // для состояния "Вопрос задан"
    struct QuizeStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    // для состояния "Результат квиза"
    struct QuizeResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizeQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    private var currentQuestionIndex: Int = 0
    private var rigthAnswerCount: Int = 0
    
    private let questions: [QuizeQuestion] = [
    QuizeQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizeQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
    QuizeQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizeQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textlabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private func showStep(quize step: QuizeStepViewModel) {
        imageView.image = step.image
        textlabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResult(quize result: QuizeResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { _ in
          print("OK button is clicked!")
            self.currentQuestionIndex = 0
            self.rigthAnswerCount = 0
            self.showStep(quize: self.convert(model: self.questions[0]))
        })

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizeQuestion) -> QuizeStepViewModel {
        return QuizeStepViewModel(
            image: UIImage(named: model.image)!,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        if isCorrect {
            rigthAnswerCount += 1
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questions.count - 1 {
            showResult(quize: QuizeResultsViewModel(
                title: "Ваш результат",
                text: rigthAnswerCount == questions.count ? "Вы ответили правильно на все вопросы" : "Вы ответили правильно на \(rigthAnswerCount) вопросов из \(questions.count)",
                buttonText: "Попробовать еще раз"
            )
            )
         } else {
             currentQuestionIndex += 1
             showStep(quize: convert(model: questions[currentQuestionIndex]))
         }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showStep(quize: convert(model: questions[currentQuestionIndex]))
    }
}
