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

        self.viewModel.subscribeForEvents { [weak self] in self?.handleEvent($0) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionViewLayout.invalidateLayout()
    }

    // MARK: - Private methods

    private func setupUI() {
        [collectionView, addButton].forEach(view.addSubview)

        collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = Asset.Colors.background.color
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserHabitCell.self, forCellWithReuseIdentifier: "UserHabitCell")
        collectionView.register(
            UserHabitListHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "UserHabitListHeaderView"
        )
        collectionView.canCancelContentTouches = false
        collectionViewLayout.minimumLineSpacing = 16
        collectionViewLayout.minimumInteritemSpacing = 16

        addButton.contentMode = .scaleAspectFit
        addButton.setImage(Asset.Images.add.image, for: .normal)
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = .init(width: 0, height: 4)
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOpacity = 0.5
        addButton.defaultShadowOpacity = addButton.layer.shadowOpacity
        addButton.addTarget(self, action: #selector(tappedAdd), for: .touchUpInside)

        collectionView
            .align(with: view)
        addButton
            .align(
                with: view,
                edges: [.right, .bottom],
                insets: .init(top: 0, left: 0, bottom: 48, right: 16),
                isInSafeArea: true
            )
            .equalsSize(to: .init(width: 64, height: 64))
    }

    @objc private func tappedAdd() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.tappedAdding(sourceView: addButton)
    }

    private func handleEvent(_ event: HabitListViewModel.LogicEventKind) {
        switch event {
        case let .update(kind):
            switch kind {
            case .insert(let indexPath):
                collectionView.insertItems(at: [indexPath])
            case .delete(let indexPath):
                collectionView.deleteItems(at: [indexPath])
            case .update(let indexPath):
                collectionView.reloadItems(at: [indexPath])
            case .move(let from, let to):
                collectionView.moveItem(at: from, to: to)
            case .fullReload:
                collectionView.reloadData()
            }
        }
    }

    private func resetCells(except cell: UserHabitCell?) {
        collectionView.visibleCells.forEach {
            guard let visibleCell = $0 as? UserHabitCell, cell != visibleCell else { return }

            visibleCell.reset()
        }
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
        cell.subscribeOnPanAction { [weak self] in
            self?.resetCells(except: cell)
        }

        return cell
    }
}

extension HabitListController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        if UIDevice.current.orientation.isLandscape {
            return .init(width: (availableWidth - self.collectionViewLayout.minimumInteritemSpacing) / 2, height: 64)
        } else {
            return .init(width: availableWidth, height: 64)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        resetCells(except: nil)
        let cell = collectionView.cellForItem(at: indexPath) as? UserHabitCell
        viewModel.models[indexPath.item].action?(cell!.viewToScale())
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "UserHabitListHeaderView",
            for: indexPath
        ) as! UserHabitListHeaderView
        view.configure(with: viewModel.headerModel)

        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 72)
    }
}
