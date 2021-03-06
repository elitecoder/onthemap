//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Mukul Sharma on 11/8/16.
//  Copyright © 2016 Mukul Sharma. All rights reserved.
//

import Foundation

// MARK: - UdacityClient

class UdacityClient {
	
	// MARK: Properties
	
	var session = URLSession.shared
	
	// MARK: GET
	
	func taskForGETMethod(_ method: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
		
		/* Build the URL, Configure the request */
		let request = NSMutableURLRequest(url: udacityURL(withPathExtension: method))
		request.httpMethod = "GET"
		
		/* Make the request */
		let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
			
			func sendError(_ error: String) {
				print(error)
				let userInfo = [NSLocalizedDescriptionKey : error]
				completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
			}
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				sendError("There was an error with your request: \(error!.localizedDescription)")
				return
			}
			
			/* GUARD: Did we get a successful 2XX response? */
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
				
				if let data = data {
					// Pull error message out of the Data and report that.
					sendError(Utility.obtainErrorMessage(data))
				}
				else {
					sendError("Your request returned a status code other than 2xx!")
				}
				return
			}
			
			/* GUARD: Was there any data returned? */
			guard let data = data else {
				sendError("No data was returned by the request!")
				return
			}
			
			/* Parse the data and use the data (happens in completion handler) */
			self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
		})
		
		/* Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: POST
	
	func taskForPOSTMethod(_ method: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
		
		/* Build the URL, Configure the request */
		let request = NSMutableURLRequest(url: udacityURL(withPathExtension: method))
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonBody.data(using: String.Encoding.utf8)
		
		/* Make the request */
		let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
			
			func sendError(_ error: String) {
				print(error)
				let userInfo = [NSLocalizedDescriptionKey : error]
				completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
			}
			
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				sendError("There was an error with your request: \(error!.localizedDescription)")
				return
			}
			
			/* GUARD: Did we get a successful 2XX response? */
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
				
				if let data = data {
					// Pull error message out of the Data and report that.
					sendError(Utility.obtainErrorMessage(data))
				}
				else {
					sendError("Your request returned a status code other than 2xx!")
				}
				return
			}
			
			/* GUARD: Was there any data returned? */
			guard let data = data else {
				sendError("No data was returned by the request!")
				return
			}
			
			/* Parse the data and use the data (happens in completion handler) */
			self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
		})
		
		/* Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: DELETE
	
	func taskForDELETEMethod(_ method: String, requestValues: [String:AnyObject], completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
	
				/* Build the URL, Configure the request */
				let request = NSMutableURLRequest(url: udacityURL(withPathExtension: method))
				request.httpMethod = "DELETE"
		
				for (key, value) in requestValues {
					request.addValue(value as! String, forHTTPHeaderField: key)
				}
		
				/* 4. Make the request */
				let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
		
					func sendError(_ error: String) {
						print(error)
						let userInfo = [NSLocalizedDescriptionKey : error]
						completionHandlerForDELETE(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
					}
		
					/* GUARD: Was there an error? */
					guard (error == nil) else {
						sendError("There was an error with your request: \(error!.localizedDescription)")
						return
					}
		
					/* GUARD: Did we get a successful 2XX response? */
					guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
						if let data = data {
							// Pull error message out of the Data and report that.
							sendError(Utility.obtainErrorMessage(data))
						}
						else {
							sendError("Your request returned a status code other than 2xx!")
						}
						return
					}
		
					/* GUARD: Was there any data returned? */
					guard let data = data else {
						sendError("No data was returned by the request!")
						return
					}
					
					/* Parse the data and use the data (happens in completion handler) */
					self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)
				})
				
				/* 7. Start the request */
				task.resume()
				
				return task
	}

	// MARK: Internal Helper Methods
	
	// given raw JSON, return a usable Foundation object
	fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
		
		// Udacity response contains 5 chars in the beginning which needs to be stripped off before parsing.
		let validData = data.subdata(in: Range(uncheckedBounds: (lower: 5, upper: data.count))) /* subset response data! */

		var parsedResult: AnyObject!
		do {
			parsedResult = try JSONSerialization.jsonObject(with: validData, options: .allowFragments) as AnyObject
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
			completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
		}
		
		completionHandlerForConvertData(parsedResult, nil)
	}
	
	// create a URL from parameters
	fileprivate func udacityURL(withPathExtension: String? = nil) -> URL {
		
		var components = URLComponents()
		components.scheme = Constants.ApiScheme
		components.host = Constants.ApiHost
		components.path = Constants.ApiPath + (withPathExtension ?? "")
		
		return components.url!
	}

	// MARK: Shared Instance
	
	class func sharedInstance() -> UdacityClient {
		struct Singleton {
			static var sharedInstance = UdacityClient()
		}
		return Singleton.sharedInstance
	}
}

