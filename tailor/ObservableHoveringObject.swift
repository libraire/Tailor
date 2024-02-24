//
//  HoverObject.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import Foundation


class ObservableHoveringObject: ObservableObject {
    
    static let shared: ObservableHoveringObject = ObservableHoveringObject()
    
    @Published var activeHoveringIndex: Int? = nil
    
    
    func isHovering(index: Int) -> Bool {
        return index == activeHoveringIndex
    }
    
    private func exited(_ index: Int) { setCollection.remove(index) }
    
    private func entered(_ index: Int) { isHoveringTrafficLightFunction(index: index) }
    
    func sign(_ index: Int, hoverValue: Bool) {
        if (hoverValue) { entered(index) }
        else { exited(index) }
    }
    
    private var setCollection: Set<Int> = Set<Int>() {
        
        didSet {
            
            let filteredSet: Set<Int>.Element? = setCollection.max(by: { (lhs, rhs) in
                if (lhs < rhs) { return true }
                else { return false }
            })
            
            if let unwrappedValue: Int = filteredSet { activeHoveringIndex = unwrappedValue }
            else { activeHoveringIndex = nil }
            
        }
        
    }
    
    private func isHoveringTrafficLightFunction(index: Int) {
        
        if let unwrappedActiveHoveringIndex: Int = activeHoveringIndex {
            
            setCollection.insert(index)
            
            if (index >= unwrappedActiveHoveringIndex) { activeHoveringIndex = index }
            
        }
        else {
            activeHoveringIndex = index
            setCollection.insert(index)
            
        }
        
    }
}
