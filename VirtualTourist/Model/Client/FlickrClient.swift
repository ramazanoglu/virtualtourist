//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 29.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient : NSObject {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    
    func searchImages(pin: Pin, completionHandler: @escaping (_ error: String?) -> Void) {
        
        queryForPages(pin: pin, completionHandler: ({totalPages, error in
            
            if error == nil {
                
                let requiredPage  = self.getRandomNumber(lastUsedNumber: Int(pin.lastPage), totalPages: totalPages!)
                
                if requiredPage < 1
                {
                    completionHandler("No Images are found at this location")
                    return
                }
                
                pin.lastPage = Int16(requiredPage)
                
                self.queryImagesByLocation(pin: pin, completionHandler: completionHandler)
                
            }
        }))
    }
    
    func getRandomNumber(lastUsedNumber: Int, totalPages: Int) -> Int {
        
        print("Total Pages \(totalPages)")
        
        if totalPages == 1 {
            return 1
        }
        
        if totalPages < 1 {
            return -1
        }
       
        let randomPage = Int(arc4random_uniform(UInt32(totalPages))) + 1
        
        if(randomPage == lastUsedNumber) {
            return getRandomNumber(lastUsedNumber: lastUsedNumber, totalPages: totalPages)
        } else {
            return randomPage
        }
        
    }
    
    
    func downloadImage(url: String, completionHandler: @escaping (_ data: Data?,_ error: String?) -> Void) {
        
        let session = URLSession.shared
        let request = URLRequest(url: URL(string: url)!)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                
                completionHandler(data, nil)
                
            } else {
                print(error!)
            }
            
            
        }
        
        task.resume()
        
    }
    
    private func queryForPages(pin: Pin, completionHandler: @escaping (_ pages: Int?, _ error: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: String(pin.latitude),
            Constants.FlickrParameterKeys.Lon: String(pin.longitude),
            Constants.FlickrParameterKeys.PerPage: String("50")
            
        ]
        
        runRequest(methodParameters as [String:AnyObject]) { (parsedResult, error) in
            
            if error == nil {
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = parsedResult![Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(nil, "Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                    return
                }
                
                guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    completionHandler(nil, "Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                    return
                }
                                
                completionHandler(totalPages, nil)
                return
                
            } else {
                completionHandler(nil, error)
                return
            }
            
        }
        
        
    }
    
    private func queryImagesByLocation(pin: Pin, completionHandler: @escaping (_ error: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: String(pin.latitude),
            Constants.FlickrParameterKeys.Lon: String(pin.longitude),
            Constants.FlickrParameterKeys.Page: String(pin.lastPage),
            Constants.FlickrParameterKeys.PerPage: String("50")
            
        ]
        
        runRequest(methodParameters as [String:AnyObject], completionHandler: ({parsedResult, error in
            
            if error == nil {
                
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = parsedResult![Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    completionHandler("Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
                }
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = parsedResult![Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                    return
                }
                
                guard let page = photosDictionary[Constants.FlickrResponseKeys.Page] as? Int else {
                    completionHandler("Cannot find key '\(Constants.FlickrResponseKeys.Page)' in \(photosDictionary)")
                    return
                }
                
                
                print("Page \(page)")
                
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completionHandler("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                
                if photosArray.count == 0 {
                    completionHandler("No Photos Found. Search Again.")
                    return
                } else {
                    print("Photo Array Count \(photosArray.count)")
                    
                    //                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    //                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                    self.stack.performBackgroundBatchOperation { (batch) in
                        for photoDictionary in photosArray {
                            
                            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                            
                            /* GUARD: Does our photo have a key for 'url_m'? */
                            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                                completionHandler("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                                return
                            }
                            
                            
                            
                            _ = Image(url: imageUrlString, title: photoTitle!, pin: pin, context: self.stack.context)
                            
                        }
                        performUIUpdatesOnMain {
                            completionHandler(nil)
                        }
                        
                        
                    }
                    
                    
                }
            } else {
                completionHandler(error)
            }
            
        }))
        
        
    }
    
    func runRequest(_ methodParameters: [String: AnyObject], completionHandler: @escaping (_ dictionary: [String:AnyObject]?, _ error: String?) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func sendError(_ error: String) {
                print(error)
                completionHandler(nil,error)
                return
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            completionHandler(parsedResult, nil)
            return
            
            
        }
        
        
        // start the task!
        task.resume()
        
        
    }
    
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
        
    }
}
