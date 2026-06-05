// Copyright @ MyScript. All rights reserved.

struct ConfigurationsProvider {

    enum ConfigurationError: Swift.Error {
        case configurationFileNotFound(path: String)
    }

    static let defaultConfiguration = "interactivity"
    static let configProfileMetadataKey = "configuration-profile"
    private static let partTypeConfigurationsPath = (Bundle.main.resourcePath ?? Bundle.main.bundlePath).appending("/configurations/")

    // Returns the configuration JSON for the given part, or `nil` when no custom profile is set.
    // Throws when metadata specifies a profile but the corresponding file cannot be read.
    static func configurationJson(from part: IINKContentPart) throws -> String? {
        let hasCustomProfile = Self.hasCustomProfile(part: part)
        let configurationPath = Self.configurationPath(from: part)
        guard let configurationJson = try? String(contentsOf: URL(fileURLWithPath: configurationPath)) else {
            if hasCustomProfile {
                throw ConfigurationError.configurationFileNotFound(path: configurationPath)
            }
            return nil
        }
        return configurationJson
    }

    private static func hasCustomProfile(part: IINKContentPart) -> Bool {
        guard let configurationFromMetadata = try? part.metadata?.string(forKey: Self.configProfileMetadataKey) else {
            return false
        }
        return !configurationFromMetadata.isEmpty
    }

    private static func configurationPath(from part: IINKContentPart) -> String {
        var configurationPath = Self.partTypeConfigurationsPath + Self.defaultConfiguration + ".json"
        // retrieve configuration from part metadata
        if let configurationFromMetadata = try? part.metadata?.string(forKey: Self.configProfileMetadataKey),
           !configurationFromMetadata.isEmpty {
            configurationPath = Self.partTypeConfigurationsPath + part.type + "/" + configurationFromMetadata + ".json"
        }
        return configurationPath
    }
}
