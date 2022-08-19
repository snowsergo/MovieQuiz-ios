import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    private var currentQuestionIndex: Int = 0
    private var rightAnswerCount: Int = 0
    private var quizeCount: Int = 0
    private var totalRightAnswerCount: Int = 0
    private var answersRecord: Int = 0
    private var recordDate: Date = Date()
   
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private func showStep(quize step: QuizStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResult(quize result: QuizResultsViewModel) {
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default, handler: {_ in
            self.currentQuestionIndex = 0
            self.rightAnswerCount = 0
//                if let firstQuestion = self.questionFactory.requestNextQuestion() {
//                    self.currentQuestion = firstQuestion
//                    let viewModel = self.createStepModel(model: firstQuestion)
//                    self.showStep(quize: viewModel)
//                }
                
                self.questionFactory.requestNextQuestion { [weak self] question in
                    guard
                        let self = self,
                        let question = question
                    else {
                        // Ошибка
                        return
                    }
                    
                    self.currentQuestion = question
                    let viewModel = self.createStepModel(model: question)
                    DispatchQueue.main.async {
                        self.showStep(quize: viewModel)
                    }
                }
//            self.showStep(quize: self.createStepModel(model: self.questions[0]))
        })
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    private func createStepModel(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
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
        let quize: String = "Количество сыгранных квизов: \(quizeCount)."
        let record: String = "Рекорд: \(answersRecord)/\(questionsAmount) (\(formater.string(from: recordDate)))."
        let percent = (Double(totalRightAnswerCount) / Double(quizeCount * questionsAmount) * 10000).rounded() / 100
        let statistic: String = "Средняя точность: \(percent)%."
        return result + "\n" + quize + "\n" + record + "\n" + statistic
    }
    private func showNextQuestionOrResults() {
        movieImageView.layer.borderWidth = 0
        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
        if currentQuestionIndex == questionsAmount - 1 {
            if quizeCount == 0 || rightAnswerCount > answersRecord {
                answersRecord = rightAnswerCount
                recordDate = Date()
            }
            totalRightAnswerCount += self.rightAnswerCount
            quizeCount += 1
            showResult(quize: QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: getResultMessage(),
                buttonText: "Сыграть еще раз"
            )
            )
        } else {
            currentQuestionIndex += 1
//            if let nextQuestion = questionFactory.requestNextQuestion() {
//                currentQuestion = nextQuestion
//                let viewModel = createStepModel(model: nextQuestion)
//
//                showStep(quize: viewModel)
//            }
            
            questionFactory.requestNextQuestion { [weak self] question in
                guard
                    let self = self,
                    let question = question
                else {
                    // Ошибка
                    return
                }
                
                self.currentQuestion = question
                let viewModel = self.createStepModel(model: question)
                DispatchQueue.main.async {
                    self.showStep(quize: viewModel)
                }
            }
//            currentQuestionIndex += 1
//            showStep(quize: createStepModel(model: questions[currentQuestionIndex]))
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
//        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
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
        //showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
//        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
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
//        if let firstQuestion = questionFactory.requestNextQuestion() {
//            currentQuestion = firstQuestion
//            let viewModel = createStepModel(model: firstQuestion)
//            showStep(quize: viewModel)
//        }
        
        questionFactory.requestNextQuestion { [weak self] question in
            guard
                let self = self,
                let question = question
            else {
                // Ошибка
                return
            }
            
            self.currentQuestion = question
            let viewModel = self.createStepModel(model: question)
            DispatchQueue.main.async {
                self.showStep(quize: viewModel)
            }
        }
        
        //showStep(quize: createStepModel(model: questions[currentQuestionIndex]))
    }
}
