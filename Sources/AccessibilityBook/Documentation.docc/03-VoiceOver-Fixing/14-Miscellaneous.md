# Разное

Трейты, хаптик, ошибки, загрузка, голос и другие аспекты доступности.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

## Трейты

Трейты — это свойства элемента, которые влияют на то, как VoiceOver его озвучивает и как с ним взаимодействует. Они задаются через `accessibilityTraits` и делятся на несколько категорий.

### Тип элемента

Трейт типа добавляет слово к описанию и меняет поведение:

| Трейт | Описание |
|-------|----------|
| `.button` | Кнопка. VoiceOver добавит «кнопка» и разрешит двойной тап |
| `.adjustable` | Регулируемый элемент. Появляются вертикальные свайпы для изменения значения |
| `.image` | Изображение. VoiceOver добавит «изображение» |
| `.link` | Ссылка. VoiceOver добавит «ссылка», элемент появится в роторе «Ссылки» |
| `.searchField` | Поле поиска. VoiceOver добавит «поле поиска» |
| `.keyboardKey` | Клавиша клавиатуры. Активируется по поднятию пальца в режиме набора вслепую |
| `.tab` | Вкладка. VoiceOver добавит «вкладка» |

### Состояние

| Трейт | Описание |
|-------|----------|
| `.selected` | Выбранный элемент. VoiceOver скажет «выбрано» |
| `.notEnabled` | Отключённый элемент. VoiceOver скажет «недоступно» |

### Навигация

| Трейт | Описание |
|-------|----------|
| `.header` | Заголовок. Появляется в роторе «Заголовки», пользователь может прыгать между заголовками |
| `.summaryElement` | Сводный элемент. Читается при переходе на экран |

### Взаимодействие

| Трейт | Описание |
|-------|----------|
| `.allowsDirectInteraction` | Прямое касание. VoiceOver передаёт касания напрямую элементу |
| `.playsSound` | Элемент воспроизводит звук. VoiceOver замолчит, чтобы не перебивать |
| `.startsMediaSession` | Начинает медиасессию. VoiceOver замолчит на время воспроизведения |
| `.causesPageTurn` | Вызывает перелистывание страницы. VoiceOver дождётся новой страницы |

### Обновление

| Трейт | Описание |
|-------|----------|
| `.updatesFrequently` | Часто обновляется. VoiceOver будет проверять значение чаще |
| `.staticText` | Статичный текст |
| `.none` | Без трейтов |

### Работа с трейтами

Трейты — это `OptionSet`, поэтому их можно комбинировать, добавлять и удалять:

```swift
// Задать несколько трейтов
cell.accessibilityTraits = [.button, .header]

// Добавить трейт
cell.accessibilityTraits.insert(.selected)

// Убрать трейт
cell.accessibilityTraits.remove(.selected)
```

> Note: Не используйте `accessibilityTraits = .selected` для добавления — это заменит все существующие трейты. Вместо этого используйте `insert`.

## Скрытые трейты

В iOS существуют недокументированные трейты, доступные через `rawValue`. Их можно найти, если перебрать битовые сдвиги:

```swift
let trait = UIAccessibilityTraits(rawValue: 1 << 19)
```

Биты с 19 по 60 содержат скрытые трейты, которые Apple использует внутренне. Среди них есть трейты для обозначения вкладки, статус-бара, панели поиска, всплывающей кнопки, подстрочного текста и других элементов.

Использовать недокументированные трейты в продакшне рискованно — Apple может изменить их в любой момент. Но знать о них полезно для исследования поведения стандартных контролов.

## Хаптик

Тактильная обратная связь помогает незрячим получать подтверждение действия. В iOS доступны два основных генератора.

### UISelectionFeedbackGenerator

Лёгкая вибрация при переключении между элементами:

```swift
let generator = UISelectionFeedbackGenerator()
generator.prepare()
generator.selectionChanged()
```

Метод `prepare()` вызывайте заранее — он подготавливает Taptic Engine, чтобы вибрация произошла мгновенно.

### UINotificationFeedbackGenerator

Три типа уведомлений с разной интенсивностью:

