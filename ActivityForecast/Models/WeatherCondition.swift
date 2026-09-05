//
//  WeatherCondition.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// A WMO 4677 weather interpretation code, as delivered in the forecast feed's
/// `weathercode` array, turned into something a person can read.
public struct WeatherCondition: Hashable, Sendable {

    public let code: Int

    public init(code: Int) {
        self.code = code
    }

    /// WMO code groups. Codes not in the table fall through to `unknown`.
    private enum Code {
        static let clearSky = 0
        static let mainlyClear = 1
        static let partlyCloudy = 2
        static let overcast = 3
        static let fog = 45
        static let depositingRimeFog = 48
        static let lightDrizzle = 51
        static let drizzle = 53
        static let denseDrizzle = 55
        static let lightFreezingDrizzle = 56
        static let freezingDrizzle = 57
        static let lightRain = 61
        static let rain = 63
        static let heavyRain = 65
        static let lightFreezingRain = 66
        static let freezingRain = 67
        static let lightSnow = 71
        static let snow = 73
        static let heavySnow = 75
        static let snowGrains = 77
        static let lightRainShowers = 80
        static let rainShowers = 81
        static let violentRainShowers = 82
        static let lightSnowShowers = 85
        static let snowShowers = 86
        static let thunderstorm = 95
        static let thunderstormWithLightHail = 96
        static let thunderstormWithHail = 99
    }

    public var description: String {
        switch code {
            case Code.clearSky: return "Clear sky"
            case Code.mainlyClear: return "Mainly clear"
            case Code.partlyCloudy: return "Partly cloudy"
            case Code.overcast: return "Overcast"
            case Code.fog, Code.depositingRimeFog: return "Fog"
            case Code.lightDrizzle: return "Light drizzle"
            case Code.drizzle: return "Drizzle"
            case Code.denseDrizzle: return "Dense drizzle"
            case Code.lightFreezingDrizzle, Code.freezingDrizzle: return "Freezing drizzle"
            case Code.lightRain: return "Light rain"
            case Code.rain: return "Rain"
            case Code.heavyRain: return "Heavy rain"
            case Code.lightFreezingRain, Code.freezingRain: return "Freezing rain"
            case Code.lightSnow: return "Light snow"
            case Code.snow: return "Snow"
            case Code.heavySnow: return "Heavy snow"
            case Code.snowGrains: return "Snow grains"
            case Code.lightRainShowers: return "Light showers"
            case Code.rainShowers: return "Rain showers"
            case Code.violentRainShowers: return "Violent showers"
            case Code.lightSnowShowers: return "Light snow showers"
            case Code.snowShowers: return "Snow showers"
            case Code.thunderstorm: return "Thunderstorm"
            case Code.thunderstormWithLightHail, Code.thunderstormWithHail: return "Thunderstorm with hail"
            default: return "Unsettled"
        }
    }

    public var systemImage: String {
        switch code {
            case Code.clearSky: return "sun.max.fill"
            case Code.mainlyClear: return "sun.min.fill"
            case Code.partlyCloudy: return "cloud.sun.fill"
            case Code.overcast: return "cloud.fill"
            case Code.fog, Code.depositingRimeFog: return "cloud.fog.fill"
            case Code.lightDrizzle, Code.drizzle, Code.denseDrizzle: return "cloud.drizzle.fill"
            case Code.lightFreezingDrizzle, Code.freezingDrizzle,
                 Code.lightFreezingRain, Code.freezingRain: return "cloud.sleet.fill"
            case Code.lightRain, Code.rain: return "cloud.rain.fill"
            case Code.heavyRain: return "cloud.heavyrain.fill"
            case Code.lightSnow, Code.snow, Code.heavySnow, Code.snowGrains: return "cloud.snow.fill"
            case Code.lightRainShowers, Code.rainShowers, Code.violentRainShowers: return "cloud.sun.rain.fill"
            case Code.lightSnowShowers, Code.snowShowers: return "wind.snow"
            case Code.thunderstorm, Code.thunderstormWithLightHail,
                 Code.thunderstormWithHail: return "cloud.bolt.rain.fill"
            default: return "cloud.fill"
        }
    }
}
