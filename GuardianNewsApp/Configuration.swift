import Foundation

#if DEBUG
var Config = Configuration()
#else
let Config = Configuration()
#endif

struct Configuration {
    var apiKey: String = getApiKey()
}

func getApiKey(from provider: (String) -> Any? = { Bundle.main.object(forInfoDictionaryKey: $0) }) -> String {
    guard let object = provider("API_KEY"),
          let string = object as? String,
            !string.isEmpty else {
        print("🔑🔑🔑 Please add an api key in Config.xcconfig available at https://open-platform.theguardian.com")
        return ""
    }
    
    return string
}