```swift
let generator = UINotificationFeedbackGenerator()
generator.prepare()

generator.notificationOccurred(.success) // Лёгкая: операция выполнена
generator.notificationOccurred(.warning) // Средняя: предупреждение
generator.notificationOccurred(.error)   // Сильная: ошибка
```

Пример использования:

```swift
func submitForm() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()

    if validate() {
        save()
        generator.notificationOccurred(.success)
    } else {
        generator.notificationOccurred(.error)
    }
}
```

> Tip: Для подбора правильной вибрации можно использовать приложение Haptic Composer от Apple, которое входит в Xcode Additional Tools.

## Ошибки

Сообщения об ошибках в формах — частая проблема доступности. Вот несколько правил.

### Показывайте ошибку рядом с полем

Не выводите одну ошибку на весь экран наверху — незрячий может не заметить её. Привяжите текст ошибки к конкретному полю:

```swift
emailField.accessibilityLabel = "Электронная почта"
emailField.accessibilityValue = "Ошибка: неверный формат адреса"
```

### Объявляйте ошибки через уведомления

Когда ошибка появляется, сообщите о ней VoiceOver:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Ошибка: неверный формат электронной почты"
)
```

### Не скрывайте ошибки по таймеру

Если сообщение об ошибке исчезает через несколько секунд, незрячий может не успеть до него добраться. Ошибка должна оставаться на экране, пока пользователь не исправит её.

### Кнопка отправки

Когда пользователь нажимает кнопку отправки и есть ошибки, озвучьте количество:

```swift
func submitTapped() {
    let errors = validate()

    if errors.isEmpty {
        submit()
    } else {
        UIAccessibility.post(
            notification: .announcement,
            argument: "\(errors.count) \(pluralizeError(errors.count)). Первая: \(errors[0].message)"
        )
    }
}
```

Для навигации по ошибкам добавьте их в ротор через `UIAccessibilityCustomRotor`:

```swift
let errorRotor = UIAccessibilityCustomRotor(name: "Ошибки") { predicate in
    // Перейти к следующему/предыдущему полю с ошибкой
    let direction = predicate.searchDirection
    let nextField = findNextErrorField(
        after: predicate.currentItem.targetElement,
        direction: direction
    )

    guard let field = nextField else { return nil }
    return UIAccessibilityCustomRotorItemResult(
        targetElement: field,
        targetRange: nil
    )
}

view.accessibilityCustomRotors = [errorRotor]
```

## Загрузка

Поведение при загрузке зависит от её длительности и типа.

### Короткая загрузка (менее 0.5 секунды)

Ничего делать не нужно. Пользователь не заметит задержку, и лишнее уведомление только собьёт с толку.

### Долгая блокирующая загрузка

Если экран заблокирован индикатором загрузки, переместите фокус на индикатор:

```swift
activityIndicator.accessibilityLabel = "Загрузка"
activityIndicator.isAccessibilityElement = true

// Показали индикатор — фокус на него
UIAccessibility.post(
    notification: .screenChanged,
    argument: activityIndicator
)
```

Когда загрузка завершится и экран обновится, VoiceOver автоматически переключится на новый контент при использовании `.screenChanged`.

### Долгая фоновая загрузка

Если загрузка идёт в фоне и пользователь может продолжать работу, не перехватывайте фокус. Просто сообщите о завершении:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Данные загружены"
)
```

## Прогресс

Для длительных операций с прогрессом нужно больше информации.

```swift
progressView.accessibilityLabel = "Загрузка файла"
progressView.accessibilityValue = "45 процентов, примерно 2 минуты"
progressView.accessibilityTraits = .updatesFrequently
```

Трейт `.updatesFrequently` подсказывает VoiceOver, что значение нужно проверять чаще.

Обновляйте `accessibilityValue` по мере продвижения, а при завершении уведомите пользователя:

```swift
func updateProgress(_ fraction: Float) {
    let percent = Int(fraction * 100)
    progressView.accessibilityValue = "\(percent) процентов"

    if fraction >= 1.0 {
        UIAccessibility.post(
            notification: .announcement,
            argument: "Загрузка завершена"
        )
    }
}
```

Не обновляйте значение на каждый процент — VoiceOver не успеет прочитать. Достаточно обновлять каждые 10% или по ключевым этапам.

