import UIKit

struct ChatMessage {
    let content: String
    let isUser: Bool
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sendMessageIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    var messages: [ChatMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // Set a reasonable estimated row height
        
        
        
        tableView.backgroundColor = .white
        tableView.separatorColor = .lightGray // Adjust according to your preference
        
        let autoMessage = ChatMessage(content: "Rashed: Hello, How can I help you?", isUser: false)
        messages.append(autoMessage)
        
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cellIdentifier = message.isUser ? "UserMessageCell" : "BotMessageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        cell.messageLabel.text = message.content
        cell.drawMessageBubble(isUser: message.isUser)
        return cell
    }
    
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        let messageText = message.content

        // Calculate the height required for the message text
        let labelWidth = tableView.frame.width - 80
        let labelFont = UIFont.systemFont(ofSize: 15)
        let labelSize = NSString(string: messageText).boundingRect(
            with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: labelFont],
            context: nil).size

        // Return the calculated height, accounting for padding or margins
        return labelSize.height + 50
    }


    // User sends a message
    @IBAction func sendMessage(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            self.sendMessageIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
            self.sendMessageIcon.transform = CGAffineTransform.identity
            }
        }
        if let messageText = messageTextField.text, !messageText.isEmpty {
            let userMessage = ChatMessage(content: messageText, isUser: true)
            messages.append(userMessage)
            messageTextField.text = ""

            // Process user's message and generate bot's response
            let botResponse = generateBotResponse(for: messageText)
            let botMessage = ChatMessage(content: botResponse, isUser: false)
            messages.append(botMessage)

            tableView.reloadData()
            scrollToBottom()
        }
    }

    // Scroll to the bottom of the table view
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // Generate Bot's response (dummy implementation)
    func generateBotResponse(for userMessage: String) -> String {
        guard let jsonData = loadJSONData() else {
                return "Sorry, I couldn't find the data."
            }
            
            // Decode JSON data into an array of QuestionAnswer objects
            guard let questionAnswers = decodeJSON(data: jsonData) else {
                return "Sorry, I couldn't process the data."
            }
            
            // Search for the user's message in the question answers
            for qa in questionAnswers {
                if qa.question.lowercased() == userMessage.lowercased() {
                    return "Rashed: \(qa.answer)"
                }
            }
            
            // If no matching question is found, return a default response
            return "I'm sorry, I don't have an answer to that question."
    }
    
    func loadJSONData() -> Data? {
        if let url = Bundle.main.url(forResource: "questions_answers", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("Error loading JSON data: \(error)")
            }
        }
        return nil
    }
    
    func decodeJSON(data: Data) -> [QuestionAnswer]? {
        do {
            let decoder = JSONDecoder()
            let questionAnswers = try decoder.decode([QuestionAnswer].self, from: data)
            return questionAnswers
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }

    struct QuestionAnswer: Codable {
        let question: String
        let answer: String
    }
}

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var userMessageView: UIView!
    @IBOutlet weak var botMessageView: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            messageLabel.numberOfLines = 0
    }
    
    func drawMessageBubble(isUser: Bool) {
            let messageView = isUser ? userMessageView : botMessageView
            
        let bubblePath = UIBezierPath(roundedRect: messageView!.bounds, byRoundingCorners: [.topLeft, .topRight, isUser ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
            
            let bubbleLayer = CAShapeLayer()
            bubbleLayer.path = bubblePath.cgPath
            bubbleLayer.fillColor = UIColor.lightGray.cgColor // Set your desired bubble color
            
        messageView!.layer.insertSublayer(bubbleLayer, at: 0)
    }

}

