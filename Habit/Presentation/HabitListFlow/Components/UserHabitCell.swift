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
        var checkAction: (() -> Void)?
        var deleteAction: (() -> Void)?
    }

    // MARK: - Private types

    private enum SwipableCellStateKind: String, Equatable {
        case left
        case center
        case right
    }

    private struct Constants {
        static let labelInsetX: CGFloat = 16
        static let labelInsetY: CGFloat = 12
    }

    // MARK: - Internal properties

    static let cellHeight: CGFloat = 64

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
        let view = UIStackView(arrangedSubviews: [leftButton, mainView, rightButton])
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

    private let leftButton = BouncableButton()
    private let rightButton = BouncableButton()

    private var state: SwipableCellStateKind = .center

    private var deleteAction: (() -> Void)?
    private var checkAction: (() -> Void)?
    private var cellWasPanned: (() -> Void)?

    private var isStateChanging = false

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

        nameLabel.text = nil
        dateLabel.text = nil
        deleteAction = nil
        countLabel.text = nil
        reset()
    }

    // MARK: - Internal methods

    override func viewToScale() -> UIView { mainView }

    func configure(with model: Model) {
        nameLabel.text = model.name
        dateLabel.text = model.nextDate
        deleteAction = model.deleteAction

        let passedString = String(model.passedCount)
        let totalString = String(model.totalCount)
        let isDone = model.passedCount == model.totalCount
        let attributedText = NSMutableAttributedString(
            string: [passedString, "/", totalString].joined(),
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: (isDone ? Asset.Colors.success : Asset.Colors.text1).color
            ])
        if !isDone, model.passedCount > 0 {
            attributedText.addAttribute(
                .foregroundColor,
                value: Asset.Colors.success.color,
                range: (attributedText.string as NSString).range(of: passedString)
            )
        }
        countLabel.attributedText = attributedText

        if isDone {
            markAsCompleted()
        }
    }

    func subscribeOnPanAction(_ completion: @escaping (() -> Void)) {
        cellWasPanned = completion
    }

    func reset() {
        animateNewState(.center)
    }

    // MARK: - Private methods

    private func setupUI() {
        defaultShadowOpacity = 0.5
        bounceScale = 0.98

        backgroundColor = .clear

        leftButton.backgroundColor = Asset.Colors.success.color
        mainView.backgroundColor = Asset.Colors.secondary.color
        rightButton.backgroundColor = Asset.Colors.failure.color

        [leftButton, mainView, rightButton].forEach {
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = .init(width: 0, height: 4)
            $0.layer.shadowRadius = 5
            $0.layer.shadowOpacity = defaultShadowOpacity
            $0.layer.cornerRadius = 8
        }

        [leftButton, rightButton].forEach {
            $0.isHidden = true
            $0.alpha = 0
            $0.defaultColor = $0.backgroundColor!
            $0.highlightedColor = $0.backgroundColor!
            $0.defaultShadowOpacity = defaultShadowOpacity
        }

        leftButton.setImage(Asset.Images.check.image, for: .normal)
        rightButton.setImage(Asset.Images.close.image, for: .normal)

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
        leftButton
            .equalsHeightToWidth()
        rightButton
            .equalsHeightToWidth()

        leftButton.addTarget(self, action: #selector(checkWasTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(deleteWasTapped), for: .touchUpInside)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        switchButtonsVisiblity(isLeftPan: sender.velocity(in: self).x < 0, isTriggeredByItself: true)
        cellWasPanned?()
    }

    private func switchButtonsVisiblity(isLeftPan: Bool, isTriggeredByItself: Bool = false) {
        var newState = state

        switch (isLeftPan, state) {
        case (false, .left), (true, .right):
            break
        case (false, .center):
            newState = .left
        case (false, .right), (true, .left):
            newState = .center
        case (true, .center):
            newState = .right
        }

        guard newState != state, !isStateChanging else { return }

        isStateChanging = true

        if isTriggeredByItself {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        animateNewState(newState)
    }

    private func animateNewState(_ newState: SwipableCellStateKind) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { self.applyNewState(newState) },
            completion: { [weak self] finished in
                guard finished else { return }

                self?.isStateChanging = false
                self?.state = newState
            }
        )
    }

    private func markAsCompleted() {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: nameLabel.text!)
        attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        mainView.alpha = 0.8
        nameLabel.attributedText = attributeString
    }

    private func applyNewState(_ state: SwipableCellStateKind) {
        if rightButton.isHidden != (state != .right) {
            rightButton.alpha = state == .right ? 1 : 0
            rightButton.isHidden = state != .right
        }

        if leftButton.isHidden != (state != .left) {
            leftButton.alpha = state == .left ? 1 : 0
            leftButton.isHidden = state != .left
        }

        mainStackView.layoutIfNeeded()
    }

    @objc private func checkWasTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        reset()
        checkAction?()
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
