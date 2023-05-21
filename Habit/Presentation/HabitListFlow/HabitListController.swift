//
//  HabitListController.swift
//  Habit
//
//  Created by Andrei Krotov on 20/05/2023.
//

import UIKit.UIView

import CoordinatableViewController
import ConstraintsKit
import AnimatableViewsKit

final class HabitListController: CoordinatableViewController {

    // MARK: - Private types

    // MARK: - Internal properties

    let addButton = BouncableButton()

    // MARK: - Private properties

    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

    private let viewModel: HabitListViewModel

    // MARK: - Init

    init(viewModel: HabitListViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.viewModel.subscribeForEvents { [weak self] event in
            switch event {
            case .update:
                self?.collectionView.reloadData()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.updateModels()
    }

    // MARK: - Private methods

    private func setupUI() {
        [collectionView, addButton].forEach(view.addSubview)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = Asset.Colors.background.color
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserHabitCell.self, forCellWithReuseIdentifier: "UserHabitCell")
        collectionViewLayout.minimumLineSpacing = 16

        addButton.contentMode = .scaleAspectFit
        addButton.backgroundColor = Asset.Colors.secondary.color
        addButton.setImage(Asset.Images.add.image, for: .normal)
        addButton.layer.cornerRadius = 24
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = .init(width: 0, height: 4)
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOpacity = 0.5
        addButton.defaultShadowOpacity = addButton.layer.shadowOpacity
        addButton.addTarget(self, action: #selector(tappedAdd), for: .touchUpInside)

        collectionView
            .align(with: view)
        addButton
            .align(with: view, edges: [.right, .bottom], insets: .init(top: 0, left: 0, bottom: 64, right: 16))
            .equalsSize(to: .init(width: 48, height: 48))
    }

    @objc private func tappedAdd() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.tappedAdding(sourceView: addButton)
    }
}

extension HabitListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.models.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "UserHabitCell", for: indexPath) as! UserHabitCell
        cell.configure(with: viewModel.models[indexPath.item])

        return cell
    }
}

extension HabitListController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.bounds.width - 32, height: 48)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.models[indexPath.item].action?(collectionView.cellForItem(at: indexPath)!)
    }
}