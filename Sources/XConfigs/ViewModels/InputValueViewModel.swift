import Combine
import CombineExt
import Foundation

struct InputValueViewModel: ViewModelType {
    struct Input {
        let textPublisher: AnyPublisher<String, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
        let donePublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let title: AnyPublisher<String, Never>
        let value: AnyPublisher<String, Never>
        let action: AnyPublisher<Action, Never>
    }

    enum Action {
        case cancel
        case done(String)
    }

    private let model: TextInputModel

    init(model: TextInputModel) {
        self.model = model
    }

    func transform(input: Input) -> Output {
        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let doneAction = input.donePublisher.withLatestFrom(input.textPublisher).map(Action.done)
        let action = Publishers.Merge(cancelAction, doneAction).eraseToAnyPublisher()
        return .init(
            title: Just(model.key).eraseToAnyPublisher(),
            value: Just(model.value).eraseToAnyPublisher(),
            action: action
        )
    }
}
