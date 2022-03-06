//
//  FormFloatingPanelLayout.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 08/09/21.
//

import UIKit
import FloatingPanel

class FormFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition = .bottom
    
    var initialState: FloatingPanelState = .full
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]{
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea)
        ]
    }
    
}
