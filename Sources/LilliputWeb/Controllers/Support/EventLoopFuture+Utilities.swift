// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor


public extension EventLoopFuture {
    func then<NewValue>(file: StaticString = #file, line: UInt = #line, _ callback: @escaping (Value) -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        flatMap(file: file, line: line, callback)
    }

    func thenRedirect(with request: Request, to: PathComponent) -> EventLoopFuture<Response> {
        map { _ in request.redirect(to: to) }
    }

    func thenRedirect(with request: Request, to: String) -> EventLoopFuture<Response> {
        map { _ in request.redirect(to: to) }
    }

    func translatingError<ErrorType>(to error: Error, if condition: @escaping (ErrorType) -> Bool) -> EventLoopFuture<Value> {
        flatMapErrorThrowing {
            if let dbError = $0 as? ErrorType, condition(dbError) {
                throw error
            }
            throw $0
        }
    }
}
