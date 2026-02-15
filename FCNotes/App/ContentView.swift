import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var notesViewModel = NotesViewModel()
    @State private var folderViewModel = FolderViewModel()
    @State private var selectedTab = 0
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                mainContent
            } else {
                LockScreenView(authViewModel: authViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }

    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            // Notes Tab
            NoteListView(notesViewModel: notesViewModel, folderViewModel: folderViewModel)
                .tabItem {
                    Label("Notlar", systemImage: "note.text")
                }
                .tag(0)

            // Folders Tab
            FolderListView(
                notesViewModel: notesViewModel,
                folderViewModel: folderViewModel
            )
            .tabItem {
                Label("Klasörler", systemImage: "folder.fill")
            }
            .tag(1)

            // Settings Tab
            SettingsView(authViewModel: authViewModel)
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.fcSeaGreen)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    let authViewModel: AuthViewModel
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            List {
                Section("Güvenlik") {
                    HStack(spacing: 12) {
                        Image(systemName: authViewModel.biometricIcon)
                            .foregroundStyle(.fcSeaGreen)
                            .font(.title3)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(authViewModel.biometricName) Kilidi")
                                .font(.body)
                            Text("Uygulama açılışında kimlik doğrulama")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.fcSeaGreen)
                    }
                    .padding(.vertical, 4)
                }

                Section("Uygulama") {
                    Button {
                        authViewModel.lock()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.fcAccent)
                                .frame(width: 32)
                            Text("Uygulamayı Kilitle")
                                .foregroundStyle(.fcDarkText)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Hakkında") {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.fcLightBlue)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("FCNotes")
                                .font(.body.weight(.medium))
                            Text("Sürüm 1.0.0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ücretsiz & Reklamsız")
                                .font(.body.weight(.medium))
                            Text("Hiçbir reklam içermez, tamamen ücretsizdir")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.fcSeaGreen)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gizlilik")
                                .font(.body.weight(.medium))
                            Text("Verileriniz cihazınızda güvende kalır")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.fcLightGray)
            .navigationTitle("Ayarlar")
        }
    }
}
