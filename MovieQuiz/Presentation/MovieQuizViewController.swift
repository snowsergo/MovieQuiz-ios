import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    private var presenter: MovieQuizPresenter!
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showStep(quize step: QuizStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func showAnswerResult(isCorrect: Bool) {
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
        movieImageView.layer.borderWidth = 8
        movieImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            self.presenter.incrementRigthAnswerCount()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.movieImageView.layer.borderWidth = 0
            self.movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
            self.presenter.showNextQuestionOrResults()
        }
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }

        @IBAction private func yesButtonClicked(_ sender: Any) {
            presenter.yesButtonClicked()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.cornerRadius = 20
        showLoadingIndicator()
    }
}
