//
//  APIFire.swift
//  SwiftDelegateAndClosure
//
//  Created by Priyam Dutta on 13/06/16.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireObjectMapper

func +=< K, V > ( left: inout [K: V], right: [K: V]) {
	for (k, v) in right {
		left[k] = v
	}
}

extension Alamofire.SessionManager {
    private func cancelTasksByUrl(tasks: [URLSessionTask], url: String)
	{
		for task in tasks
		{
			debugPrint(task.currentRequest!.url!.description)
			if task.currentRequest!.url!.description == url
			{
				task.cancel()
			}
		}
	}

	func cancelAllTaskExcluding(tasks cancelTasks: [String]) {
		self.session.getTasksWithCompletionHandler
		{
			(dataTasks, uploadTasks, downloadTasks) -> Void in
            for task in dataTasks as [URLSessionTask] {
				if !cancelTasks.contains((task.currentRequest?.url?.description)!) {
					task.cancel()
                    debugPrint("*************************\(String(describing: task.currentRequest?.url?.description))*************")
				}
			}
		}
	}

	func cancelRequests(url: String) {
		self.session.getTasksWithCompletionHandler {
			(dataTasks, uploadTasks, downloadTasks) -> Void in
            self.cancelTasksByUrl(tasks: dataTasks as [URLSessionTask], url: "" + url)
            self.cancelTasksByUrl(tasks: uploadTasks as [URLSessionTask], url: "" + url)
            self.cancelTasksByUrl(tasks: downloadTasks as [URLSessionTask], url: "" + url)
		}
	}
}

class HTTPManager: Alamofire.SessionManager {
	static let sharedManager: HTTPManager = {
		let configuration = URLSessionConfiguration.default
		let manager = HTTPManager(configuration: configuration)
		return manager
	}()

	internal var currentTask: Alamofire.Request?
	private var baseURL = "https://raw.githubusercontent.com/tristanhimmelman/AlamofireObjectMapper/d8bb95982be8a11a2308e779bb9a9707ebe42ede/sample_json"
	private static let apiKey = ""
	private let parameterEncoding: ParameterEncoding = JSONEncoding.default
	internal var header: [String: String] = ["Content-Type": "application/json"]

	// MARK: Reachability Check
	let network = NetworkReachabilityManager()
	private func isReachable() -> (Bool) {
		if network?.isReachable ?? false {
			if ((network?.isReachableOnEthernetOrWiFi) != nil) {
				return true
			} else if (network?.isReachableOnWWAN)! {
				return true
			}
		} else {
			return false
		}
		return false
	}

	func networkStatus() {
		network?.startListening()
		network?.listener = { status in
            if status == self.network?.networkReachabilityStatus {
                // Network reachability check
			}
		}
	}

	// MARK: API Callings
	/************************** General Requests ***************************/

