//
//  EventProducerUtilities.swift
//  CoatChex
//
//  Created by Austin Feight on 11/30/16.
//  Copyright © 2016 Chexology. All rights reserved.
//

import Foundation
import PromiseKit
import ReactiveKit

public enum EitherError: Error {
  case timeout
}

public enum Either<A,B> {
  case left(A)
  case right(B)
}

public func wait<EventProducer: SignalProtocol>
                (for eventProducer: EventProducer, withTimeout timeout: TimeInterval) -> Promise<EventProducer.Element>
{
  let (promise, fulfill, reject) = Promise<EventProducer.Element>.pending()
  
  var disposable: Disposable?
  disposable = eventProducer.observeNext {
    fulfill($0)
    disposable?.dispose()
  }
  
  delay(timeout) {
    guard !promise.isResolved else { return }
    
    reject(EitherError.timeout)
    disposable?.dispose()
  }

  return promise
}

public func either<EventStream: SignalProtocol, ErrorStream: SignalProtocol>
                  (_ eventStream: EventStream, or errorStream: ErrorStream, withTimeout timeout: TimeInterval? = nil)
                  -> Promise<EventStream.Element>
  where ErrorStream.Element: Error
{
  let (promise, fulfill, reject) = Promise<EventStream.Element>.pending()
  let disposable = CompositeDisposable()
  
  let fulfillDisposable = eventStream.observeNext(with: {
    fulfill($0)
    disposable.dispose()
  })
    
  let errorDisposable = errorStream.observeNext(with: {
    reject($0)
    disposable.dispose()
  })

  if let timeout = timeout {
    delay(timeout) {
      reject(EitherError.timeout)
      disposable.dispose()
    }
  }
  
  [fulfillDisposable, errorDisposable].forEach(disposable.add)
  return promise
}

public extension SignalProtocol where Error == NoError {
  @discardableResult
  func observeOnce(_ observer: @escaping (Element) -> Void) -> Disposable?
  {
    var disposable: Disposable?
    disposable = observeNext { event in
      disposable?.dispose()
      observer(event)
    }
    
    return disposable
  }
  
  var promise: Promise<Element> {
    return Promise { fulfill, _ in observeOnce(fulfill) }
  }
}

extension Property where Element: Equatable {
  var filterDuplicates: Signal<Element, NoError> {
    return filter { [weak self] in $0 != self?.value }
  }
}

public func delay<T>(_ seconds: Double, queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> T)
{
  let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
  let fireTime = DispatchTime.now() + Double(nanoSeconds) / Double(NSEC_PER_SEC)
  queue.asyncAfter(deadline: fireTime) { _ = block() }
}
