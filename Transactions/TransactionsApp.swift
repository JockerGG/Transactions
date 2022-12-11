//
//  TransactionsApp.swift
//  Transactions
//
//  Created by Eduardo García on 09/12/22.
//

import SwiftUI

@main
struct TransactionsApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(
                transactionDataRepository: TransactionsDataRepository(
                    context: persistenceController.container.viewContext
                )
            ))
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
