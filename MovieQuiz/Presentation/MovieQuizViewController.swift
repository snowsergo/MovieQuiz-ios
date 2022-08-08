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
    private var quizeCount: Int = 0
    private var totalRightAnswerCount: Int = 0
    private var answersRecord: Int = 0
    private var recordDate: Date = Date()
    
//    let dateFormatterGet = NSDateFormatter()
//    dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"“
//    dateformater.dateformat = "dd.MM.yy"
    
    private let questions: [QuizeQuestion] = [
    QuizeQuestion(image: "Deadpool_000", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizeQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizeQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizeQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizeQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private func showStep(quize step: QuizeStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResult(quize result: QuizeResultsViewModel) {
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: result.buttonText,
            style: .default, handler: { _ in
            self.currentQuestionIndex = 0
            self.rigthAnswerCount = 0
            self.showStep(quize: self.convertQuestionToQuestionStepModel(model: self.questions[0]))
        })
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    private func convertQuestionToQuestionStepModel(model: QuizeQuestion) -> QuizeStepViewModel {
        return QuizeStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
        movieImageView.layer.borderWidth = 8
        movieImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            rigthAnswerCount += 1
        }
    }
    private func getResultMessage() -> String {
        let formater = DateFormatter()
        formater.dateFormat = "dd.MM.yyyy hh:mm"
        let result: String = "Ваш результат: \(rigthAnswerCount)/\(questions.count)."
        let quize: String = "Количество сыгранных квизов: \(quizeCount)."
        let record: String = "Рекорд: \(answersRecord)/\(questions.count) (\(formater.string(from: recordDate)))."
        let percent = (Double(totalRightAnswerCount) / Double(quizeCount * questions.count) * 10000).rounded() / 100
        let statistic: String = "Средняя точность: \(percent)%."
        return result + "\n" + quize + "\n" + record + "\n" + statistic
    }
    private func showNextQuestionOrResults() {
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.borderWidth = 0
        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
        if currentQuestionIndex == questions.count - 1 {
            if quizeCount == 0 || rigthAnswerCount > answersRecord {
                answersRecord = rigthAnswerCount
                recordDate = Date()
            }
            totalRightAnswerCount += self.rigthAnswerCount
            quizeCount += 1
            showResult(quize: QuizeResultsViewModel(
                title: "Этот раунд окончен",
                text: getResultMessage(),
                buttonText: "Сыграть еще раз"
            )
            )
        } else {
            currentQuestionIndex += 1
            showStep(quize: convertQuestionToQuestionStepModel(model: questions[currentQuestionIndex]))
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showNextQuestionOrResults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.cornerRadius = 20
        showStep(quize: convertQuestionToQuestionStepModel(model: questions[currentQuestionIndex]))
    }
}
