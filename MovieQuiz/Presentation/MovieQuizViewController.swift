import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate,ResultAlertPresenterDelegate {
  
    // MARK: - Lifecycle
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    enum CodingKeys: CodingKey {
       case id, title, year, image, releaseDate, runtimeMins, directors, actorList
     }
    struct Actor: Codable {
        let id: String
        let image: String
        let name: String
        let asCharacter: String
    }
    
    struct Movie: Codable {
        let id: String
        let title: String
        let year: Int
        let image: String
       // let releaseDate: String
      //  let runtimeMins: Int
      //  let directors: String
      //  let actorList: [Actor]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            let year = try container.decode(String.self, forKey: .year)
            self.year = Int(year)!
            image = try container.decode(String.self, forKey: .image)
         //   releaseDate = try container.decode(String.self, forKey: .releaseDate)
        //    let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        //    self.runtimeMins = Int(runtimeMins)!
        //    directors = try container.decode(String.self, forKey: .directors)
         //   actorList = try container.decode([Actor].self, forKey: .actorList)
        }
    }
    
    struct Top: Decodable {
        let items: [Movie]
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
    
    private func showStep(quize step: QuizStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func createStepModel(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
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
//        let record: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(formater.string(from: statisticService.bestGame.date ?? Date())))."
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
//            if quizeCount == 0 || rightAnswerCount > answersRecord {
//                answersRecord = rightAnswerCount
//                recordDate = Date()
//            }
            totalRightAnswerCount += self.rightAnswerCount
            quizeCount += 1
            resultAlertPresenter = ResultAlertPresenter(
                title:"Этот раунд окончен", text:getResultMessage(),
                buttonText:"Сыграть еще раз",
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
//        let statisticService: StatisticService = StatisticServiceImplementation()
//        statisticService = StatisticServiceImplementation()
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        print("====")
//        print(documentsURL)
//        print("====")
        let fileName = "top.json"
        documentsURL.appendPathComponent(fileName)
        var fileExist = FileManager.default.fileExists(atPath: documentsURL.path)
        print("fileExist = ", fileExist)
        let jsonString = try? String(contentsOf: documentsURL)
//        print("jsonString = ", jsonString)
//        var data = jsonString.data(using: .utf8)!
        let data = jsonString?.data(using: .utf8) as! Data
        print("data = ",data)
        do {
            let top = try JSONDecoder().decode(Top.self, from: data)
            print("top", top)
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
        }
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self)
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
}
