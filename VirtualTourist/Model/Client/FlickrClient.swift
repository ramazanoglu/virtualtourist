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
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: String(pin.latitude),
            Constants.FlickrParameterKeys.Lon: String(pin.longitude),
            Constants.FlickrParameterKeys.Page: String("3"),
            Constants.FlickrParameterKeys.PerPage: String("50")
            
            
        ]
        queryImagesByLocation(methodParameters as [String:AnyObject], pin: pin, completionHandler: completionHandler)
        
    }
    
    private func queryImagesByLocation(_ methodParameters: [String: AnyObject], pin: Pin, completionHandler: @escaping (_ error: String?) -> Void) {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func sendError(_ error: String) {
                print(error)
                completionHandler(error)
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
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                sendError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            guard let page = photosDictionary[Constants.FlickrResponseKeys.Page] as? Int else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Page)' in \(photosDictionary)")
                return
            }
            
            print("Total pages \(totalPages)")
            
            print("Page \(page)")
            
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                sendError("No Photos Found. Search Again.")
                return
            } else {
                print("Photo Array Count \(photosArray.count)")
                
                //                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                //                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                for photoDictionary in photosArray {
                    
                    let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                    
                    print(photoTitle)
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        sendError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                        return
                    }
                    
                    let image = Image(url: imageUrlString, title: photoTitle!, pin: pin, context: self.stack.context)
                    
                   
                    
                }
                
                completionHandler(nil)
                return
            }
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
