//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

// MARK: - StudentClient (Constants)

extension StudentClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "4e8bdccc3bb63cefbec21f936eca5651"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let SessionAuthentication : String = "/session"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "/account"
        static let AccountIDFavoriteMovies = "/account/{id}/favorite/movies"
        static let AccountIDFavorite = "/account/{id}/favorite"
        static let AccountIDWatchlistMovies = "/account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "/account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "/authentication/token/new"
        static let AuthenticationSessionNew = "/authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "/search/movie"
        
        // MARK: Config
        static let Config = "/configuration"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: StudentInfo
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let linkURL = "linkURL"
        //static let MovieResults = "results"
        
    }
    

}