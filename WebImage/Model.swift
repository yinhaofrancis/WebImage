// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let body = try? newJSONDecoder().decode(Body.self, from: jsonData)

import Foundation

// MARK: - Body
public struct Body: Codable {
    public let success: Bool?
    public let errcode: Int?
    public let message: String?
    public let data: DataClass?

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case errcode = "errcode"
        case message = "message"
        case data = "data"
    }

    public init(success: Bool?, errcode: Int?, message: String?, data: DataClass?) {
        self.success = success
        self.errcode = errcode
        self.message = message
        self.data = data
    }
}

// MARK: - DataClass
public struct DataClass: Codable {
    public let focus: [Focus]?
    public let game: [Game]?
    public let content: [Content]?

    enum CodingKeys: String, CodingKey {
        case focus = "focus"
        case game = "game"
        case content = "content"
    }

    public init(focus: [Focus]?, game: [Game]?, content: [Content]?) {
        self.focus = focus
        self.game = game
        self.content = content
    }
}

// MARK: - Content
public struct Content: Codable {
    public let title: String?
    public let alias: String?
    public let image: String?
    public let model: String?
    public let introText: String?
    public let hits: String?
    public let time: String?
    public let imageType: String?
    public let comments: Int?
    public let redirectUrl: String?
    public let userData: UserData?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case alias = "alias"
        case image = "image"
        case model = "model"
        case introText = "intro_text"
        case hits = "hits"
        case time = "time"
        case imageType = "image_type"
        case comments = "comments"
        case redirectUrl = "redirect_url"
        case userData = "user_data"
    }

    public init(title: String?, alias: String?, image: String?, model: String?, introText: String?, hits: String?, time: String?, imageType: String?, comments: Int?, redirectUrl: String?, userData: UserData?) {
        self.title = title
        self.alias = alias
        self.image = image
        self.model = model
        self.introText = introText
        self.hits = hits
        self.time = time
        self.imageType = imageType
        self.comments = comments
        self.redirectUrl = redirectUrl
        self.userData = userData
    }
}

// MARK: - UserData
public struct UserData: Codable {
    public let username: String?
    public let domain: String?
    public let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case domain = "domain"
        case avatarUrl = "avatar_url"
    }

    public init(username: String?, domain: String?, avatarUrl: String?) {
        self.username = username
        self.domain = domain
        self.avatarUrl = avatarUrl
    }
}

// MARK: - Focus
public struct Focus: Codable {
    public let title: String?
    public let alias: String?
    public let image: String?
    public let model: String?
    public let redirectUrl: String?
    public let isUserParam: Int?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case alias = "alias"
        case image = "image"
        case model = "model"
        case redirectUrl = "redirect_url"
        case isUserParam = "is_user_param"
    }

    public init(title: String?, alias: String?, image: String?, model: String?, redirectUrl: String?, isUserParam: Int?) {
        self.title = title
        self.alias = alias
        self.image = image
        self.model = model
        self.redirectUrl = redirectUrl
        self.isUserParam = isUserParam
    }
}

// MARK: - Game
public struct Game: Codable {
    public let eventName: String?
    public let groupName: String?
    public let format: String?
    public let sessionId: String?
    public let sessionStatus: Int?
    public let time: String?
    public let team1Score: String?
    public let team2Score: String?
    public let team1Info: TeamInfo?
    public let team2Info: TeamInfo?

    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case groupName = "group_name"
        case format = "format"
        case sessionId = "session_id"
        case sessionStatus = "session_status"
        case time = "time"
        case team1Score = "team1_score"
        case team2Score = "team2_score"
        case team1Info = "team1_info"
        case team2Info = "team2_info"
    }

    public init(eventName: String?, groupName: String?, format: String?, sessionId: String?, sessionStatus: Int?, time: String?, team1Score: String?, team2Score: String?, team1Info: TeamInfo?, team2Info: TeamInfo?) {
        self.eventName = eventName
        self.groupName = groupName
        self.format = format
        self.sessionId = sessionId
        self.sessionStatus = sessionStatus
        self.time = time
        self.team1Score = team1Score
        self.team2Score = team2Score
        self.team1Info = team1Info
        self.team2Info = team2Info
    }
}

// MARK: - TeamInfo
public struct TeamInfo: Codable {
    public let teamId: String?
    public let teamName: String?
    public let teamTag: String?
    public let teamCountryId: String?
    public let teamLogo: String?

    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case teamName = "team_name"
        case teamTag = "team_tag"
        case teamCountryId = "team_country_id"
        case teamLogo = "team_logo"
    }

    public init(teamId: String?, teamName: String?, teamTag: String?, teamCountryId: String?, teamLogo: String?) {
        self.teamId = teamId
        self.teamName = teamName
        self.teamTag = teamTag
        self.teamCountryId = teamCountryId
        self.teamLogo = teamLogo
    }
}

