import Combine
import CombineExt
import Foundation
import Prettier_swift

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
    private let prettier = Prettier()

    init(model: TextInputModel) {
        self.model = model
    }

    func transform(input: Input) -> Output {
        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let doneAction = input.donePublisher.withLatestFrom(input.textPublisher).map(Action.done)
        let action = Publishers.Merge(cancelAction, doneAction)
        return .init(
            title: Just(model.key).eraseToAnyPublisher(),
            value: Just(prettier.prettify(model.value, parser: .jsonStringify)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? model.value).eraseToAnyPublisher(),
            action: action.eraseToAnyPublisher()
        )
    }
}
