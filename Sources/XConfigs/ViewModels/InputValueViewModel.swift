import Combine
import CombineExt
import Foundation

struct InputValueViewModel: ViewModelType {
    let title: String
    let value: String

    struct Input {
        let textPublisher: AnyPublisher<String, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
        let donePublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let action: AnyPublisher<Action, Never>
    }

    enum Action {
        case cancel
        case done(String)
    }

    func transform(input: Input) -> Output {
        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let doneAction = input.donePublisher.withLatestFrom(input.textPublisher).map(Action.done)
        let action = Publishers.Merge(cancelAction, doneAction).eraseToAnyPublisher()
        return .init(action: action)
    }
}
