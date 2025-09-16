import Foundation

final class StatisticService: StatisticServiceProtocol {

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

    // MARK: - Публичные свойства протокола

    var gamesCount: Int {
        storage.integer(forKey: Keys.gamesCount.rawValue)
    }

    var bestGame: GameResult {
        let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
        let total   = storage.integer(forKey: Keys.bestGameTotal.rawValue)
        let date    = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? .distantPast
        return GameResult(correct: correct, total: total, date: date)
    }

    var totalAccuracy: Double {
        let totalAsked = totalQuestionsAsked
        guard totalAsked > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(totalAsked)) * 100.0
    }

    // MARK: - Приватные накопительные счётчики

    private var totalCorrectAnswers: Int {
        get { storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }

    private var totalQuestionsAsked: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAsked.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue) }
    }

    // MARK: - Сохранение результата игры

    func store(correct count: Int, total amount: Int) {
        let newGamesCount = gamesCount + 1
        storage.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
        
        totalCorrectAnswers += count
        totalQuestionsAsked += amount

        let current = GameResult(correct: count, total: amount, date: Date())
        if current.isBetterThan(bestGame) {
            storage.set(current.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(current.total,   forKey: Keys.bestGameTotal.rawValue)
            storage.set(current.date,    forKey: Keys.bestGameDate.rawValue)
        }
    }
}
