//
//  UserHabitListHeaderView.swift
//  Habit
//
//  Created by Andrei Krotov on 25/05/2023.
//

import UIKit

import ConstraintsKit

final class UserHabitListHeaderView: UICollectionReusableView {

    // MARK: - Private properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)

        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    func configure(text: String) {
        titleLabel.text = text
    }

    // MARK: - Private methods

    private func setupUI() {
        [titleLabel].forEach(addSubview)

        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = .init(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 5
        titleLabel.layer.shadowOpacity = 0.5

        titleLabel
            .align(with: self, edges: [.left, .right])
            .centerVertically(with: self)
    }
}
