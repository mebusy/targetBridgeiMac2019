import SwiftUI

struct TBDisplaySenderContentView: View {
    @ObservedObject var service: TBDisplaySenderService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(TBDisplaySenderL10n.appName(service.language))
                        .font(.title2.weight(.semibold))
                    Text(TBDisplaySenderL10n.appSubtitle(service.language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                GroupBox(TBDisplaySenderL10n.connectionGroup(service.language)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text(TBDisplaySenderL10n.availableTBInterfaces(service.language))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(service.bridgeSummaryText)
                                .font(.system(.body, design: .monospaced))
                                .multilineTextAlignment(.trailing)
                        }

                        Text(TBDisplaySenderL10n.multiSessionHint(service.language))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            Button(TBDisplaySenderL10n.addSessionButton(service.language)) {
                                service.addSession()
                            }

                            Button(TBDisplaySenderL10n.refreshIPButton(service.language)) {
                                service.refreshBridgeInterfaces()
                            }

                            Button(TBDisplaySenderL10n.stopAllButton(service.language)) {
                                service.stopAll()
                            }
                            .disabled(!service.anyConnected)

                            Spacer()

                            Text(service.summaryStatusText())
                                .foregroundStyle(service.anyStreaming ? .green : .secondary)
                        }
                    }
                }

                GroupBox(TBDisplaySenderL10n.languageGroup(service.language)) {
                    Picker(TBDisplaySenderL10n.languageGroup(service.language), selection: $service.language) {
                        ForEach(TBDisplaySenderLanguage.allCases) { language in
                            Text(language.pickerTitle).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                ForEach(service.sessions) { session in
                    TBDisplaySenderSessionCard(service: service, session: session)
                }

                GroupBox(TBDisplaySenderL10n.modeGroup(service.language)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(TBDisplaySenderL10n.modeLine1(service.language))
                        Text(TBDisplaySenderL10n.modeLine2(service.language))
                        Text(TBDisplaySenderL10n.modeLine3(service.language))
                        Text(TBDisplaySenderL10n.modeLine4(service.language))
                        Text(TBDisplaySenderL10n.modeLine5(service.language))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Toggle(TBDisplaySenderL10n.showMenuBarIcon(service.language), isOn: $service.showsMenuBarIcon)
                Toggle(TBDisplaySenderL10n.largeCursor(service.language), isOn: $service.largeCursor)
                    .disabled(service.anyConnected)

                HStack {
                    Spacer()
                    Text("\(TBDisplaySenderL10n.versionLabel(service.language)) \(TBDisplaySenderBuildInfo.versionDisplay)")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
        }
        .task {
            service.refreshBridgeInterfaces()
        }
    }
}

private struct TBDisplaySenderSessionCard: View {
    @ObservedObject var service: TBDisplaySenderService
    @ObservedObject var session: TBDisplaySenderSession

    var body: some View {
        GroupBox(service.sessionTitle(for: session)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(TBDisplaySenderL10n.localTBIP(service.language))
                        .foregroundStyle(.secondary)
                        .frame(width: 132, alignment: .leading)
                    Picker(TBDisplaySenderL10n.localTBIP(service.language), selection: $session.localTBIP) {
                        Text(TBDisplaySenderL10n.notDetected(service.language)).tag("")
                        ForEach(service.bridgeInterfaces) { bridgeInterface in
                            Text(bridgeInterface.displayText).tag(bridgeInterface.ip)
                        }
                    }
                    .disabled(session.isConnected || session.isStreaming)
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(TBDisplaySenderL10n.discoveredReceiver(service.language))
                        .foregroundStyle(.secondary)
                        .frame(width: 132, alignment: .leading)
                    Picker(TBDisplaySenderL10n.discoveredReceiver(service.language), selection: $session.selectedReceiverID) {
                        Text(TBDisplaySenderL10n.manualReceiverEntry(service.language)).tag("")
                        ForEach(service.discoveredReceivers) { receiver in
                            Text(receiver.displayText).tag(receiver.id)
                        }
                    }
                    .onChange(of: session.selectedReceiverID) { _, newValue in
                        guard let receiver = service.discoveredReceivers.first(where: { $0.id == newValue }) else { return }
                        service.applyDiscoveredReceiver(receiver, to: session)
                    }
                    .disabled(session.isConnected || session.isStreaming)
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(TBDisplaySenderL10n.receiverIP(service.language))
                        .foregroundStyle(.secondary)
                        .frame(width: 132, alignment: .leading)
                    TextField("169.254.x.x", text: $session.receiverIP)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .disabled(session.isConnected || session.isStreaming)
                }

                HStack(spacing: 10) {
                    Button(session.isConnected ? TBDisplaySenderL10n.stopButton(service.language) : TBDisplaySenderL10n.connectButton(service.language)) {
                        if session.isConnected {
                            session.stop()
                        } else {
                            session.connect()
                        }
                    }
                    .disabled(!session.isConnected && (trimmedReceiverIP.isEmpty || session.localTBIP.isEmpty))

                    Button(TBDisplaySenderL10n.removeSessionButton(service.language)) {
                        service.removeSession(session)
                    }
                    .disabled(service.sessions.count == 1 || session.isConnected || session.isStreaming)

                    Spacer()

                    Text(session.statusText)
                        .foregroundStyle(session.isStreaming ? .green : .secondary)
                }

                Picker(TBDisplaySenderL10n.captureSource(service.language), selection: $session.captureSource) {
                    ForEach(TBDisplayCaptureSource.allCases) { source in
                        Text(source.title(service.language)).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(session.isConnected || session.isStreaming)

                Picker(TBDisplaySenderL10n.streamProfile(service.language), selection: $session.capturePreset) {
                    ForEach(TBDisplayCapturePreset.allCases) { preset in
                        Text("\(preset.title(service.language)) · \(preset.description)").tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(session.isConnected || session.isStreaming)

                Text(TBDisplaySenderL10n.streamHint1(service.language))
                Text(TBDisplaySenderL10n.streamHint2(service.language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if !service.discoveredReceivers.isEmpty {
                    Text(TBDisplaySenderL10n.discoveryHint(service.language))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    infoRow(TBDisplaySenderL10n.receiverLabel(service.language), session.receiverPanelText)
                    infoRow(TBDisplaySenderL10n.virtualDisplayLabel(service.language), session.virtualDisplayText)
                    infoRow(TBDisplaySenderL10n.streamLabel(service.language), session.streamResolutionText)
                    infoRow(TBDisplaySenderL10n.fpsLabel(service.language), "\(session.senderFPS)")
                    infoRow("Capture", session.captureDisplayText)
                    infoRow("State", session.displayStateText)
                }
            }
        }
    }

    private var trimmedReceiverIP: String {
        session.receiverIP.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 132, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
        }
    }
}
