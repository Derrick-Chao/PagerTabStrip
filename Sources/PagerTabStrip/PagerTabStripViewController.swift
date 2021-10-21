//
//  PagerTabStripViewController.swift
//  PagerTabStripFramework
//
//  Created by DerrickChao on 2021/7/30.
//

import UIKit

public protocol IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripViewController: PagerTabStripViewController) -> IndicatorInfo
}

public protocol PagerTabStripView: IndicatorInfoProvider where Self: UIViewController {}

public protocol PagerTabStripDataSource: AnyObject {
    func viewControllers(for pagerTabStripViewController: PagerTabStripViewController) -> [PagerTabStripView]
}

@objc public protocol PagerTabStripDelegate: AnyObject {
    @objc optional func pagerTabStripViewController(_ viewController: PagerTabStripViewController, didMoveTo index: Int)
}

open class PagerTabStripViewController: UIViewController {
    // MARK:- Outlets
    @IBOutlet public weak var containerView: UIScrollView!
    @IBOutlet public weak var buttonBarView: ButtonBarView!
    @IBOutlet public weak var buttonBarHeightAnchor: NSLayoutConstraint!
    
    // MARK:- Public property
    open weak var dataSource: PagerTabStripDataSource?
    open weak var delegate: PagerTabStripDelegate?
    open var pageWidth: CGFloat {
        return containerView.bounds.width
    }
    open var settings: ButtonBarViewSettings = ButtonBarViewSettings() {
        didSet {
            updateSettings()
        }
    }
    
    open var isScrollEnabled: Bool = true {
        didSet {
            containerView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public private(set) var viewControllers = [UIViewController]()
    public private(set) var currentIndex = 0
    
    // MARK:- Private property
//    private lazy var buttonBarView: ButtonBarView = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .horizontal
////        flowLayout.minimumLineSpacing = 20.0
//        flowLayout.minimumInteritemSpacing = settings.barInteritemSpacing
//        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: settings.barLeftRightInset, bottom: 0.0, right: settings.barLeftRightInset)
//        let buttonBarView = ButtonBarView(frame: .zero, collectionViewLayout: flowLayout)
//        buttonBarView.backgroundColor = settings.buttonBarBackgroundColor
//        return buttonBarView
//    }()
    private var cellWidths: [CGFloat] = []
    private var lastContentOffsetX: CGFloat = 0.0
    private var lastSize: CGSize = .zero
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.barInteritemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: settings.barLeftRightInset, bottom: 0.0, right: settings.barLeftRightInset)
        return flowLayout
    }()
    
