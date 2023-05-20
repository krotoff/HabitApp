//
//  UserHabitCell.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit.UICollectionViewCell

import AnimatableViewsKit
import ConstraintsKit

final class UserHabitCell: BouncableCollectionCell {

    // MARK: - Internal types

    struct Model {
        var name: String
        var action: (() -> Void)?
    }

    // MARK: - Private types

    private struct Constants {
        static let labelInset: CGFloat = 16
    }

    // MARK: - Internal properties

    static let cellHeight: CGFloat = 48

    // MARK: - Private properties

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color
        label.font = .systemFont(ofSize: 16, weight: .semibold)

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

    func configure(with model: Model) {
        nameLabel.text = model.name
    }

    // MARK: - Private methods

    private func setupUI() {
        defaultShadowOpacity = 0.5
        bounceScale = 0.98
        backgroundColor = Asset.Colors.secondary.color
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = defaultShadowOpacity

        addSubview(nameLabel)

        nameLabel
            .align(
                with: self,
                edges: [.left, .right],
                insets: .init(top: 0, left: Constants.labelInset, bottom: 0, right: Constants.labelInset)
            )
            .centerVertically(with: self)
    }
}
