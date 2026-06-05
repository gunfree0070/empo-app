import SwiftUI

// Kept as a lightweight compatibility wrapper so the Xcode project
// file does not need to change while the update status moved into the
// Settings header.
struct UpdateCheckRow: View {
    let status: UpdateChecker.Status
    let onTapRetry: () -> Void

    var body: some View {
        EmptyView()
    }
}
