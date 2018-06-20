//
//  Salesforce.swift
//  SwiftlySalesforce
//
//  Created by Michael Epstein on 5/14/18.
//

import Foundation
import SafariServices
import PromiseKit

public class Salesforce {
	
	public struct User {
		let userID: String
		let organizationID: String
	}
	
	public struct Options: OptionSet {
		public let rawValue: Int
		public static let dontAuthenticate = Options(rawValue: 1 << 0)
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	public let configuration: Configuration
	
	internal var authorizationPromise: Promise<Authorization>?
	internal var authorizationStoreKey: AuthorizationStore.Key?
	internal var authenticationSession: SFAuthenticationSession?
	
	public init(configuration: Configuration, user: User? = nil) {
		self.configuration = configuration
		if let u = user {
			authorizationStoreKey = AuthorizationStore.Key(userID: u.userID, organizationID: u.organizationID, consumerKey: configuration.consumerKey)
		}
		else {
			authorizationStoreKey = AuthorizationStore.lastStoredKey
		}
	}
}

public extension Salesforce {
	
	public var authorization: Authorization? {
		guard let key = self.authorizationStoreKey else {
			return nil
		}
		return AuthorizationStore.retrieve(for: key)
	}
	
	public var accessToken: String? {
		return authorization?.accessToken
	}
}

internal extension Salesforce {
	
	internal func dataTask(resource: Resource, options: Options = [], validator: DataResponseValidator? = nil) -> Promise<DataResponse> {
		
		let go: (Authorization) throws -> Promise<DataResponse> = {
			URLSession.shared.dataTask(.promise, with: try resource.request(with: $0)).validated(with: validator)
		}
		
		return firstly { () -> Promise<DataResponse> in
			guard let auth = self.authorization else {
				throw Salesforce.Error.unauthorized
			}
			return try go(auth)
		}.recover { error -> Promise<DataResponse> in
			guard case Salesforce.Error.unauthorized = error, !options.contains(.dontAuthenticate) else {
				throw error
			}
			return self.authorize().then { auth -> Promise<DataResponse> in
				return try go(auth)
			}
		}
	}
	
	internal func dataTask<T: Decodable>(resource: Resource, options: Options = [], validator: DataResponseValidator? = nil) -> Promise<T> {
		return dataTask(resource: resource, options: options, validator: validator).map {
			return try JSONDecoder(dateFormatter: .salesforceDateTimeFormatter).decode(T.self, from: $0.data)
		}
	}
}
