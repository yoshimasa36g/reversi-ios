//
//  RepositoryGatewayTests.swift
//  ReversiInterfaceAdapterTests
//
//  Created by yoshimasa36g on 2020/05/25.
//  Copyright © 2020 yoshimasa36g. All rights reserved.
//

@testable import ReversiInterfaceAdapter
import ReversiUseCase
import XCTest

final class RepositoryGatewayTests: XCTestCase {
    private let repository = MockRepository()
    private let client = MockClient()
    private var subject: RepositoryGateway?

    override func setUp() {
        super.setUp()
        subject = RepositoryGateway(repository: repository, client: client)
    }

    // MARK: - test for save(data:)

    /// GameStateRepositoryのsaveメソッドを呼ぶこと
    func testSave() {
        let data = sampleData()
        subject?.save(data)
        XCTAssertEqual(repository.savedData, data)
    }

    // MARK: - test for load()

    /// GameStateRepositoryのloadメソッドでデータを取得し、
    /// GameUseCaseResponseのdataLoadedメソッドでクライアントに通知すること
    func testLoad() {
        repository.savedData = sampleData()
        subject?.load()
        XCTAssertEqual(client.loadedData, repository.savedData)
    }

    /// ロードに失敗した場合、クライアントにエラーを通知すること
    func testLoadWhenFailed() {
        repository.savedData = nil
        subject?.load()
        XCTAssertEqual(client.error, .loadFailed)
    }

    // MARK: - helper methods

    private func sampleData() -> Data {
        guard let data = UUID().uuidString.data(using: .utf8) else {
            preconditionFailure("Couldn't create test data")
        }
        return data
    }
}

private class MockClient: GameUseCaseResponse {
    var loadedData: Data?
    var error: GameUseCaseResponseError?

    func dataLoaded(result: Result<Data, GameUseCaseResponseError>) {
        switch result {
        case .success(let data):
            loadedData = data
        case .failure(let error):
            self.error = error
        }
    }
}

private class MockRepository: GameStateRepository {
    var savedData: Data?

    func save(_ data: Data) throws {
        self.savedData = data
    }

    func load() throws -> Data {
        guard let data = savedData else {
            throw MockError()
        }
        return data
    }
}

private struct MockError: Error {}
