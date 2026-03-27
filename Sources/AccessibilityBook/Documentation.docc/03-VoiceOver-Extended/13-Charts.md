# Графики

Как сделать графики и диаграммы доступными для VoiceOver, когда iOS видит только картинку.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

## Проблема

Графики — одни из самых сложных элементов для адаптации. iOS не знает, что нарисовано на экране: для системы график — это просто картинка. Ни столбцы гистограммы, ни сегменты круговой диаграммы, ни точки на линейном графике не являются элементами UIKit. VoiceOver не может сфокусироваться ни на одной из частей графика, потому что для него частей не существует.

Чтобы незрячий человек мог работать с данными на графике, нужно создать доступные элементы вручную.

## Кастомные элементы

Каждую точку данных на графике нужно представить как `UIAccessibilityElement`. Это объект, который не отображается на экране, но доступен для VoiceOver.

```swift
let chartView = ChartView()

var elements: [UIAccessibilityElement] = []

for dataPoint in dataPoints {
    let element = UIAccessibilityElement(accessibilityContainer: chartView)
    element.accessibilityLabel = dataPoint.label
    element.accessibilityValue = "\(dataPoint.value) рублей"
    element.accessibilityFrameInContainerSpace = dataPoint.barFrame
    elements.append(element)
}

chartView.accessibilityElements = elements
```

Обратите внимание на `accessibilityFrameInContainerSpace` — это координаты элемента внутри контейнера, а не в координатах экрана. Свойство удобнее, чем `accessibilityFrame`, потому что не нужно пересчитывать координаты при скролле или смещении.

Когда вы задаёте `accessibilityElements`, VoiceOver будет перемещаться только по этим элементам и проигнорирует всю остальную иерархию вью внутри графика.

## Столбчатая диаграмма

Для столбчатой диаграммы фрейм каждого элемента совпадает с прямоугольником столбца:

```swift
for (index, bar) in bars.enumerated() {
    let element = UIAccessibilityElement(accessibilityContainer: chartView)
    element.accessibilityLabel = months[index]
    element.accessibilityValue = "\(bar.value) тысяч рублей"
    element.accessibilityFrameInContainerSpace = bar.frame
    elements.append(element)
}
```

VoiceOver нарисует рамку фокуса вокруг каждого столбца, и пользователь сможет свайпать между ними, слушая значения.

## Круговая диаграмма

У круговой диаграммы сегменты не прямоугольные. Если задать `accessibilityFrame` прямоугольником, рамки будут пересекаться и вводить в заблуждение. Вместо этого используйте `accessibilityPath` с `UIBezierPath`:

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

    // accessibilityPath задаётся в координатах экрана
    element.accessibilityPath = path
    elements.append(element)
}
```

Когда задан `accessibilityPath`, VoiceOver рисует рамку фокуса по контуру пути, а не прямоугольником. Это точно повторяет форму сегмента.

> Note: `accessibilityPath` работает в координатах экрана. Если вью перемещается, путь нужно пересчитывать.

## Много данных

Когда на графике сотни или тысячи точек, свайпать по каждой неудобно даже зрячему. Посмотрите на приложение Apple Stocks: там график акций за год содержит множество точек, но VoiceOver не заставляет пользователя проходить по каждой.

Вместо этого Apple делит график на **10 сегментов** и озвучивает тренд для каждого. Пользователь может зажать палец на графике и услышать аудиограф — звуковое представление данных, где высота тона соответствует значению.

### Контекстные действия

Для графиков с большим количеством данных добавьте контекстные действия:

```swift
chartView.accessibilityCustomActions = [
    UIAccessibilityCustomAction(
        name: "Описать график"
    ) { _ in
        // "Линейный график, доход за 12 месяцев"
        return true
    },
    UIAccessibilityCustomAction(
        name: "Сводка данных"
    ) { _ in
        // "Минимум: 12 000 в феврале. Максимум: 89 000 в декабре.
        //  Средний: 45 000. Тренд: рост на 34%."
        return true
    },
    UIAccessibilityCustomAction(
        name: "Описать серию"
    ) { _ in
        // Перечислить ключевые точки серии
        return true
    },
    UIAccessibilityCustomAction(
        name: "Воспроизвести аудиограф"
    ) { _ in
        // Проиграть звуковое представление данных
        return true
    },
]
```

Так незрячий получает выбор: прослушать сводку за секунду или погрузиться в детали.

## Графики в iOS 15

В iOS 15 Apple представила протокол `AXChart` и свойство `accessibilityChartDescriptor`. Это стандартный способ описать график, после которого система сама предоставит аудиограф и навигацию по данным.

### AXChartDescriptor

Основа подхода — объект `AXChartDescriptor`, который описывает структуру графика: оси, серии данных, точки.

```swift
import Accessibility

class RevenueChartView: UIView, AXChart {

    var accessibilityChartDescriptor: AXChartDescriptor? {
        get { makeChartDescriptor() }
        set { }
    }

    private func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Месяц",
            categoryOrder: months // ["Янв", "Фев", "Мар", ...]
        )

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Доход",
            range: 0...100_000,
            gridlinePositions: [0, 25_000, 50_000, 75_000, 100_000]
        ) { value in
            "\(Int(value)) рублей"
        }

        let series = AXDataSeriesDescriptor(
            name: "Доход за 2025 год",
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
            title: "Доход по месяцам",
            summary: "Рост дохода с 12 000 до 89 000 рублей за 2025 год",
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }
}
```

### Что даёт AXChart

После реализации протокола пользователь получает:

- **Аудиограф.** Система проигрывает звуковое представление данных — высота тона соответствует значению на оси Y. Это быстрый способ понять тренд.
- **Навигацию по точкам.** Свайпы перемещают фокус между точками данных, VoiceOver озвучивает значение каждой.
- **Описание осей.** VoiceOver рассказывает, что на осях, какой диапазон значений и шаг сетки.
- **Сводку.** Текст из `summary` помогает быстро понять суть графика.

### Числовые оси

Для временных рядов или числовых данных по обеим осям используйте `AXNumericDataAxisDescriptor`:

```swift
let xAxis = AXNumericDataAxisDescriptor(
    title: "День",
    range: 1...30,
    gridlinePositions: [1, 7, 14, 21, 30]
) { value in
    "\(Int(value)) день"
}
```

### Несколько серий

Если на графике несколько линий, опишите каждую как отдельную `AXDataSeriesDescriptor`:

```swift
let revenueSeries = AXDataSeriesDescriptor(
    name: "Доход",
    isContinuous: true,
    dataPoints: revenuePoints
)

let expenseSeries = AXDataSeriesDescriptor(
    name: "Расходы",
    isContinuous: true,
    dataPoints: expensePoints
)

let descriptor = AXChartDescriptor(
    title: "Доход и расходы",
    summary: "Доход превышает расходы с марта",
    xAxis: xAxis,
    yAxis: yAxis,
    additionalAxes: [],
    series: [revenueSeries, expenseSeries]
)
```

VoiceOver позволит переключаться между сериями, чтобы пользователь мог сравнить данные.

> Tip: Используйте `AXChart`, если ваше приложение поддерживает iOS 15 и выше. Для более ранних версий создавайте `UIAccessibilityElement` вручную и добавляйте контекстные действия.
