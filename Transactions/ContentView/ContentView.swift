//
//  ContentView.swift
//  Transactions
//
//  Created by Eduardo García on 09/12/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var transactionsView: some View {
        Group {
            Text("Transactions")
                .font(.title)
                . fontWeight(.regular)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(TransactionActions.allCases) { action in
                    Button(action: {
                        viewModel.execute(transactionAction: action)
                    }) {
                        Text(action.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(10)
                            .background(viewModel.shouldEnableTransactionButton(action: action) ? Color.blue : Color.init(cgColor: UIColor.lightGray.cgColor))
                            .foregroundColor(.white)
                    }
                    .disabled(!viewModel.shouldEnableTransactionButton(action: action))
                    .cornerRadius(5)
                }
            }
            .frame(width: .infinity)
            .padding()
        }
    }
    
    var actionsView: some View {
        Group {
            Text("Actions")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(Actions.allCases) {  action in
                    Button(action: {
                        viewModel.setAction(action)
                    }) {
                        Text(action.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(10)
                            .background(viewModel.actionSelected == action ? Color.blue : Color.init(cgColor: UIColor.lightGray.cgColor))
                            .foregroundColor(.white)
                    }
                    .cornerRadius(5)
                    Spacer()
                }
            }
            .frame(width: .infinity)
            .padding()
        }
    }
    
    var fieldsSection: some View {
        Group {
            if viewModel.actionSelected != .count {
                TextField("Key",
                          text: $viewModel.key)
                .autocapitalization(.none)
            }
            
            if viewModel.showValueTextField {
                TextField("Value",
                          text: $viewModel.dataValue)
                .autocapitalization(.none)
            }
            
            Spacer()
            Button("Execute") {
                viewModel.execute()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.executeButtonIsEnabled)
            Spacer()
        }
    }
    
    var consoleSection: some View {
        Group {
            if !viewModel.consoleLog.isEmpty {
                Text("Output:")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView {
                    Text(viewModel.consoleLog)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .border(.black)
                .cornerRadius(5)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                transactionsView
                actionsView
                fieldsSection
                consoleSection
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .navigationTitle("Mobile Transactional")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        ContentView(viewModel: .init(transactionDataRepository: TransactionsDataRepository(context: viewContext)))
    }
}
