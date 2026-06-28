import SwiftUI

struct CancellationExperimentView: View {
    @StateObject private var viewModel = CancellationExperimentViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                experimentPicker
                ExperimentExplanationView(
                    mode: viewModel.selectedMode,
                    status: viewModel.status
                )
                ExperimentControlsView(
                    status: viewModel.status,
                    start: viewModel.startTask,
                    cancel: viewModel.cancelTask,
                    reset: viewModel.reset
                )
                ExperimentProgressView(
                    mode: viewModel.selectedMode,
                    status: viewModel.status,
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps,
                    latestLog: viewModel.latestLog,
                    stepColor: viewModel.stepColor(for:)
                )
                ExperimentTimelineView(logs: viewModel.logs)
            }
            .padding()
            .navigationTitle("Task Cancellation Lab")
        }
    }

    private var experimentPicker: some View {
        Picker("Experiment", selection: $viewModel.selectedMode) {
            ForEach(ExperimentMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .disabled(viewModel.status == .running)
        .onChange(of: viewModel.selectedMode) {
            viewModel.selectedModeDidChange()
        }
    }
}

#Preview {
    CancellationExperimentView()
}
