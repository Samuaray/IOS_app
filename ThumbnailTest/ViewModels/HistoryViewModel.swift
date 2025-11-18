//
//  HistoryViewModel.swift
//  ThumbnailTest
//
//  Analysis history list management
//

import Foundation

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var analyses: [Analysis] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    @Published var searchText = ""
    @Published var selectedFilter: FilterOption = .all
    @Published var selectedCategory: String?

    // Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false

    private let pageLimit = 20

    // MARK: - Filter Options
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case published = "Published"
        case draft = "Draft"

        var apiValue: String? {
            switch self {
            case .all: return nil
            case .published: return "completed"
            case .draft: return "draft"
            }
        }
    }

    // MARK: - Load Analyses
    func loadAnalyses(page: Int = 1) async {
        if page == 1 {
            isLoading = true
        }

        errorMessage = nil

        do {
            let response = try await AnalysisService.shared.getAnalysisList(
                page: page,
                limit: pageLimit,
                status: selectedFilter.apiValue,
                category: selectedCategory,
                search: searchText.isEmpty ? nil : searchText
            )

            if page == 1 {
                analyses = response.analyses
            } else {
                analyses.append(contentsOf: response.analyses)
            }

            currentPage = response.pagination.page
            totalPages = response.pagination.totalPages
            hasMorePages = currentPage < totalPages

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        isRefreshing = false
    }

    // MARK: - Refresh
    func refresh() async {
        isRefreshing = true
        await loadAnalyses(page: 1)
    }

    // MARK: - Load More
    func loadMore() async {
        guard hasMorePages && !isLoading else { return }
        await loadAnalyses(page: currentPage + 1)
    }

    // MARK: - Search
    func search(_ text: String) {
        searchText = text
        Task {
            // Debounce search
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await loadAnalyses(page: 1)
        }
    }

    // MARK: - Apply Filter
    func applyFilter(_ filter: FilterOption) {
        selectedFilter = filter
        Task {
            await loadAnalyses(page: 1)
        }
    }

    // MARK: - Apply Category Filter
    func applyCategoryFilter(_ category: String?) {
        selectedCategory = category
        Task {
            await loadAnalyses(page: 1)
        }
    }

    // MARK: - Delete Analysis
    func deleteAnalysis(_ analysis: Analysis) async {
        do {
            try await AnalysisService.shared.deleteAnalysis(id: analysis.id)
            analyses.removeAll { $0.id == analysis.id }
        } catch {
            errorMessage = "Failed to delete analysis: \(error.localizedDescription)"
        }
    }

    // MARK: - Get Analysis
    func getAnalysis(id: String) async -> Analysis? {
        do {
            return try await AnalysisService.shared.getAnalysis(id: id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
