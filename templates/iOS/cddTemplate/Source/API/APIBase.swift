import Foundation
enum PostTypeCodingError: Error {
	case decoding(String)
}

class CDDAPI {
	static var token: String? {
		set {
			UserDefaults.standard.set(newValue, forKey: "kAPIToken")
			UserDefaults.standard.synchronize()
		}
		get {
			return UserDefaults.standard.string(forKey: "kAPIToken")
		}
	}
}

protocol APIClientProtocol {
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

class HTTPClient: APIClientProtocol {
	func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
	}
}

enum HTTPMethod: String {
	case options = "OPTIONS"
	case get     = "GET"
	case head    = "HEAD"
	case post    = "POST"
	case put     = "PUT"
	case patch   = "PATCH"
	case delete  = "DELETE"
	case trace   = "TRACE"
	case connect = "CONNECT"
}

enum CDDError: Error {
	case cantParseURL(String)
	case error(String)
	case genericError(Error)
	case noData
	//
	//    var localizedDescription: String {
	//        switch self {
	//        case .cantParseURL(let url):
	//            return "Can't parse url \(url)"
	//        case .error(let desc):
	//            return desc
	//        case .noData:
	//            return "Response doesn't contain data"
	//		case .genericError(let error):
	//			return error.localizedDescription
	//        }
	//    }
}

protocol APIModel: Decodable, Encodable {}

struct EmptyResponse: APIModel {

}

protocol APIRequest: Encodable {
	associatedtype ResponseType: Decodable
	associatedtype ErrorType: Decodable
	var urlPath: String { get }
	var method: HTTPMethod { get }
	//    func baseURL() -> URL
	func headers() -> [String:String]
	func isNeedLog() -> Bool
	func isNeedToken() -> Bool
	func send(client: APIClientProtocol,
			  onPaginate: ((_ curPage: Int, _ totalPage: Int) -> Void)?,
			  onResult: @escaping (_ result: ResponseType) -> Void,
			  onError: @escaping (_ error: ErrorType) -> Void,
			  onOtherError: ((_ error: CDDError) -> Void)?)
}

extension APIRequest {
	//    func baseURL() -> URL {
	//        return URL(string: HOST)!
	//    }

	func headers() -> [String:String] {
		return [:]
	}

	func isNeedLog() -> Bool {
		return true
	}

	func isNeedToken() -> Bool {
		return true
	}

	func mockFileName() -> String? {
		return nil
	}


	func generateRequest(url: URL, data: Data) -> URLRequest {
		URLSessionConfiguration.default.timeoutIntervalForRequest = 15
		URLSessionConfiguration.default.httpShouldSetCookies = true

		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.httpBody = data
		request.allHTTPHeaderFields = headers()
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		if let token = CDDAPI.token {
			request.setValue(token, forHTTPHeaderField: "X-Access-Token")
		}

		return request
	}

	func printLogging(request: URLRequest, response: URLResponse?, data: Data) {
		var logString = ""
		logString += "\nCURL:"
		logString += "\n" + request.cURL

		logString += "\nRESPONSE:"
		if let httpResponse = response as? HTTPURLResponse,
			let value = String(data: data, encoding: .utf8) {
			logString += "\nCODE: " + String(httpResponse.statusCode)
			logString += "\n" + value
		}
		print(logString)
	}


	func send(client: APIClientProtocol = HTTPClient(),
			  onPaginate: ((_ curPage: Int, _ totalPage: Int) -> Void)? = nil,
			  onResult: @escaping (_ result: ResponseType) -> Void,
			  onError: @escaping (_ error: ErrorType) -> Void,
			  onOtherError: ((_ error: CDDError) -> Void)? = nil) { // onOtherError not necessary, combine to one error function.

		do {
			let data = try JSONEncoder().encode(self)

			guard let url = URL(string: HOST + ENDPOINT + urlPath) else {
				onOtherError?(.cantParseURL(urlPath))
				return // TODO: improve error handling
			}

			let request = generateRequest(url: url, data: data)

			let _ = client.dataTask(with: request) { (data, response, error) in
				do {
					guard let data = data else {
						return // TODO: improve error handling
					}

					// TOKEN stuff start
					if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
						let dict = json as? [String:Any],
						let token = dict["access_token"] as? String {
						CDDAPI.token = token
					}
					// TOKEN stuff end - explore this

					if self.isNeedLog() {
						self.printLogging(request: request, response: response, data: data)
					}

					if let httpResponse = response as? HTTPURLResponse {
						let decoder = JSONDecoder()

						switch httpResponse.statusCode {
						case 200...299:
							// 200 OK
							let result = try decoder.decode(ResponseType.self, from: data)
							onResult(result)

						default:
							let result = try decoder.decode(ErrorType.self, from: data)
							onError(result)
						}
					}
				} catch {
					onOtherError?(.genericError(error))
				}
			}

			//			task.resume()
		}
		catch {
			onOtherError?(.genericError(error))
		}
	}
}


public extension URLRequest {

	/// Returns a cURL command for a request
	/// - return A String object that contains cURL command or "" if an URL is not properly initalized.
	var cURL: String {

		guard
			let url = url,
			let httpMethod = httpMethod,
			url.absoluteString.utf8.count > 0
			else {
				return ""
		}

		var curlCommand = "curl --verbose \\\n"

		// URL
		curlCommand = curlCommand.appendingFormat(" '%@' \\\n", url.absoluteString)

		// Method if different from GET
		if "GET" != httpMethod {
			curlCommand = curlCommand.appendingFormat(" -X %@ \\\n", httpMethod)
		}

		// Headers
		let allHeadersFields = allHTTPHeaderFields!
		let allHeadersKeys = Array(allHeadersFields.keys)
		let sortedHeadersKeys = allHeadersKeys.sorted(by: <)
		for key in sortedHeadersKeys {
			curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \\\n", key, self.value(forHTTPHeaderField: key)!)
		}

		// HTTP body
		if let httpBody = httpBody, httpBody.count > 0 {
			let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
			let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
			curlCommand = curlCommand.appendingFormat(" --data '%@' \\\n", escapedHttpBody)
		}

		return curlCommand
	}

	/// Escapes all single quotes for shell from a given string.
	static func escapeAllSingleQuotes(_ value: String) -> String {
		return value.replacingOccurrences(of: "'", with: "'\\''")
	}
}
