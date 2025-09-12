import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion)
    func didRunOutOfQuestions()
}


