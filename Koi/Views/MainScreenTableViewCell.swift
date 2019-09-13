//
//  MainScreenTableViewCell.swift
//  Koi
//
//  Created by john sanford on 8/24/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class MainScreenTableViewCell: UITableViewCell {
    
    let cellView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .deepBlue
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let listLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Use the + to add someone to your list"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(cellView)
        cellView.addSubview(listLabel)
        self.selectionStyle = .none
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        // Height and width anchor decide the size of the textLabel within each cell
        listLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        listLabel.widthAnchor.constraint(equalToConstant: 400).isActive = true
        listLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        listLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 20).isActive = true
        
    }

}
