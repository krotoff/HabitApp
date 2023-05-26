//
//  UnderlinedTextFieldWithHeader.swift
//  Habit
//
//  Created by Andrei Krotov on 23/05/2023.
//

import UIKit

import ConstraintsKit

final class UnderlinedTextFieldWithHeader: UIView {

    // MARK: - Private properties

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = Asset.Colors.text1.color.withAlphaComponent(0.5)
        label.alpha = 0
        
        return label
    }()
    private let headerFakeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = Asset.Colors.text1.color.withAlphaComponent(0.5)
        label.alpha = 1

        return label
    }()
    private let textField: UITextField = {
        let field = UITextField()
        field.textColor = Asset.Colors.text1.color
        field.font = .systemFont(ofSize: 24, weight: .bold)
        field.backgroundColor = .clear
        field.tintColor = Asset.Colors.text1.color.withAlphaComponent(0.5)

        return field
    }()
    private let textFieldUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = Asset.Colors.text1.color.withAlphaComponent(0.5)
        view.layer.cornerRadius = 1

        return view
    }()
    private var setOnce = false

    // MARK: - Init

    init(title: String, text: String) {
        headerLabel.text = title
        headerFakeLabel.text = title
        textField.text = text

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !setOnce, bounds.width * bounds.height > 0 {
            setOnce = true

            updateHeader(isBig: false) { [weak self] in
                self?.headerLabel.alpha = 1
                self?.headerFakeLabel.alpha = 0
            }
        }
    }

    // MARK: - Internal methods

    func setTextFieldDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }

    // MARK: - Private methods

    private func setupUI() {
        [headerFakeLabel, headerLabel, textField, textFieldUnderlineView].forEach(addSubview)

        headerLabel
            .align(with: self, edges: [.right, .left, .bottom])
        headerFakeLabel
            .align(with: self, edges: [.right, .left, .top])
        textField
            .align(with: self, insets: .init(top: 15, left: 0, bottom: 0, right: 0))
            .equalsHeight(to: 31)
        textFieldUnderlineView
            .align(with: textField, edges: [.left, .right, .bottom])
            .equalsHeight(to: 2)

        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }

    @objc private func didBeginEditing() {
        updateHeader(isBig: false)
    }

    @objc private func didEndEditing() {
        updateHeader(isBig: textField.text?.isEmpty ?? true)
    }

    private func updateHeader(isBig: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.headerLabel.transform = isBig ? .identity : .init(scaleX: 0.5, y: 0.5)
                self.headerLabel.frame.origin = isBig ? self.textField.frame.origin : .zero
            },
            completion: { finished in
                guard finished else { return }

                completion?()
            }
        )
    }
}
