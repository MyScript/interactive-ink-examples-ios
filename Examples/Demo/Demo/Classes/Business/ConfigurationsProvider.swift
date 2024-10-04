// Copyright @ MyScript. All rights reserved.

struct ConfigurationsProvider {

    static let defaultConfiguration = "interactivity"
    static let configProfileMetadataKey = "configuration-profile"
    private static let partTypeConfigurationsPath = Bundle.main.bundlePath.appending("/configurations/")

    static func configurationJson(from part: IINKContentPart) -> String? {
        let configurationPath = Self.configurationPath(from: part)
        guard let configurationJson = try? String(contentsOf: URL(fileURLWithPath: configurationPath)) else {
            return nil
        }
        return configurationJson
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
