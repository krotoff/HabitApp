//
//  UserHabitListHeaderView.swift
//  Habit
//
//  Created by Andrei Krotov on 25/05/2023.
//

import UIKit

import ConstraintsKit

final class UserHabitListHeaderView: UICollectionReusableView {

    // MARK: - Internal types

    struct Model: Equatable {
        let models: [UserHabitListDayTrackingCell.Model]
        var selectedIndex: Int
    }

    // MARK: - Private properties

    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

    private let selectorView: UIView = {
        let view = UIView()
        view.backgroundColor = Asset.Colors.secondary.color
        view.layer.cornerRadius = 22

        return view
    }()
    private var model = Model(models: [], selectedIndex: 0)

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
        guard self.model != model else { return }

        self.model = model
        collectionView.reloadData()
        placeSelector()
    }

    // MARK: - Private methods

    private func setupUI() {
        [collectionView].forEach(addSubview)
        [selectorView].forEach(collectionView.addSubview)

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserHabitListDayTrackingCell.self, forCellWithReuseIdentifier: UserHabitListDayTrackingCell.reuseIdentifier)
        collectionView.canCancelContentTouches = false
        collectionView.clipsToBounds = false

        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0

        collectionView
            .align(with: self, insets: .init(top: 0, left: 0, bottom: 8, right: 0))

        selectorView.alpha = 0
        selectorView.layer.zPosition = -1
    }

    private func placeSelector() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: model.selectedIndex, section: 0)) else { return }

        collectionView.scrollToItem(at: IndexPath(item: model.selectedIndex + 1, section: 0), at: .right, animated: true)
        if selectorView.alpha == 0 {
            selectorView.frame = cell.frame
            UIView.animate(withDuration: 0.3) {
                self.selectorView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.selectorView.frame = cell.frame
            }
        }
    }
}

extension UserHabitListHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: UserHabitListDayTrackingCell.reuseIdentifier, for: indexPath)
    }
}

extension UserHabitListHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 44, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? UserHabitListDayTrackingCell else { return }

        cell.configure(with: model.models[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        model.selectedIndex = indexPath.item
        placeSelector()
    }
}