	/**
     POST REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    func postRequestJSON(shouldShowLoader: Bool, endPoint: String, parameters: [String: AnyObject]?, headers: [String: String]?, success: @escaping (_ response: JSON?) -> (), failure: @escaping (_ error: NSError?) -> ()) {
		defer {
			debugPrint("POST REQUEST for endpoint \(endPoint) successfully executed")
		}
		if isReachable() {
			debugPrint("show loader")
			if shouldShowLoader {
				// Show loader
			}
			if headers != nil {
				header += headers!
			}
			let postURL = baseURL
            
			HTTPManager.sharedManager.currentTask = HTTPManager.sharedManager.request(postURL + endPoint, method: .post, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
				debugPrint("hide loader")
				if shouldShowLoader {
					// Show loader
				}
				guard response.result.isSuccess else {
                    failure(response.result.error! as NSError)
					if response.result.error?.localizedDescription != "cancelled" {
					}
					return
				}
				if let value = response.result.value {
                    success(JSON(value))
				}
			}
		} else {
		}
	}
	/**
     GET REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    func getRequestJSON(shouldShowLoader: Bool, endPoint: String, parameters: [String: AnyObject]?, headers: [String: String]?, success: @escaping (_ response: JSON?) -> (), failure: @escaping (_ error: NSError?) -> ()) {
		defer {
			debugPrint("GET REQUEST for endpoint \(endPoint) successfully executed")
		}
		if isReachable() {
			debugPrint("show loader")
			if shouldShowLoader {
				// Start triggering loader here.
			}
			if headers != nil {
				header += headers!
			}
            
            HTTPManager.sharedManager.request(baseURL, method: .get, parameters: nil, encoding: parameterEncoding, headers: header).validate().responseObject(completionHandler: { (response: DataResponse<WeatherResponse>) in
                print(response.result.value?.location)
            })
            
			/*HTTPManager.sharedManager.currentTask = HTTPManager.sharedManager.request(baseURL + endPoint, method: .get, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
				debugPrint("hide loader")
				if shouldShowLoader {
					// Stop loader animation here.
				}
				guard response.result.isSuccess else {
                    failure(response.result.error! as NSError)
                    debugPrint(response.result.error!.localizedDescription)
					if response.result.error?.localizedDescription != "cancelled" {
                        // If Task Cancelled
					}
					return
				}
				if let value = response.result.value {
                    success(JSON(value))
				}
			}*/
		} else {
		}
	}

	/**
     PUT REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    func putRequestJSON(shouldShowLoader: Bool, endPoint: String, parameters: [String: AnyObject]?, headers: [String: String]?, success: @escaping (_ response: JSON?) -> (), failure: @escaping (_ error: NSError?) -> ()) {
		defer {
			debugPrint("PUT REQUEST for endpoint \(endPoint) successfully executed")
		}
		if isReachable() {
			debugPrint("show loader")
			if shouldShowLoader {
				// Show loader here.
			}
			if headers != nil {
				header += headers!
			}
			HTTPManager.sharedManager.currentTask = HTTPManager.sharedManager.request(baseURL + endPoint, method: .put, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
				debugPrint("hide loader")
				if shouldShowLoader {
					// Show loader here.
				}
				guard response.result.isSuccess else {
					failure(response.result.error! as NSError)
                    debugPrint(response.result.error!.localizedDescription)
					if response.result.error?.localizedDescription != "cancelled" {
					}
					return
				}

				if let value = response.result.value {
                    success(JSON(value))
				}
			}
		} else {
		}
	}

	/*---------------------Uploading---------------------*/

	/**
     Uploading Without Multipart
     
     - parameter endPoint:      to be appended to base url
     - parameter headers:       to be send in request headers
     - parameter file:          file to be uploaded in binary format
     - parameter progressBlock: callback for progress updation
     - parameter success:       callback on success
     - parameter failure:       callback on failure
     */
    func uploadFile(endPoint: String, headers: [String: String]?, file: Data, progressBlock: (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ bytesExpectedToWrite: Int64) -> (), success: (_ response: AnyObject?) -> (), failure: (_ error: NSError?) -> ()) {

		if isReachable() {
			if headers != nil {
				header += headers!
			}
            HTTPManager.sharedManager.uploadFile(endPoint: baseURL + endPoint, headers: headers, file: file, progressBlock: { (bytesWritten, totalBytesWritten, bytesExpectedToWrite) in
            }, success: { (response) in
            }, failure: { (error) in
            })
		} else {}
	}

	/**
     Uploading using Multipart
     
     - parameter endPoint: to be appended to base url
     - parameter headers:  to be send in request headers
     - parameter file:     file to be uploaded in binary format
     - parameter fileName: file name to be set
     - parameter success:  callback on success
     - parameter failure:  callback on failure
     */
    func uploadFileMultipartFormData(endPoint: String, headers: [String: String]?, file: [Data]?, fileName: [String]?, success: (_ response: AnyObject) -> (), failure: (_ error: NSError?) -> ()) {

		if isReachable() {
			if headers != nil {
				header += headers!
			}
            HTTPManager.sharedManager.upload(multipartFormData: { (multipartFormData) in
                for (index, value) in (file?.enumerated())! {
                    multipartFormData.append(value, withName: fileName![index], mimeType: "image/jpeg")
                }
            }, to: baseURL + endPoint, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(request: _, streamingFromDisk: _, streamFileURL: _): break
//                    upload.responseJSON { response in
//                        debugPrint(response)
//                    }
                case .failure(let error):
                    debugPrint(error)
                }
            })
            
