//
//  WeatherFormat.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Turns the forecast feed's raw metric values into short, locale-correct strings.
///
/// The feed is always metric because `LocationForecastUri` never asks for unit
/// conversion. Wrapping each value in a `Measurement` of its known source unit lets
/// Foundation render it in whatever the reader's locale prefers — so the same
/// response shows 19° C in Berlin and 66° F in Boston without a branch anywhere.
public enum WeatherFormat {

    public static func temperature(celsius: Double) -> String {
        Measurement(value: celsius, unit: UnitTemperature.celsius)
            .formatted(.measurement(width: .narrow, usage: .weather))
    }

    public static func rainfall(millimetres: Double) -> String {
        Measurement(value: millimetres, unit: UnitLength.millimeters)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .rainfall,
                    numberFormatStyle: .number.precision(.fractionLength(0...1))
                )
            )
    }

    public static func snowfall(centimetres: Double) -> String {
        Measurement(value: centimetres, unit: UnitLength.centimeters)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .snowfall,
                    numberFormatStyle: .number.precision(.fractionLength(0...1))
                )
            )
    }

    public static func windSpeed(kilometresPerHour: Double) -> String {
        Measurement(value: kilometresPerHour, unit: UnitSpeed.kilometersPerHour)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .asProvided,
                    numberFormatStyle: .number.precision(.fractionLength(0))
                )
            )
    }

    public static func hours(_ hours: Double) -> String {
        let value = hours.formatted(.number.precision(.fractionLength(1)))
        return "\(value) h"
    }

    public static func probability(_ percentage: Int) -> String {
        Double(percentage).formatted(.percent.scale(1).precision(.fractionLength(0)))
    }

    public static func ratio(_ ratio: Double) -> String {
        let value = ratio.formatted(.number.precision(.fractionLength(1)))
        return "\(value)×"
    }

    public static func index(_ index: Double) -> String {
        index.formatted(.number.precision(.fractionLength(1)))
    }
}
