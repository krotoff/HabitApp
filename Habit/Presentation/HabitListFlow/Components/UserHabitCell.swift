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
        var id: String
        var name: String
        var nextDate: String
        var passedCount: Int
        var totalCount: Int
        var action: ((UIView) -> Void)?
        var deleteAction: (() -> Void)?
    }

    // MARK: - Private types

    private struct Constants {
        static let labelInsetX: CGFloat = 16
        static let labelInsetY: CGFloat = 8
        static let buttonWidth: CGFloat = 52
    }

    // MARK: - Internal properties

    static let cellHeight: CGFloat = 52

    // MARK: - Private properties

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color
        label.font = .systemFont(ofSize: 20, weight: .semibold)

        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 14)

        return label
    }()

    private let mainView = UIView()
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mainView, rightButton])
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = 8

        return view
    }()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = Asset.Colors.text1.color
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .right

        return label
    }()
    private lazy var infoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [labelsStackView, countLabel])
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.alignment = .fill
        view.spacing = 4

        return view
    }()
    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .fill
        view.spacing = 0

        return view
    }()

    private let rightButton = BouncableButton()
    private var deleteAction: (() -> Void)?
    private var cellWasPanned: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    override func viewToScale() -> UIView { mainView }

    func configure(with model: Model) {
        nameLabel.text = model.name
        dateLabel.text = model.nextDate
        countLabel.text = "\(model.passedCount)/\(model.totalCount)"
        deleteAction = model.deleteAction
    }

    func subscribeOnPanAction(_ completion: @escaping (() -> Void)) {
        cellWasPanned = completion
    }

    func reset() {
        switchButtonsVisiblity(isVisible: false)
    }

    // MARK: - Private methods

    private func setupUI() {
        defaultShadowOpacity = 0.5
        bounceScale = 0.98

        backgroundColor = .clear
        [mainView, rightButton].forEach {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = .init(width: 0, height: 4)
            $0.layer.shadowRadius = 5
            $0.layer.shadowOpacity = defaultShadowOpacity
        }

        mainView.layer.cornerRadius = 8
        mainView.backgroundColor = Asset.Colors.secondary.color

        rightButton.layer.cornerRadius = 8
        rightButton.backgroundColor = Asset.Colors.failure.color
        rightButton.setImage(Asset.Images.close.image, for: .normal)
        rightButton.isHidden = true

        [mainStackView].forEach(addSubview)
        [infoStackView].forEach(mainView.addSubview)

        mainStackView
            .align(with: self)
        infoStackView
            .align(with: mainView, insets: .init(
                top: Constants.labelInsetY,
                left: Constants.labelInsetX,
                bottom: Constants.labelInsetY,
                right: Constants.labelInsetX
            ))
        rightButton
            .equalsHeightToWidth()

        rightButton.addTarget(self, action: #selector(deleteWasTapped), for: .touchUpInside)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self)
        let directionIsLeft = velocity.x < 0
        let buttonIsHidden = rightButton.isHidden
        let areLeftDirectionChangesNeeded = directionIsLeft && buttonIsHidden
        let areRightDirectionChangesNeeded = !directionIsLeft && !buttonIsHidden
        if areLeftDirectionChangesNeeded || areRightDirectionChangesNeeded {
            switchButtonsVisiblity(isVisible: directionIsLeft)
            cellWasPanned?()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func switchButtonsVisiblity(isVisible: Bool) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.rightButton.alpha = isVisible ? 1 : 0
                self.rightButton.isHidden = !isVisible
                self.mainStackView.layoutIfNeeded()
            }
        )
    }

    @objc private func deleteWasTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        deleteAction?()
    }
}

extension UserHabitCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizerShouldBeginForSwipableCell(gestureRecognizer: gestureRecognizer)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer is UISwipeGestureRecognizer || otherGestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
}


public extension UICollectionReusableView {

    // MARK: - Public properties

    static var reuseIdentifier: String { return String(describing: self) }
    static var bundle: Bundle { return Bundle(for: Self.self) }

    // MARK: - Public methods

    func gestureRecognizerShouldBeginForSwipableCell(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = recognizer.velocity(in: self)
            return abs(velocity.y) < abs(velocity.x)
        }

        return true
    }
}
