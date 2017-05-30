//
//  TutorialPageViewController.swift
//  inkcluded-405
//
//  Created by Christopher on 5/29/17.
//  Copied almost entirely from:
//  https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.darkGray
        appearance.currentPageIndicatorTintColor = UIColor.lightGray
        appearance.backgroundColor = UIColor.white
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTutorialViewController(num: "0"),
                self.newTutorialViewController(num: "1"),
                self.newTutorialViewController(num: "2"),
                self.newTutorialViewController(num: "3"),
                self.newTutorialViewController(num: "4"),
                self.newTutorialViewController(num: "5"),
                self.newTutorialViewController(num: "6"),
                self.newTutorialViewController(num: "7"),
                self.newTutorialViewController(num: "8")]
    }()
    
    private func newTutorialViewController(num: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "Tutorial\(num)Controller")
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
