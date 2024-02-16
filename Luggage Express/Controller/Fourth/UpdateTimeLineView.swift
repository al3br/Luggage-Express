import UIKit

class TimelineItemView: UIView {
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 4 // Adjust the corner radius as needed
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0 // Allow multiple lines for long titles
        return label
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(dateTimeLabel)
        
        dotView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Dot constraints
        dotView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        dotView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        
        // Title label constraints
        titleLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        titleLabel.topAnchor.constraint(equalTo: dotView.topAnchor).isActive = true
        
        // Date time label constraints
        dateTimeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        dateTimeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        dateTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
    }
    
    func configure(title: String?, dateTime: String?, hasData: Bool) {
        titleLabel.text = title
        dateTimeLabel.text = dateTime
        if hasData {
                dotView.backgroundColor = .black
                dotView.layer.borderWidth = 0
            } else {
                dotView.backgroundColor = .clear
                dotView.layer.borderWidth = 2 // Set the border width as desired
                dotView.layer.borderColor = UIColor.black.cgColor // Set the border color as desired
            }
    }
}
