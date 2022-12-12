import Foundation
import Prettier_swift
import RxCocoa
import RxSwift

struct InputValueViewModel: ViewModelType {
    struct Input {
        let textPublisher: Observable<String>
        let dismissPublisher: Observable<Void>
        let donePublisher: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let value: Driver<String>
        let action: Driver<Action>
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
        let action = Observable.merge(cancelAction, doneAction).asDriver(onErrorDriveWith: .empty())
        return .init(
            title: .just(model.key),
            value: .just(prettier.prettify(model.value, parser: .jsonStringify)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? model.value),
            action: action
        )
    }
}
