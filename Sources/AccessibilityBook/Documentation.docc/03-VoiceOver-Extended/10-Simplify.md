# Упростить

Как объединять элементы в ячейках, комбинировать название и значение, управлять рамкой фокуса и точкой активации.

## Списки и ячейки

Большинство экранов в мобильных приложениях — это списки. Каждая ячейка списка обычно содержит несколько вью: картинку, заголовок, подзаголовок, иконку. Без адаптации VoiceOver будет фокусироваться на каждом из них по отдельности, заставляя пользователя совершать лишние свайпы.

Принцип простой: **одна ячейка — один элемент доступности.** Зрячий человек воспринимает ячейку как единое целое, и VoiceOver должен делать то же самое.

У таблиц (`UITableView`) есть системные стили, которые влияют на поведение VoiceOver: заголовки секций, футеры. Коллекции (`UICollectionView`) более примитивны — у них нет встроенной семантики, и всё нужно настраивать вручную.

Простая ячейка: делаем саму ячейку доступным элементом, даём ей описание и добавляем свойство `.button`, чтобы пользователь понял, что на неё можно нажать.

```swift
class LocaleCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    var title: String? {
        didSet {
            nameLabel.text = title
            accessibilityLabel = title
        }
    }
}
```

Когда `isAccessibilityElement = true` стоит на ячейке, VoiceOver перестаёт искать доступные элементы внутри неё — все дочерние вью становятся невидимыми. Ячейка сама становится единым фокусом.

## Сложная ячейка

Не все ячейки состоят из одной надписи. Представим ячейку товара: **название**, **состав** и **цена**. Зрячий человек видит это как единый блок, и VoiceOver должен работать так же.

Объединяем всю информацию в одном элементе:
- `accessibilityLabel` — название и цена, самое важное.
- `accessibilityValue` — состав, дополнительная информация.

```swift
func updateAccessibility(
    title: String,
    price: String,
    ingredients: String,
    isProductAvailable: Bool
) {
    isAccessibilityElement = true

    accessibilityLabel = "\(title), \(price)"
    accessibilityValue = ingredients

    if isProductAvailable {
        accessibilityTraits = .button
    } else {
        accessibilityTraits = [.button, .notEnabled]
    }
}
```

Разделение на `label` и `value` создаёт паузу и разную интонацию в речи VoiceOver: название читается уверенно, а значение — чуть тише и после паузы. Это помогает пользователю структурировать информацию на слух.

## Название + значение

Частый паттерн в интерфейсе — пара из двух надписей: название и значение. Например, "Стоимость заказа" и "799 ₽", или "Способ оплаты" и "Картой".

Без адаптации VoiceOver прочитает их как два отдельных элемента. Пользователю придётся догадываться, какое значение к какому названию относится. Нужно объединить их в один элемент.

Используем `accessibilityLabel` для названия и `accessibilityValue` для значения. VoiceOver прочитает их с разной интонацией, что естественно для пары "вопрос — ответ".

```swift
// Родительский контейнер (например, UIView или UIStackView)
isAccessibilityElement = true
accessibilityLabel = "Стоимость заказа"
accessibilityValue = "799 ₽"
```

Не забудьте скрыть дочерние надписи от VoiceOver:

```swift
titleLabel.isAccessibilityElement = false
valueLabel.isAccessibilityElement = false
```

Хороший пример — панель оценок в App Store. Средняя оценка, количество оценок и гистограмма объединены в один элемент: "Оценки и отзывы", значение "4.8 из 5". Не нужно свайпать по каждой звёздочке отдельно.

## Рамка фокуса

Когда мы объединяем несколько вью в один доступный элемент, возникает проблема: рамка фокуса VoiceOver по умолчанию соответствует `frame` элемента, на котором стоит `isAccessibilityElement = true`. Если это контейнер, рамка может быть правильной. Но если мы пометили одну из надписей как доступный элемент и включили в неё информацию из соседних — рамка будет слишком маленькой.

Решение — расширить рамку с помощью `accessibilityFrame`. Нужно объединить фреймы всех элементов, входящих в группу.

```swift
override func layoutSubviews() {
    super.layoutSubviews()

    let combinedFrame = titleLabel.frame.union(valueLabel.frame)

    accessibilityFrame = UIAccessibility.convertToScreenCoordinates(
        combinedFrame,
        in: self
    )
}
```

