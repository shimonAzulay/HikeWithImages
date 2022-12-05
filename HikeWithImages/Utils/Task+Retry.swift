//
//  Task+Retry.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import Foundation

/// This code was taken from the following: https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/
extension Task where Failure == Error {
  @discardableResult
  static func retrying(
    priority: TaskPriority? = nil,
    maxRetryCount: Int = 3,
    retryDelay: TimeInterval = 1,
    operation: @Sendable @escaping () async throws -> Success
  ) -> Task {
    Task(priority: priority) {
      for retry in 0..<maxRetryCount {
        do {
          return try await operation()
        } catch {
          print("Task failed! retries left: \(maxRetryCount - retry - 1)")
          let oneSecond = TimeInterval(1_000_000_000)
          let delay = UInt64(oneSecond * retryDelay)
          try await Task<Never, Never>.sleep(nanoseconds: delay)
          
          continue
        }
      }
      
      try Task<Never, Never>.checkCancellation()
      return try await operation()
    }
  }
}
