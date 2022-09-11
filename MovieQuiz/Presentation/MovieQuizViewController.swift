import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
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

    func highlightImageBorder(isCorrectAnswer: Bool) {
        movieImageView.layer.borderWidth = 8
        movieImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
    }

    func hideImageBorder() {
        movieImageView.layer.borderWidth = 0
        movieImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.0).cgColor
    }

    func showStep(quize step: QuizStepViewModel) {
        noButton.isUserInteractionEnabled = true
        yesButton.isUserInteractionEnabled = true
        movieImageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
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
