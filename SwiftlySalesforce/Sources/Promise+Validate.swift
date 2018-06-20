//
//  Promise+Validate.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 6/11/18.
//

import Foundation
import PromiseKit

internal extension Promise where T == DataResponse {
	
	internal static var defaultValidator: DataResponseValidator {
		return {
			guard let response = $0.response as? HTTPURLResponse else {
				return $0
			}
			switch response.statusCode {
			case 200..<300:
				return $0
			case 401:
				throw Salesforce.Error.unauthorized
			case let code:
				// Error - try to deseralize Salesforce-provided error information
				// See: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/errorcodes.htm
				if let err = try? JSONDecoder().decode(ResourceErrorResult.self, from: $0.data) {
					throw Salesforce.Error.resourceError(httpStatusCode: code, errorCode: err.errorCode, message: err.message, fields: err.fields)
				}
				else if let err = try? JSONDecoder().decode(OAuth2ErrorResult.self, from: $0.data) {
					throw Salesforce.Error.resourceError(httpStatusCode: code, errorCode: err.error, message: err.error_description, fields: nil)
				}
				else {
					throw Salesforce.Error.resourceError(httpStatusCode: code, errorCode: nil, message: "Salesforce resource error.", fields: nil)
				}
			}
		}
	}
	
	internal func validated(with validator: DataResponseValidator? = nil) -> Promise<T> {
		return map(validator ?? Promise<T>.defaultValidator)
	}
}

fileprivate struct ResourceErrorResult: Decodable {
	var message: String
	var errorCode: String
	var fields: [String]?
}

fileprivate struct OAuth2ErrorResult: Decodable {
	var error: String
	var error_description: String?
}