Важно: `accessibilityFrame` работает в **экранных координатах**, а не в координатах родительского вью. Метод `UIAccessibility.convertToScreenCoordinates(_:in:)` выполняет нужное преобразование.

Пересчёт рамки ставят в `layoutSubviews()`, чтобы она обновлялась при изменении размеров и положения вью.

## UISwitch в ячейке

`UISwitch` добавляет специальное свойство — `.button` с особым rawValue 53, которое VoiceOver озвучивает как "переключатель". Когда свитчер стоит в ячейке рядом с текстом, VoiceOver видит их как отдельные элементы: сначала текст, потом переключатель. Нужно объединить.

Делаем ячейку доступным элементом и копируем данные из свитчера:

```swift
class SwitchCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switcher: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
    }

    func updateAccessibility() {
        accessibilityLabel = [
            titleLabel.text,
            subtitleLabel.text
        ]
            .compactMap { $0 }
            .joined(separator: ", ")

        accessibilityTraits = switcher.accessibilityTraits
        accessibilityValue = switcher.accessibilityValue
    }

    override func accessibilityActivate() -> Bool {
        switcher.setOn(!switcher.isOn, animated: true)
        switcher.sendActions(for: .valueChanged)
        updateAccessibility()
        return true
    }
}
```

Мы берём `accessibilityTraits` у свитчера — так VoiceOver скажет "переключатель". Берём `accessibilityValue` — он скажет "вкл." или "выкл.". Собираем `accessibilityLabel` из двух текстовых надписей.

При двойном тапе VoiceOver вызовет `accessibilityActivate()`, в котором мы переключаем свитчер и обновляем доступность.

Альтернативный подход — переместить `accessibilityActivationPoint` на центр свитчера, чтобы VoiceOver тапал именно по нему.

## Activation Point

По умолчанию `accessibilityActivationPoint` указывает на центр элемента. При двойном тапе VoiceOver имитирует нажатие именно в эту точку. Обычно это работает, но иногда нужно перенаправить нажатие.

Например, если ячейка содержит кнопку выбора не по центру, можно переместить точку активации:

```swift
override func layoutSubviews() {
    super.layoutSubviews()

    let buttonCenter = CGPoint(
        x: selectButton.frame.midX,
        y: selectButton.frame.midY
    )

    accessibilityActivationPoint = UIAccessibility.convertToScreenCoordinates(
        buttonCenter,
        in: self
    )
}
```

Точка активации работает в **экранных координатах**, поэтому используем `UIAccessibility.convertToScreenCoordinates(_:in:)`. Пересчёт ставим в `layoutSubviews()`, как и рамку фокуса.

> Tip: Если поведение при нажатии сложнее, чем просто тап по кнопке, лучше использовать `accessibilityActivate()` — это надёжнее, чем перемещение точки.

## Порядок чтения

VoiceOver читает информацию об элементе в строгом порядке:

1. **Label** — название элемента. Читается первым, уверенным голосом.
2. **Value** — значение. Читается после паузы, чуть другой интонацией.
3. **Traits** — свойства. Озвучиваются в определённом порядке:
   - `.selected` — "выбрано"
   - `.notEnabled` — "недоступно"
   - `.button` — "кнопка"
4. **Hint** — подсказка. Читается последней, после длинной паузы. Если пользователь свайпнул до конца подсказки — она не прозвучит.

Пример:

```
"Пепперони, 625 рублей, выбрано, кнопка, коснитесь дважды чтобы убрать"
 ───────────────────── ────────── ──────── ──────── ─────────────────────
       label             value    selected  button         hint
```

Понимание порядка чтения помогает правильно распределить информацию: самое важное — в `label`, переменное — в `value`, поведение — в `traits`.

## Практика

Адаптация списков сводится к нескольким приёмам:

- **Добавьте `.button`** ко всем ячейкам, на которые можно нажать. Это самое простое изменение, которое сразу помогает.
- **Сгруппируйте контролы** в ячейках: сделайте ячейку `isAccessibilityElement = true` и соберите описание из дочерних элементов.
- **Объедините пары** "название + значение" в один элемент, используя `accessibilityLabel` и `accessibilityValue`.
- **Расширьте рамку фокуса**, если она не покрывает все элементы группы.
- **Переопределите `accessibilityActivate()`** для ячеек с интерактивными контролами вроде `UISwitch`.
