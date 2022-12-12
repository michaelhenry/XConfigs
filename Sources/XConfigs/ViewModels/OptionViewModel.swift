import Foundation
import RxCocoa
import RxSwift

struct OptionViewModel: ViewModelType {
    typealias Section = Int

    typealias Item = Choice

    struct Input {
        let reloadPublisher: Observable<Void>
        let dismissPublisher: Observable<Void>
        let selectItemPublisher: Observable<Item>
    }

    struct Output {
        let title: Driver<String>
        let sectionItemsModels: Driver<[SectionItemsModel<Section, Item>]>
        let action: Driver<Action>
    }

    enum Action {
        case cancel
        case select(Item)
    }

    private let model: OptionSelectionModel

    init(model: OptionSelectionModel) {
        self.model = model
    }

    func transform(input: Input) -> Output {
        let sectionItemsFromReload = input.reloadPublisher.map { _ -> [SectionItemsModel<Section, Item>] in
            .init(arrayLiteral: .init(section: 0, items: model.choices))
        }.asDriver(onErrorDriveWith: .empty())

        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let selectAction = input.selectItemPublisher.map(Action.select)

        let action = Observable.merge(cancelAction, selectAction).asDriver(onErrorDriveWith: .empty())
        return .init(
            title: .just(model.key),
            sectionItemsModels: sectionItemsFromReload,
            action: action
        )
    }
}
