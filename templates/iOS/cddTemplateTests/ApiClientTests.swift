import XCTest
@testable import cddTemplate

class MockClient: APIClientProtocol {
	var jsonData: Data
	var statusCode: Int

	init(json: String, statusCode: Int) {
		self.jsonData = Data(json.utf8)
		self.statusCode = statusCode
	}

	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		let response = HTTPURLResponse(
			url: URL(string: "https://test.local/")!,
			statusCode: self.statusCode,
			httpVersion: nil,
			headerFields: nil)
		completionHandler(self.jsonData, response, nil)
		return URLSessionDataTask()
	}
}

class APIRequestTests: XCTestCase {
	func testMalformedRequest() {
		struct BasicResponse: APIModel {
			let id: Int
			let firstName: String
		}

		struct BasicError: APIModel {
			let message: String
		}

		struct MalformedRequest : APIRequest {
			typealias ResponseType = BasicResponse
			typealias ErrorType = BasicError
			var urlPath: String { return "/" }
			var method: HTTPMethod { return .post }
		}

		let request = MalformedRequest()

		// test status code 200
		request.send(
			client: MockClient(json: #"{"id": 2, "firstName": "Fred"}"#, statusCode: 200),
			onResult: { result in XCTAssertTrue(result.id == 2) },
			onError: { error in XCTFail("onError: \(error)") },
			onOtherError: { error in XCTFail("onOtherError: \(error)") })

		// test status code 400
		request.send(
			client: MockClient(json: #"{"message": "error occurred."}"#, statusCode: 400),
			onResult: { result in XCTFail("incorrectly returned valid result") },
			onError: { error in XCTAssertTrue(error.message == "error occurred.") },
			onOtherError: { error in XCTFail("onOtherError: \(error)") })

		// test incomplete fields response with code 200
		request.send(
			client: MockClient(json: #"{}"#, statusCode: 200),
			onResult: { result in XCTFail("incorrectly returned valid result") },
			onError: { error in XCTFail("onError: \(error)") },
			onOtherError: { error in /* ok */ })

		// test incomplete fields with response code 400
		request.send(
			client: MockClient(json: #"{}"#, statusCode: 400),
			onResult: { result in XCTFail("incorrectly returned valid result") },
			onError: { error in XCTFail("onError: \(error)") },
			onOtherError: { error in /* ok */ })
	}

}