    // MARK:- Life cycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        configureButtonBarView()
        configureContainerView()
        reloadViewControllers()
        let childViewController = viewControllers[currentIndex]
        addChild(childViewController)
        childViewController.view.frame = view.bounds
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(childViewController.view)
        NSLayoutConstraint.activate([
            childViewController.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            childViewController.view.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            childViewController.view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        ])
        didMove(toParent: self)
        calculateCellWidths()
        settings.updateSettings = { [weak self] in
            guard let self = self else { return }
            self.updateSettings()
        }
    }
    
    deinit {
        print("PagerTabStripViewController deinit.")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         測試下來不需添加 beginAppearanceTransition 與 endAppearanceTransition methods
         childViewController 也會自行呼叫 viewWillAppear, viewDidAppear, viewWillDisappear, viewDidDisappear 方法
         */
//        children.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        children.forEach { $0.endAppearanceTransition() }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        children.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
     
//        children.forEach { $0.endAppearanceTransition() }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateIfNeeded()
    }
    // MARK:- Layouts
    private func configureButtonBarView() {
        
        let barView = buttonBarView ?? {
            
            let buttonBarView = ButtonBarView(frame: .zero, collectionViewLayout: flowLayout)
            buttonBarView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttonBarView)
            let topAnchor: NSLayoutYAxisAnchor
            if #available(iOS 11.0, *) {
                topAnchor = view.safeAreaLayoutGuide.topAnchor
            } else {
                topAnchor = view.topAnchor
            }
            let heightAnchor = buttonBarView.heightAnchor.constraint(equalToConstant: settings.viewHeight)
            NSLayoutConstraint.activate([
                buttonBarView.topAnchor.constraint(equalTo: topAnchor),
                buttonBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                heightAnchor
            ])
            buttonBarHeightAnchor = heightAnchor
            return buttonBarView
        }()
        
        barView.backgroundColor = settings.buttonBarBackgroundColor
        buttonBarView = barView
        buttonBarView.setCollectionViewLayout(flowLayout, animated: false)
        buttonBarView.dataSource = self
        buttonBarView.delegate = self
    }
    
    private func configureContainerView() {
        
        let containerViewCheck = containerView ?? {
            let scrollView = UIScrollView(frame: CGRect(origin: .zero, size: view.bounds.size))
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return scrollView
        }()
        containerView = containerViewCheck
        containerView.backgroundColor = .clear
        containerView.bounces = true
        containerView.alwaysBounceHorizontal = true
        containerView.alwaysBounceVertical = false
        containerView.scrollsToTop = false
        containerView.delegate = self
        containerView.showsHorizontalScrollIndicator = false
        containerView.showsVerticalScrollIndicator = false
        containerView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            containerView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    // MARK:- Public methods
    open func updateIfNeeded() {
        if isViewLoaded && !lastSize.equalTo(containerView.bounds.size) {
            updateContent()
        }
    }
    
    open func pageOffsetForChild(index: Int) -> CGFloat {
        return CGFloat(index) * containerView.bounds.width
    }
    
    open func moveToViewController(at index: Int, animated: Bool) {
        guard isViewLoaded && index >= 0 && index < viewControllers.count else { return }
        
        let offsetX = pageOffsetForChild(index: index)
        containerView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: animated)
    }
    
    open func moveTo(viewController: PagerTabStripView, animated: Bool) {
        guard let index = viewControllers.firstIndex(of: viewController) else { return }
        moveToViewController(at: index, animated: animated)
    }
    
    open func updateContent() {
            
        if lastSize != containerView.bounds.size {
            
            lastSize = containerView.bounds.size
            containerView.contentOffset = CGPoint(x: pageOffsetForChild(index: currentIndex), y: 0.0)
        }
        containerView.contentSize = CGSize(width: CGFloat(viewControllers.count) * containerView.bounds.width, height: containerView.bounds.height)
        print("containerView.contentSize: \(containerView.contentSize)")
        print("containerView offsetX: \(containerView.contentOffset.x)")
        for (index, viewController) in viewControllers.enumerated() {
            
            let pageOffsetForChild = pageOffsetForChild(index: index)
            if abs(containerView.contentOffset.x - pageOffsetForChild) < containerView.bounds.width {
                
                if viewController.parent == nil {
                    
                    var leadingAnchor = containerView.leadingAnchor
                    if index > 0 {
                        leadingAnchor = viewControllers[index - 1].view.trailingAnchor
                        addChild(viewController)
                        viewController.view.frame = containerView.bounds
                        viewController.view.translatesAutoresizingMaskIntoConstraints = false
                        containerView.addSubview(viewController.view)
                        NSLayoutConstraint.activate([
                            viewController.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            viewController.view.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                            viewController.view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                            viewController.view.leadingAnchor.constraint(equalTo: leadingAnchor)
                        ])
                        viewController.didMove(toParent: self)
                    }
                }
            }
        }

        let futurePage = futurePageFor(contentOffsetX: containerView.contentOffset.x)
        print("futurePageFor: \(futurePage)")
        currentIndex = checkFuturePageValid(futurePage: futurePage)
        print("currentIndex: \(currentIndex)")
        
    }
    
    // MARK:- Private methods
    private func reloadViewControllers() {
        guard let dataSource = self.dataSource else {
            fatalError("DataSource must not be nil.")
        }
        
        viewControllers = dataSource.viewControllers(for: self)
        guard !viewControllers.isEmpty else {
            fatalError("viewControllers(for:) should provide at least one childViewController.")
        }
    }
    
    private func calculateCellWidths() {
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfCells = viewControllers.count
        var cellWidths: [CGFloat] = []
        for viewController in viewControllers {
            
            let indicatorInfoProvider = (viewController as! IndicatorInfoProvider)
            let indicatorInfo = indicatorInfoProvider.indicatorInfo(for: self)
            let label = UILabel()
            label.text = indicatorInfo.title
            label.font = settings.itemTextFont
            let size = label.intrinsicContentSize
            print("indicatorInfo: \(indicatorInfo.title), size: \(size)")
            let width = size.width + settings.itemLeftRightPadding * 2.0
            print("width: \(width)")
            cellWidths.append(width)
        }
        self.cellWidths = cellWidths
    }
    
    /**
     當滑動超過頁面的一半時，就準備切換到下一頁
     則以 lround 執行四捨五入來取得頁數，此頁數結果還需判斷是否在範圍內
     */
    private func futurePageFor(contentOffsetX: CGFloat) -> Int {
        let scrollPercentage = Double(contentOffsetX / pageWidth)
        print("scrollPercentage: \(scrollPercentage)")
        return lround(scrollPercentage)
    }
    
    /**
     檢查將要移動的頁面是否在合法範圍內
     */
    private func checkFuturePageValid(futurePage: Int) -> Int {
        
        if futurePage < 0 {
            return 0
        } else if futurePage > viewControllers.count - 1 {
            return viewControllers.count - 1
        }
        return futurePage
    }
    
    private func updateSettings() {
        print("updateSettings")
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = settings.barInteritemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: settings.barLeftRightInset, bottom: 0.0, right: settings.barLeftRightInset)
        buttonBarView.backgroundColor = settings.buttonBarBackgroundColor
        calculateCellWidths()
        buttonBarHeightAnchor?.isActive = false
        buttonBarHeightAnchor = buttonBarView.heightAnchor.constraint(equalToConstant: settings.viewHeight)
        buttonBarHeightAnchor?.isActive = true
        view.layoutIfNeeded()
        buttonBarView.reloadData()
    }
    
    // MARK:- Actions

}

