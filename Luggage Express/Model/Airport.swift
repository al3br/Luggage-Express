import Foundation

struct Airport: Codable {
    let name: String

}

func fetchAirports(from urlString: String, completion: @escaping ([Airport]?) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        
        do {
            let airports = try JSONDecoder().decode([Airport].self, from: data)
            completion(airports)
        } catch {
            print("Error decoding data: \(error)")
            completion(nil)
        }
    }
    
    task.resume()
}
