//
//  AdviceWidgetBundle.swift
//  AdviceWidget
//
//  Created by Kamil Caglar on 06/02/2023.
//

import WidgetKit
import SwiftUI

@main
struct AdviceWidgetBundle: WidgetBundle {
    var body: some Widget {
        AdviceWidget()
        AdviceWidgetLiveActivity()
    }
}