## 3D-тач

3D Touch работает при включённом VoiceOver. Пользователь может нажать сильнее на элемент в фокусе, чтобы вызвать Peek & Pop. Но он может не знать, что элемент поддерживает 3D Touch.

Используйте `accessibilityHint`, чтобы подсказать:

```swift
cell.accessibilityHint = "Нажмите сильнее для быстрого просмотра"
```

VoiceOver прочитает хинт после небольшой паузы, и пользователь будет знать о дополнительной возможности.

## Тост с действием

Тосты — всплывающие уведомления, которые исчезают через несколько секунд. Самый распространённый пример — тост с отменой действия: «Письмо удалено. Отменить».

### Проблемы для VoiceOver

Незрячий может не заметить тост, потому что фокус не перемещается на него автоматически. Даже если он услышит уведомление, может не успеть найти кнопку «Отменить» до исчезновения тоста.

### Решения

**Увеличьте время показа для VoiceOver:**

```swift
let duration: TimeInterval = UIAccessibility.isVoiceOverRunning ? 10.0 : 3.0
showToast(duration: duration)
```

**Размещайте тост у края экрана** — сверху или снизу. Так незрячий сможет быстрее найти его, исследуя экран касанием.

**Добавьте Shake to Undo.** Встряхивание телефона для отмены — стандартный жест iOS, который работает с VoiceOver:

```swift
override var canBecomeFirstResponder: Bool { true }

override func motionEnded(
    _ motion: UIEvent.EventSubtype,
    with event: UIEvent?
) {
    if motion == .motionShake {
        undoLastAction()
    }
}
```

**Используйте хаптик `.warning`**, чтобы привлечь внимание:

```swift
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.warning)

UIAccessibility.post(
    notification: .announcement,
    argument: "Письмо удалено. Встряхните телефон для отмены"
)
```

## Голос

`NSAttributedString` поддерживает специальные атрибуты, которые управляют произношением VoiceOver.

### Пунктуация

Включает чтение знаков препинания вслух — точек, запятых, скобок:

```swift
let code = NSAttributedString(
    string: "func hello() { }",
    attributes: [
        .accessibilitySpeechPunctuation: true
    ]
)
label.accessibilityAttributedLabel = code
// VoiceOver: "func hello открытая скобка закрытая скобка
//             открытая фигурная скобка закрытая фигурная скобка"
```

### Язык

Задаёт язык для фрагмента текста. VoiceOver переключит голосовой движок:

```swift
let text = NSMutableAttributedString(string: "Добро пожаловать, welcome!")

text.addAttribute(
    .accessibilitySpeechLanguage,
    value: "ru-RU",
    range: NSRange(location: 0, length: 19) // "Добро пожаловать, "
)

text.addAttribute(
    .accessibilitySpeechLanguage,
    value: "en-US",
    range: NSRange(location: 19, length: 8) // "welcome!"
)

label.accessibilityAttributedLabel = text
```

### Высота голоса

Значение от 0 до 2, где 1 — обычная высота. Полезно для выделения важных частей:

```swift
let text = NSMutableAttributedString(string: "Ошибка: неверный пароль")

// "Ошибка" — высоким голосом для привлечения внимания
text.addAttribute(
    .accessibilitySpeechPitch,
    value: 1.5,
    range: NSRange(location: 0, length: 6)
)

label.accessibilityAttributedLabel = text
```

### Фонетическое произношение

`speechIPANotation` задаёт произношение через IPA-транскрипцию:

```swift
let name = NSAttributedString(
    string: "Xiaomi",
    attributes: [
        .accessibilitySpeechIPANotation: "ˈʃaʊmiː"
    ]
)
label.accessibilityAttributedLabel = name
// VoiceOver произнесёт "Шаоми" вместо "Ксяоми"
```

### Произнесение по буквам

Заставляет VoiceOver произнести текст по одной букве:

```swift
let code = NSAttributedString(
    string: "ABC123",
    attributes: [
        .accessibilitySpeechSpellOut: true
    ]
)
label.accessibilityAttributedLabel = code
// VoiceOver: "А Бэ Цэ один два три"
```

Полезно для кодов подтверждения, серийных номеров и аббревиатур.