extension PagerTabStripViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK:- UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonBarCell", for: indexPath) as! ButtonBarCell
        let indicatorInfoProvider = viewControllers[indexPath.item] as! IndicatorInfoProvider
        let indicatorInfo = indicatorInfoProvider.indicatorInfo(for: self)
        let isDisplayingTab = (currentIndex == indexPath.item)
        cell.setTitle(indicatorInfo.title)
        cell.setLayoutProperties(settings: settings, isDisplayingTab: isDisplayingTab)
        return cell
    }
    
    // MARK:- UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = indexPath.item
        currentIndex = index
        moveToViewController(at: index, animated: true)
        collectionView.reloadData()
        collectionView.performBatchUpdates {
            collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        } completion: { _ in }
    }
    
    // MARK:- UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cellWidths[indexPath.item]
        let size = CGSize(width: width, height: settings.viewHeight * 0.55)
        return size
    }
}

extension PagerTabStripViewController: UIScrollViewDelegate {
    // MARK:- UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === containerView {
            
            updateContent()
            lastContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === containerView {
            
            buttonBarView.reloadData()
            buttonBarView.performBatchUpdates {
                self.buttonBarView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            } completion: { _ in }
            delegate?.pagerTabStripViewController?(self, didMoveTo: currentIndex)
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView === containerView {
            
            (navigationController?.view ?? view)?.isUserInteractionEnabled = true
            updateContent()
            delegate?.pagerTabStripViewController?(self, didMoveTo: currentIndex)
        }
    }
}
