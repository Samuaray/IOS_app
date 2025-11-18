//
//  HistoryView.swift
//  ThumbnailTest
//
//  Analysis history list with search and filters
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedAnalysis: Analysis?
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.analyses.isEmpty {
                    // Initial loading
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.analyses.isEmpty && !viewModel.isLoading {
                    // Empty state
                    EmptyHistoryView()
                } else {
                    // History list
                    ScrollView {
                        LazyVStack(spacing: Constants.Spacing.spacing12) {
                            // Search bar
                            SearchBar(text: $viewModel.searchText, onCommit: {
                                viewModel.search(viewModel.searchText)
                            })
                            .padding(.horizontal)
                            .padding(.top, Constants.Spacing.spacing8)

                            // Filter chips
                            FilterChipsView(viewModel: viewModel)
                                .padding(.horizontal)

                            // Analysis list
                            ForEach(viewModel.analyses) { analysis in
                                AnalysisHistoryRow(analysis: analysis) {
                                    selectedAnalysis = analysis
                                }
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteAnalysis(analysis)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }

                            // Load more indicator
                            if viewModel.hasMorePages {
                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                            }
                        }
                        .padding(.bottom, Constants.Spacing.spacing16)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Constants.Colors.primaryRed)
                    }
                }
            }
            .sheet(item: $selectedAnalysis) { analysis in
                NavigationStack {
                    AnalysisResultsView(analysis: analysis)
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .task {
                if viewModel.analyses.isEmpty {
                    await viewModel.loadAnalyses()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search by title...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit(onCommit)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onCommit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(Constants.Spacing.spacing12)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
}

// MARK: - Filter Chips
struct FilterChipsView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.spacing8) {
                ForEach(HistoryViewModel.FilterOption.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.applyFilter(filter)
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Constants.Typography.bodySmall)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Constants.Colors.textPrimary)
                .padding(.horizontal, Constants.Spacing.spacing16)
                .padding(.vertical, Constants.Spacing.spacing8)
                .background(isSelected ? Constants.Colors.primaryRed : Constants.Colors.cardBackground)
                .cornerRadius(Constants.CornerRadius.full)
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    ForEach(HistoryViewModel.FilterOption.allCases, id: \.self) { filter in
                        Button(action: {
                            viewModel.applyFilter(filter)
                            dismiss()
                        }) {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                Spacer()
                                if viewModel.selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Constants.Colors.primaryRed)
                                }
                            }
                        }
                    }
                }

                Section("Category") {
                    Button(action: {
                        viewModel.applyCategoryFilter(nil)
                        dismiss()
                    }) {
                        HStack {
                            Text("All Categories")
                                .foregroundColor(Constants.Colors.textPrimary)
                            Spacer()
                            if viewModel.selectedCategory == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Constants.Colors.primaryRed)
                            }
                        }
                    }

                    ForEach(Constants.categories, id: \.self) { category in
                        Button(action: {
                            viewModel.applyCategoryFilter(category)
                            dismiss()
                        }) {
                            HStack {
                                Text(category)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                Spacer()
                                if viewModel.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Constants.Colors.primaryRed)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Empty State
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: Constants.Spacing.spacing24) {
            Spacer()

            Image(systemName: "photo.stack")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            VStack(spacing: Constants.Spacing.spacing8) {
                Text("No Analyses Yet")
                    .font(Constants.Typography.headlineSmall)
                    .fontWeight(.semibold)

                Text("Create your first thumbnail analysis\nto see it here")
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HistoryView()
}
