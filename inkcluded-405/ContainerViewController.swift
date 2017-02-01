//
//  ContainerViewController.swift
//  inkcluded-405
//
//  Created by Nancy on 1/29/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

enum SlideOutState {
    case Collapsed
    case LeftPanelExpanded
}

class ContainerViewController: UIViewController {
    var centerNavigationController: UINavigationController!
    var groupsViewController: GroupsViewController!
    var currentState: SlideOutState = .Collapsed
    var leftViewController: SidePanelViewController?
    let centerPanelExpandedOffset: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupsViewController = UIStoryboard.groupsViewController()
        groupsViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: groupsViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(recognizer:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
}

extension ContainerViewController: GroupsViewControllerDelegate {
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if (notAlreadyExpanded) {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            
            addChildSidePanelController(sidePanelController: leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let leftToRight = (recognizer.velocity(in: view).x > 0)
        switch(recognizer.state) {
            case .began:
                if (leftToRight && currentState == .Collapsed) {
                    addLeftPanelViewController()
                }
            case .changed:
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            case .ended:
                if (leftViewController != nil) {
                    // animate the side panel open or closed based on whether the view has moved more or less than halfway
                    let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                    animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
                }
            default:
                break
        }
    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    
    class func groupsViewController() -> GroupsViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "GroupsViewController") as? GroupsViewController
    }
    
}

