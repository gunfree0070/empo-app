import SwiftUI

/// Settings row that surfaces `UpdateChecker.Status`.
///
/// Mirrors the visual shape of the other About-section rows
/// (`Label` icon + title with a trailing arrow when tappable) so it
/// sits flush in the same `Section`. The row is only ever shown when
/// `UpdateChecker.isSideloadOrDevBuild` is true; the platform
/// handles updates on App Store / TestFlight installs and surfacing
/// our checker there would be redundant and confusing.
///
/// The row is rendered as a plain Label when the build is up to
/// date or the check hasn't run yet, and as a Link when an update
/// is available so taps deep-link to the GitHub release page where
/// the IPA is attached. The "failed" state is rendered as a button
/// that retries via the `onTapRetry` closure (which the parent
/// wires to `UpdateChecker.checkNow()`).
struct UpdateCheckRow: View {
    let status: UpdateChecker.Status
    let onTapRetry: () -> Void

    var body: some View {
        switch status {
        case .available(let latest, let url):
            Link(destination: url) {
                Label {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Update available")
                            Text("v\(latest)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.forward")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.brand)
                }
            }
            .tint(.primary)

        case .upToDate(let current):
            Label {
                HStack {
                    Text("Up to date")
                    Spacer()
                    Text("v\(current)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.secondary)
            }

        case .checking:
            Label {
                HStack {
                    Text("Checking for updates\u{2026}")
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                }
            } icon: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
            }

        case .failed(let message):
            Button(action: onTapRetry) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Couldn't check for updates")
                            Spacer()
                            Text("Retry")
                                .font(.caption)
                                .foregroundStyle(.brand)
                        }
                        Text(message)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

        case .unknown:
            // Render nothing while the initial fetch is still
            // pending; avoids a flash of a placeholder row before
            // the .task fires on view appear.
            EmptyView()
        }
    }
}
