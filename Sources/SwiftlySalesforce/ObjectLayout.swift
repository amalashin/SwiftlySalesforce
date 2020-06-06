//
//  SFDCLayout.swift
//  SFDC Tool
//
//  Created by Alexey Malashin on 28.05.2020.
//  Copyright © 2020 Alexey Malashin. All rights reserved.
//

import Foundation

public struct ObjectPicklistValue: Codable {
    public var label: String
    public var validFor: String?
    public var value: String
}

public struct ObjectLayoutComponentDetails: Codable {
    public var inlineHelpText: String?
    public var label: String
    public var name: String
    public var controllerName: String?
    public var picklistValues: [ObjectPicklistValue]
}

public struct ObjectLayoutComponent: Codable {
    public var type: String
    public var value: String?
    public var details: ObjectLayoutComponentDetails?
}

public struct ObjectLayoutItem: Codable {
    public var label: String
    public var required: Bool
    public var layoutComponents: [ObjectLayoutComponent]
}

public struct ObjectLayoutRow: Codable {
    public var numItems: Int
    public var layoutItems: [ObjectLayoutItem]
}

public struct ObjectLayoutSection: Codable {
    public var layoutSectionId: String
    public var parentLayoutId: String
    public var rows: Int
    public var heading: String
    public var columns: Int
    public var layoutRows: [ObjectLayoutRow]
}

public struct ObjectLayout: Codable {
    public var id: String
    public var detailLayoutSections: [ObjectLayoutSection]
}
