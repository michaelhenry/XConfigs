import Combine

extension AnyPublisher {
    func bind(to subject: PassthroughSubject<Output, Failure>) -> AnyCancellable {
        sink { result in
            subject.send(completion: result)
        } receiveValue: { val in
            subject.send(val)
        }
    }
}
