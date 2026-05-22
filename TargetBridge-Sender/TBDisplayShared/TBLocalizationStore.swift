import Foundation

final class TBLocalizationStore: @unchecked Sendable {
    static let shared = TBLocalizationStore()

    private var cache: [String: [String: String]] = [:]
    private let lock = NSLock()

    private init() {}

    func string(_ key: String, language: TBDisplaySenderLanguage, values: [String: String] = [:]) -> String {
        let localized = dictionary(for: language)[key]
            ?? dictionary(for: .english)[key]
            ?? "[[\(key)]]"
        return apply(values: values, to: localized)
    }

    private func dictionary(for language: TBDisplaySenderLanguage) -> [String: String] {
        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[language.rawValue] {
            return cached
        }

        let dictionary = loadDictionary(for: language)
        cache[language.rawValue] = dictionary
        return dictionary
    }

    private func loadDictionary(for language: TBDisplaySenderLanguage) -> [String: String] {
        let fileName = language.fileStem
        for candidate in candidateURLs(for: fileName) {
            guard let data = try? Data(contentsOf: candidate),
                  let object = try? JSONSerialization.jsonObject(with: data),
                  let dict = object as? [String: String] else {
                continue
            }
            return dict
        }
        return [:]
    }

    private func candidateURLs(for fileName: String) -> [URL] {
        var urls: [URL] = []

        if let root = Bundle.main.url(forResource: fileName, withExtension: "json") {
            urls.append(root)
        }

        if let direct = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Languages") {
            urls.append(direct)
        }

        if let nested = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "TargetBridge-Shared/Languages") {
            urls.append(nested)
        }

        if let resources = Bundle.main.resourceURL {
            urls.append(resources.appendingPathComponent("\(fileName).json"))
            urls.append(resources.appendingPathComponent("Languages/\(fileName).json"))
            urls.append(resources.appendingPathComponent("TargetBridge-Shared/Languages/\(fileName).json"))
        }

        let fileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = fileURL
            .deletingLastPathComponent()   // TBDisplayShared
            .deletingLastPathComponent()   // TargetBridge-Sender
        urls.append(repoRoot.appendingPathComponent("TargetBridge-Shared/Languages/\(fileName).json"))

        return urls
    }

    private func apply(values: [String: String], to template: String) -> String {
        var output = template
        for (name, value) in values {
            output = output.replacingOccurrences(of: "%{\(name)}", with: value)
        }
        return output
    }
}
