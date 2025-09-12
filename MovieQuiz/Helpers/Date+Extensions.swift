import Foundation

extension Date {
    var dateTimeString: String {
        DateFormatter.defaultDateTime.string(from: self)
    }
}

private extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.timeZone = .current
        df.dateFormat = "dd.MM.yy HH:mm"
        return df
    }()
}
