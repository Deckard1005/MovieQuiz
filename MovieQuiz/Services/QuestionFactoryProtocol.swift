import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    func reset()
}
