//
//  HabitEditingController.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit

import CoordinatableViewController
import ConstraintsKit
import AnimatableViewsKit

final class HabitEditingController: CoordinatableViewController {

    // MARK: - Private types

    private struct Constants {
        static let buttonSide: CGFloat = 48
        static let buttonInset: CGFloat = 8
        static let textFieldInset: CGFloat = 16
        static let separatorHeight: CGFloat = 2
    }

    // MARK: - Private properties

    private let closeButton = BouncableButton()

    private let nameTextField: UITextField = {
        let field = UITextField()
        field.textColor = Asset.Colors.text1.color
        field.font = .systemFont(ofSize: 24, weight: .bold)

        return field
    }()
    private let nameTextFieldUnderlineView = UIView()

    private let viewModel: HabitEditingViewModel

    // MARK: - Init

    init(viewModel: HabitEditingViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

//        modalPresentationStyle = .overFullScreen
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        nameTextField.becomeFirstResponder()
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = Asset.Colors.secondary.color

        [closeButton, nameTextField, nameTextFieldUnderlineView].forEach(view.addSubview)

        closeButton.setImage(Asset.Images.close.image, for: .normal)

        nameTextField.text = viewModel.model.name
        nameTextField.delegate = self
        nameTextField.backgroundColor = .clear
        nameTextField.tintColor = Asset.Colors.text1.color.withAlphaComponent(0.5)

        nameTextFieldUnderlineView.backgroundColor = Asset.Colors.text1.color.withAlphaComponent(0.5)
        nameTextFieldUnderlineView.layer.cornerRadius = Constants.separatorHeight / 2

        closeButton
            .align(
                with: view,
                edges: [.right, .top],
                insets: .init(top: Constants.buttonInset, left: 0, bottom: 0, right: Constants.buttonInset),
                isInSafeArea: true
            )
            .equalsSize(to: .init(width: Constants.buttonSide, height: Constants.buttonSide))
        nameTextField
            .align(
                with: view,
                edges: [.left, .right],
                insets: .init(top: 0, left: Constants.textFieldInset, bottom: 0, right: Constants.textFieldInset)
            )
            .spacingToBottom(of: closeButton)
        nameTextFieldUnderlineView
            .align(with: nameTextField, edges: [.left, .right, .bottom])
            .equalsHeight(to: Constants.separatorHeight)

        closeButton.addTarget(self, action: #selector(tappedClose), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedClose() {
        view.endEditing(true)
        viewModel.tappedClose()
    }

    @objc private func tappedAnywhere() {
        view.endEditing(true)
    }
}

extension HabitEditingController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.updateName(textField.text!)
    }
}
