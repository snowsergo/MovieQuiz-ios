import Foundation
protocol ResultAlertPresenterProtocol {
    var title: String { get }
    var text: String { get }
    var buttonText: String { get }
    func showResult(callback: @escaping () -> Void)
}
