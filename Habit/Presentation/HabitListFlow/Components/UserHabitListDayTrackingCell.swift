//
//  UserHabitListDayTrackingCell.swift
//  Habit
//
//  Created by Andrei Krotov on 05/06/2023.
//

import UIKit.UICollectionViewCell

import ConstraintsKit

final class UserHabitListDayTrackingCell: UICollectionViewCell {

    // MARK: - Internal types

    struct Model: Equatable {
        enum StateKind: String {
            case normal
            case started
            case finished
        }

        let date: Date
        let isToday: Bool
        let state: StateKind
        let previousDayState: StateKind?
        let nextDayState: StateKind?
    }

    // MARK: - Private types

    private struct Constants {
        static let baseInset: CGFloat = 8
    }

    // MARK: - Private properties

    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color
        label.textAlignment = .center

        return label
    }()

    private let monthdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color
        label.textAlignment = .center

        return label
    }()

    private let circleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.baseInset
        view.layer.borderWidth = 1

        return view
    }()

    private let leftChainView: UIView = {
        let view = UIView()
        view.backgroundColor = Asset.Colors.success.color

        return view
    }()

    private let rightChainView: UIView = {
        let view = UIView()
        view.backgroundColor = Asset.Colors.success.color

        return view
    }()

    private let formatter = DateFormatter.weekdayShort

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        configure(with: .init(date: Date(), isToday: false, state: .normal, previousDayState: nil, nextDayState: nil))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circleView.layer.cornerRadius = circleView.bounds.height / 2
    }

    // MARK: - Internal methods

    func configure(with model: Model) {
        weekdayLabel.text = String(formatter.string(from: model.date).prefix(2)).uppercased()
        monthdayLabel.text = String(Calendar.current.component(.day, from: model.date))

        switch model.state {
        case .normal:
            circleView.backgroundColor = .clear
            circleView.layer.borderColor = UIColor.clear.cgColor
            leftChainView.isHidden = true
            rightChainView.isHidden = true
        case .started:
            circleView.backgroundColor = .clear
            circleView.layer.borderColor = Asset.Colors.success.color.cgColor
            leftChainView.isHidden = true
            rightChainView.isHidden = true
        case .finished:
            circleView.backgroundColor = Asset.Colors.success.color
            circleView.layer.borderColor = Asset.Colors.success.color.cgColor
            leftChainView.isHidden = model.previousDayState != .finished
            rightChainView.isHidden = model.nextDayState != .finished
        }

        monthdayLabel.font = .systemFont(ofSize: 10, weight: model.isToday ? .bold : .regular)
        weekdayLabel.font = .systemFont(ofSize: 10, weight: model.isToday ? .bold : .regular)
    }

    // MARK: - Private methods

    private func setupUI() {
        [circleView, leftChainView, rightChainView, monthdayLabel, weekdayLabel].forEach(addSubview)

        circleView
            .align(with: self, edges: [.left, .bottom, .right], insets: .init(
                top: Constants.baseInset,
                left: Constants.baseInset,
                bottom: Constants.baseInset,
                right: Constants.baseInset
            ))
            .equalsHeightToWidth()
        weekdayLabel
            .align(with: self, edges: [.left, .top, .right], insets: .init(
                top: Constants.baseInset,
                left: Constants.baseInset,
                bottom: Constants.baseInset,
                right: Constants.baseInset
            ))
        monthdayLabel
            .center(with: circleView)
        leftChainView
            .align(with: self, edges: .left)
            .spacingToLeading(of: circleView)
            .centerVertically(with: circleView)
            .equalsHeight(to: 1)
        rightChainView
            .align(with: self, edges: .right)
            .spacingToTrailing(of: circleView)
            .centerVertically(with: circleView)
            .equalsHeight(to: 1)
    }
}

