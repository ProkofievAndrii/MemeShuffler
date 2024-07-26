import UIKit
import AVFoundation

// MARK: - Welcome
struct Welcome: Codable {
    let data: WelcomeData
}

// MARK: - WelcomeData
struct WelcomeData: Codable {
    let after: String?
    let children: [Child]

    enum CodingKeys: String, CodingKey {
        case after
        case children
    }
}

// MARK: - Child
struct Child: Codable {
    let data: ChildData
}

// MARK: - ChildData
struct ChildData: Codable {
    let postHint: String?
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case postHint = "post_hint"
        case url
    }
}

class ApiParametersManager {
    //Variables
    private var subredditName: String = String()
    private var quantity: Int = Int()
    private var after: String? = nil
    
    //Getters/Setters
    func getSubredditName() -> String {
        return subredditName
    }
    
    func setSubredditName(_ newName: String) {
        guard !newName.isEmpty else { return }
        subredditName = newName
    }
    
    func getQuantity() -> Int {
        return quantity
    }
    
    func setQuantity(_ newQuantity: Int) {
        guard newQuantity >= 0 else { return }
        quantity = newQuantity
    }
    
    func getAfter() -> String? {
        return after
    }
    
    func setAfter(_ newAfter: String) {
        guard !newAfter.isEmpty else { return }
        after = newAfter
    }
}

private var parameters = ApiParametersManager()
parameters.setSubredditName("deadbydaylight")
parameters.setQuantity(10)
private var currentTask: URLSessionDataTask?

//MARK: - API request
private func requestMemesPortion(completion: @escaping ([ChildData]?, Error?) -> Void) {
    let subreddit = parameters.getSubredditName()
    let quantity = parameters.getQuantity()
    let after = parameters.getAfter()
    
    var components = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(quantity)")!
    if let after = after {
        components.queryItems?.append(URLQueryItem(name: "after", value: after))
    }
        
    guard let url = components.url else {
        completion(nil, URLError(.badURL))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, URLError(.badServerResponse))
            return
        }
        
        do {
            let redditResponse = try JSONDecoder().decode(Welcome.self, from: data)
            parameters.setAfter(redditResponse.data.after ?? String())
            let posts = redditResponse.data.children.map { $0.data }
            completion(posts, nil)
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
            completion(nil, error)
        }
    }.resume()
}

private func thumbnail(url: URL) {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: 1.0, preferredTimescale: 600)
    
    DispatchQueue.global().async {
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}

requestMemesPortion(completion: { memes, error  in
    if let memes = memes {
        for meme in memes {
            print(thumbnail(url: URL(string: meme.url!)!))
        }
    }
})