//            HTTPManager.sharedManager.upload(.POST, baseURL + endPoint, multipartFormData: { (MultipartFormData) in
//
//                for (index, value) in (file?.enumerate())! {
//                    MultipartFormData.appendBodyPart(data: value, name: fileName![index], mimeType: "image/jpeg")
//                }
//
//                }, encodingCompletion: { encodingResult in
//
//                switch encodingResult {
//                case .Success(let upload, _, _):
//                    upload.responseJSON { response in
//                        debugPrint(response)
//                    }
//                case .Failure(let encodingError):
//                    debugPrint(encodingError)
//                }
//            })
		} else {
		}
	}

	// MARK: - Downloading -

	/*---------------------Downloading---------------------*/

    func downloadFile(withURL url: String, forNID nid: String, speakerName: String?, index: String?, success: (_ directoryPath: String) -> (), andFailure failure: (_ error: NSError??, _ atpath: String) -> ()) {

//        let destination = getFileDstination(forNID: nid, speakerName: speakerName, index: index)

		let path: String?
		if speakerName == "" {
//            path = "\(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])/OfflineTempImages/\(nid)"
		} else {
//            path = "\(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])/OfflineTempImages/\(nid)\(speakerName!.stringByReplacingOccurrencesOfString(" ", withString: ""))"
		}
        
//        HTTPManager.sharedManager.download("url", method: .get, parameters: nil, encoding: parameterEncoding, headers: nil) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
//
//            }.downloadProgress(queue: queue) { (progress) in
//
//        }
        
//        Alamofire.download(.GET, url.stringByReplacingOccurrencesOfString(" ", withString: ""), destination: destination!).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
//            // debugPrint("bytesRead: \(bytesRead)\n totalBytesRead:\(totalBytesRead)\n totalBytesExpectedToRead:\(totalBytesExpectedToRead)")
//            if (totalBytesRead == totalBytesExpectedToRead) {
//                let seconds = 0.01
//                let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
//                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//
//                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                    // here code perfomed with delay
//                    success(directoryPath: path!)
//                })
//            }
//        }.response { (_, _, _, error) in
//            if (error != nil)
//            {
//                failure(error: error, atpath: path!)
//            }
//        }
	}

	/*func downloadFile(withURL url: String, forThumbNailOfNID nid: String, speakerName: String?, success: (directoryPath: String) -> (), andFailure failure: (error: NSError!, atpath: String?) -> ()) {

		let destination = getFileDstination(thumbNailOfNID: nid, speakerName: speakerName)

		let path = "\(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])/OfflineTempImages/\(nid)\(speakerName!.stringByReplacingOccurrencesOfString(" ", withString: ""))/Thumb"
		Alamofire.download(.GET, url.stringByReplacingOccurrencesOfString(" ", withString: ""), destination: destination!).progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
			// debugPrint("bytesRead: \(bytesRead)\n totalBytesRead:\(totalBytesRead)\n totalBytesExpectedToRead:\(totalBytesExpectedToRead)")
			if (totalBytesRead == totalBytesExpectedToRead) {
				let seconds = 0.01
				let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
				let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

				dispatch_after(dispatchTime, dispatch_get_main_queue(), {
					// here code perfomed with delay
					success(directoryPath: path)
				})

			}
		}.response { (_, _, _, error) in
			if (error != nil)
			{
				failure(error: error, atpath: path)
			}
		}
	}

	func getFileDstination(forNID nid: String!, speakerName: String?, index: String?) -> Request.DownloadFileDestination? {
		var localPath: NSURL?
		return { (temporaryURL, response) in
			// Create directory
			let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
			let myDirectory: NSURL?

			if speakerName == "" {
				myDirectory = documentsPath.URLByAppendingPathComponent("OfflineTempImages/\(nid)")
			} else {
				myDirectory = documentsPath.URLByAppendingPathComponent("OfflineTempImages/\(nid)\(speakerName!.stringByReplacingOccurrencesOfString(" ", withString: ""))")
			}

			do {
				try NSFileManager.defaultManager().createDirectoryAtPath(myDirectory!.path!, withIntermediateDirectories: true, attributes: nil)
			} catch let error as NSError {
				NSLog("Unable to create directory \(error.debugDescription)")
			}
			let directoryURL = myDirectory
			let pathComponent = "\(index!).\((response.suggestedFilename?.componentsSeparatedByString(".").last)!)"

			localPath = directoryURL!.URLByAppendingPathComponent(pathComponent)
			return localPath!
		}
	}

	func getFileDstination(thumbNailOfNID nid: String!, speakerName: String?) -> Request.DownloadFileDestination? {
		var localPath: NSURL?
		return { (temporaryURL, response) in
			// Create directory
			let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])

			let myDirectory: NSURL?

			if speakerName == "" {
				myDirectory = documentsPath.URLByAppendingPathComponent("OfflineTempImages/\(nid)\(speakerName!.stringByReplacingOccurrencesOfString(" ", withString: ""))/Thumb")
			} else {
				myDirectory = documentsPath.URLByAppendingPathComponent("OfflineTempImages/\(nid)\(speakerName!.stringByReplacingOccurrencesOfString(" ", withString: ""))/Thumb")
			}

			do {
				try NSFileManager.defaultManager().createDirectoryAtPath(myDirectory!.path!, withIntermediateDirectories: true, attributes: nil)
			} catch let error as NSError {
				NSLog("Unable to create directory \(error.debugDescription)")
			}
			let directoryURL = myDirectory
			let pathComponent = response.suggestedFilename

			localPath = directoryURL!.URLByAppendingPathComponent(pathComponent!)
			return localPath!
		}
	}*/
}
