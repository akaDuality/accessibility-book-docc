# Charts

How to make charts and diagrams accessible to VoiceOver when iOS only sees a picture.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

## The problem

Charts are among the most complex elements for adaptation. iOS doesn't know what's drawn on the screen: for the system a chart is just a picture. Neither the bars of a histogram, nor the segments of a pie chart, nor the points on a line chart are UIKit elements. VoiceOver can't focus on any part of the chart, because for it there are no parts.

For a blind user to be able to work with the chart's data, you need to create accessible elements manually.

## Custom elements

Every data point on the chart needs to be represented as a `UIAccessibilityElement`. This is an object that isn't displayed on the screen but is available to VoiceOver.

```swift
let chartView = ChartView()

var elements: [UIAccessibilityElement] = []

for dataPoint in dataPoints {
    let element = UIAccessibilityElement(accessibilityContainer: chartView)
    element.accessibilityLabel = dataPoint.label
    element.accessibilityValue = "\(dataPoint.value) rubles"
    element.accessibilityFrameInContainerSpace = dataPoint.barFrame
    elements.append(element)
}

chartView.accessibilityElements = elements
```

Note the `accessibilityFrameInContainerSpace` — these are the coordinates of the element inside the container, not in screen coordinates. The property is more convenient than `accessibilityFrame`, because there's no need to recalculate coordinates when scrolling or shifting.

When you set `accessibilityElements`, VoiceOver will move only through these elements and will ignore the rest of the view hierarchy inside the chart.

## Bar chart

For a bar chart, the frame of each element coincides with the rectangle of the bar:

```swift
for (index, bar) in bars.enumerated() {
    let element = UIAccessibilityElement(accessibilityContainer: chartView)
    element.accessibilityLabel = months[index]
    element.accessibilityValue = "\(bar.value) thousand rubles"
    element.accessibilityFrameInContainerSpace = bar.frame
    elements.append(element)
}
```

VoiceOver will draw the focus frame around each bar, and the user will be able to swipe between them, listening to the values.

## Pie chart

In a pie chart, the segments aren't rectangular. If you set `accessibilityFrame` as a rectangle, the frames will overlap and be misleading. Instead, use `accessibilityPath` with `UIBezierPath`:

```swift
for segment in pieSegments {
    let element = UIAccessibilityElement(accessibilityContainer: chartView)
    element.accessibilityLabel = segment.category
    element.accessibilityValue = "\(segment.percentage)%"

    let path = UIBezierPath()
    path.move(to: center)
    path.addArc(
        withCenter: center,
        radius: radius,
        startAngle: segment.startAngle,
        endAngle: segment.endAngle,
        clockwise: true
    )
    path.close()

    // accessibilityPath is set in screen coordinates
    element.accessibilityPath = path
    elements.append(element)
}
```

When `accessibilityPath` is set, VoiceOver draws the focus frame along the path's outline, not as a rectangle. This exactly follows the shape of the segment.

> Note: `accessibilityPath` works in screen coordinates. If the view moves, the path needs to be recalculated.

## A lot of data

When the chart has hundreds or thousands of points, swiping through each is inconvenient even for a sighted user. Look at the Apple Stocks app: there the chart of a stock over a year contains many points, but VoiceOver doesn't force the user to go through every one.

Instead, Apple divides the chart into **10 segments** and voices the trend for each. The user can hold their finger on the chart and hear an audiograph — a sound representation of the data, where the pitch of the tone corresponds to the value.

### Custom actions

For charts with a lot of data, add custom actions:

```swift
chartView.accessibilityCustomActions = [
    UIAccessibilityCustomAction(
        name: "Describe chart"
    ) { _ in
        // "Line chart, revenue over 12 months"
        return true
    },
    UIAccessibilityCustomAction(
        name: "Data summary"
    ) { _ in
        // "Min: 12,000 in February. Max: 89,000 in December.
        //  Average: 45,000. Trend: growth of 34%."
        return true
    },
    UIAccessibilityCustomAction(
        name: "Describe series"
    ) { _ in
        // List the key points of the series
        return true
    },
    UIAccessibilityCustomAction(
        name: "Play audiograph"
    ) { _ in
        // Play the sound representation of the data
        return true
    },
]
```

This way the blind user gets a choice: listen to the summary in a second or dive into the details.

## Charts in iOS 15

In iOS 15, Apple introduced the `AXChart` protocol and the `accessibilityChartDescriptor` property. This is the standard way to describe a chart, after which the system itself provides the audiograph and navigation through the data.

### AXChartDescriptor

The basis of the approach is the `AXChartDescriptor` object, which describes the chart's structure: axes, data series, points.

```swift
import Accessibility

class RevenueChartView: UIView, AXChart {

    var accessibilityChartDescriptor: AXChartDescriptor? {
        get { makeChartDescriptor() }
        set { }
    }

    private func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Month",
            categoryOrder: months // ["Jan", "Feb", "Mar", ...]
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Revenue",
            range: 0...100_000,
            gridlinePositions: [0, 25_000, 50_000, 75_000, 100_000]
        ) { value in
            "\(Int(value)) rubles"
        }

        let series = AXDataSeriesDescriptor(
            name: "Revenue for 2025",
            isContinuous: true,
            dataPoints: dataPoints.enumerated().map { index, point in
                AXDataPoint(
                    x: index,
                    y: Double(point.value),
                    label: months[index]
                )
            }
        )

        return AXChartDescriptor(
            title: "Revenue by month",
            summary: "Revenue growth from 12,000 to 89,000 rubles in 2025",
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}
```

### What AXChart provides

After implementing the protocol, the user gets:

- **Audiograph.** The system plays a sound representation of the data — the pitch corresponds to the value on the Y axis. This is a fast way to understand the trend.
- **Point navigation.** Swipes move focus between data points, VoiceOver voices the value of each.
- **Axis description.** VoiceOver tells what's on the axes, what range of values, and the grid step.
- **Summary.** The text from `summary` helps to quickly understand the essence of the chart.

### Numeric axes

For time series or numeric data on both axes, use `AXNumericDataAxisDescriptor`:

```swift
let xAxis = AXNumericDataAxisDescriptor(
    title: "Day",
    range: 1...30,
    gridlinePositions: [1, 7, 14, 21, 30]
) { value in
    "Day \(Int(value))"
}
```

### Multiple series

If there are several lines on the chart, describe each as a separate `AXDataSeriesDescriptor`:

```swift
let revenueSeries = AXDataSeriesDescriptor(
    name: "Revenue",
    isContinuous: true,
    dataPoints: revenuePoints
)

let expenseSeries = AXDataSeriesDescriptor(
    name: "Expenses",
    isContinuous: true,
    dataPoints: expensePoints
)

let descriptor = AXChartDescriptor(
    title: "Revenue and expenses",
    summary: "Revenue exceeds expenses since March",
    xAxis: xAxis,
    yAxis: yAxis,
    additionalAxes: [],
    series: [revenueSeries, expenseSeries]
)
```

VoiceOver will let you switch between series so the user can compare the data.

> Tip: Use `AXChart` if your app supports iOS 15 and above. For earlier versions, create `UIAccessibilityElement`s manually and add custom actions.
