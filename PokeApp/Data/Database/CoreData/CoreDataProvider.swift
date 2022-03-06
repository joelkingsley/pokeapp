//
//  CoreDataProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 09/09/21.
//

import UIKit
import CoreData

struct CoreDataProvider {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}
