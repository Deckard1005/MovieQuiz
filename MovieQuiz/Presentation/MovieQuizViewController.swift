import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    // MARK: - Services
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let alertPresenter = AlertPresenter()

    // MARK: - Quiz State
    private let questionsAmount = 10
    private var askedCount = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFonts()
        configureImage()
        questionFactory.delegate = self
        requestNextQuestion()
    }

    // MARK: - UI Setup
    private func configureFonts() {
        questionTitleLabel.font = UIFont.ysMedium20
        indexLabel.font = UIFont.ysMedium20
        textLabel.font = UIFont.ysBold23
        noButton.titleLabel?.font = UIFont.ysMedium20
        yesButton.titleLabel?.font = UIFont.ysMedium20
    }

    private func configureImage() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }

    // MARK: - Flow
    private func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(askedCount + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        indexLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =
            isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }

    private func showNextQuestionOrResults() {
        askedCount += 1

        if askedCount >= questionsAmount {
            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let perfect = (correctAnswers == questionsAmount)
            let title = perfect ? "Идеально!" : "Этот раунд окончен!"
            let button = perfect ? "Сыграть ещё раз" : "Попробовать снова"

            let vm = QuizResultsViewModel(
                title: title,
                text: "",
                buttonText: button
            )
            showResults(quiz: vm)
        } else {
            requestNextQuestion()
        }
    }

    private func showResults(quiz result: QuizResultsViewModel) {
        let gamesCount = statisticService.gamesCount
        let best = statisticService.bestGame
        let bestDate = best.date.dateTimeString
        let accuracy = String(format: "%.2f%%", statisticService.totalAccuracy)

        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(best.correct)/\(best.total) (\(bestDate))
            Средняя точность: \(accuracy)
            """

        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.askedCount = 0
            self.correctAnswers = 0
            self.questionFactory.reset()
            self.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }

    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = true

        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        let vm = convert(model: question)
        show(quiz: vm)
    }

    func didRunOutOfQuestions() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let vm = QuizResultsViewModel(
            title: "Вопросы закончились",
            text: "",
            buttonText: "Сыграть ещё раз"
        )
        showResults(quiz: vm)
    }
}
