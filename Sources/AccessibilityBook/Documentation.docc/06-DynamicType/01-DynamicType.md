# Dynamic Type

Как поддержать изменение размера текста, адаптировать вёрстку и не сломать интерфейс на крайних значениях.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

## Обзор

20% пользователей меняют размер шрифта в настройках. Из них 13% уменьшают текст, а 7% увеличивают. Только 0,04% включают специальные размеры доступности — это те случаи, когда интерфейс требует серьёзных изменений вёрстки.

Пользователи с увеличенным шрифтом показывают конверсию на 5% выше. Они не просто крутят настройки ради интереса — им действительно важно видеть текст, и они ценят приложения, которые это уважают.

Доля таких пользователей будет расти. Старшее поколение всё активнее осваивает технологии, а вместе с этим растёт и потребность в крупном шрифте.

## Статистика

80% пользователей оставляют стандартный размер шрифта. Остальные 20% распределяются по разным уровням — от самого мелкого до самого крупного.

В настройках iPhone есть несколько уровней размера текста: от наименьшего до наибольшего. По умолчанию выбран средний. Помимо этого, существуют специальные размеры доступности — они включаются отдельным переключателем: **Настройки > Универсальный доступ > Дисплей и размер текста > Увеличенный текст**.

Когда переключатель активен, появляются дополнительные уровни увеличения, значительно превышающие стандартные. Именно для них нужно адаптировать вёрстку — обычные размеры, как правило, вписываются в существующий интерфейс без изменений.

## Стили текста

В iOS есть 11 стандартных стилей текста:

| Стиль | TextStyle |
|-------|-----------|
| Large Title | `.largeTitle` |
| Title 1 | `.title1` |
| Title 2 | `.title2` |
| Title 3 | `.title3` |
| Headline | `.headline` |
| Subheadline | `.subheadline` |
| Body | `.body` |
| Callout | `.callout` |
| Footnote | `.footnote` |
| Caption 1 | `.caption1` |
| Caption 2 | `.caption2` |

Каждый стиль задаёт не только размер шрифта, но и его вес. Используйте стили через `UIFont.preferredFont`:

```swift
label.font = UIFont.preferredFont(forTextStyle: .body)
```

Это главный принцип Dynamic Type: не задавайте размер шрифта числом, а используйте стиль. Система сама подберёт правильный размер в зависимости от настроек пользователя.

## Адаптивный размер

Стили текста напрямую влияют на отображаемый размер в зависимости от выбранной пользователем категории размера контента (`preferredContentSizeCategory`). Разброс огромный: стиль Body при размере XS составляет 80% от стандарта, а при максимальном размере доступности (AX5) — 310%. Разница в 4 раза.

Это означает, что контролы тоже должны адаптироваться. Кнопка, которая идеально выглядит с текстом 17pt, может не вместить текст 53pt. Нужно добавлять скролл, перерисовывать элементы, предлагать альтернативный ввод.

Четыре принципа адаптации:

1. **Контролы владеют своим размером.** Не задавайте фиксированную высоту — пусть элемент сам определяет, сколько ему нужно.
2. **Каждый экран может скроллиться.** Даже тот, который на стандартном размере помещается целиком.
3. **Меняйте вёрстку только для крупных размеров.** Горизонтальные раскладки ломаются на размерах доступности — переключайте их на вертикальные.
4. **Контролы во всю ширину — лучший выбор.** Они оставляют максимум места для текста.

## Как изменить размер

Есть четыре способа проверить интерфейс с разными размерами текста.

### Настройки телефона

Откройте **Настройки > Универсальный доступ > Дисплей и размер текста > Увеличенный текст**. Включите переключатель для доступа к максимальным размерам. Перетащите ползунок.

### Пункт управления

Добавьте кнопку «Размер текста» в Пункт управления. Это позволяет менять размер шрифта, не заходя в настройки — удобно для быстрого тестирования.

### Interface Builder

Начиная с Xcode 13 можно переключать размер текста прямо в Interface Builder. Это позволяет видеть, как выглядит экран при разных размерах, не запуская приложение.

### Accessibility Inspector

В симуляторе используйте Accessibility Inspector из Xcode. Он позволяет менять категорию размера контента на лету, без перезапуска приложения.

### Автоматическое обновление

Чтобы шрифт обновлялся при изменении размера текста без перезапуска приложения, включите свойство:

```swift
label.adjustsFontForContentSizeCategory = true
```

Без этого флага шрифт применится при создании лейбла, но не обновится, если пользователь изменит размер в процессе работы.

## Базовая гигиена

Прежде чем адаптировать сложные экраны, уберите типичные проблемы.

### Фиксированная высота

Удалите все фиксированные констрейнты высоты у элементов с текстом. Используйте `intrinsicContentSize` — элемент сам посчитает нужную высоту на основе содержимого.

### UILabel

Задайте `numberOfLines = 0`, чтобы текст мог занимать несколько строк:

```swift
label.numberOfLines = 0
```

### UIButton

Кнопки требуют больше внимания. Привяжите `titleLabel` к границам кнопки через констрейнты, разрешите многострочный текст и отцентрируйте:

```swift
button.titleLabel?.numberOfLines = 0
button.titleLabel?.textAlignment = .center
```

### UITableView

Включите автоматический расчёт высоты ячеек:

```swift
tableView.rowHeight = UITableView.automaticDimension
tableView.estimatedRowHeight = 56
```

Теперь ячейки будут расти вместе с текстом. Убедитесь, что внутри ячеек констрейнты образуют непрерывную цепочку от верхнего края до нижнего.

### Толщина линий

Обводки и разделители тоже должны масштабироваться. Используйте `UIFontMetrics` для пересчёта:

```swift
let scaledWidth = UIFontMetrics.default.scaledValue(for: 1)
layer.borderWidth = scaledWidth
```

## Простой пример

Рассмотрим типичные экраны: выбор города и страны со стандартными контролами UIKit. Ячейки таблицы с автоматическим расчётом высоты, многострочные `UILabel` — базовая адаптация работает из коробки.

На экране выбора страны рядом с названием стоит флаг. При стандартных размерах всё выглядит хорошо, но при максимальных размерах доступности флаг «отрывается» от текста. Есть три варианта:

- **Скрыть флаг** на крупных размерах. Самый простой подход — информация не теряется, потому что название страны достаточно.
- **Перенести флаг на отдельную строку.** Требует переключения вёрстки с горизонтальной на вертикальную.
- **Оставить как есть.** Если флаг маленький и не мешает тексту, можно ничего не делать.

## Меняем вёрстку

Горизонтальные раскладки — главная проблема при увеличенном тексте. Типичный случай: картинка слева, текст справа. При стандартных размерах всё выглядит отлично, но на размерах доступности текст не помещается.

Решение: менять вёрстку только для размеров доступности. Свойство `isAccessibilityCategory` у `UIContentSizeCategory` возвращает `true`, когда пользователь включил один из специальных крупных размеров.

Используйте `UIStackView` и переключайте его ось:

```swift
class AccessibleStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateAxis()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        updateAxis()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateAxis()
        }
    }

    private func updateAxis() {
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            axis = .vertical
        } else {
            axis = .horizontal
        }
    }
}
```

При обычных размерах картинка и текст стоят в ряд. Как только пользователь включает размер доступности, стек переключается на вертикальную ось — картинка сверху, текст снизу. Места достаточно для любого размера шрифта.

## Скриншот-тесты

Проверять вёрстку вручную на каждом размере текста утомительно. Используйте библиотеку SnapshotTesting от Point-Free для автоматических скриншот-тестов.

Тестируйте ячейки и экраны при разных размерах:

```swift
func test_defaultSize() {
    let cell = makeCell()
    assertSnapshot(
        matching: cell,
        as: .image(size: CGSize(width: 375, height: 100))
    )
}

func test_accessibleMediumSize() {
    let cell = makeCell()
    assertSnapshot(
        matching: cell,
        as: .image(size: CGSize(width: 375, height: 170)),
        traits: UITraitCollection(preferredContentSizeCategory: .accessibilityMedium)
    )
}

func test_accessibleExtraExtraExtraLargeSize() {
    let cell = makeCell()
    assertSnapshot(
        matching: cell,
        as: .image(size: CGSize(width: 375, height: 350)),
        traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    )
}
```

Обратите внимание: для каждого размера нужна своя высота. Ячейка при `.accessibilityExtraExtraExtraLarge` может быть в 3-4 раза выше, чем при стандартном размере. Если зафиксировать одну высоту, тест не покажет обрезанный текст.

## Констрейнты

Иконки должны масштабироваться вместе с текстом. Если использовать SF Symbols, это происходит автоматически при настройке через `UIImage.SymbolConfiguration` с текстовым стилем.

Для кастомных иконок нужно привязать размер к высоте первой строки текста. Создайте динамический констрейнт, который слушает изменение размера:

```swift
class DynamicConstraint: NSLayoutConstraint {

    private var baseConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        baseConstant = constant
        updateConstant()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateConstant),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateConstant() {
        constant = UIFontMetrics.default.scaledValue(for: baseConstant)
    }
}
```

Укажите этот класс для констрейнта высоты или ширины иконки в Interface Builder. Теперь при смене размера текста иконка будет масштабироваться пропорционально.

## Стильно, но в одном размере

Иногда нужно использовать стили текста для единообразия, но зафиксировать размер — например, в элементе, который не должен расти. Есть два подхода.

### Полная фиксация

Получаем шрифт для стиля, но всегда в стандартном размере:

```swift
static func preferredFont_fixed(for textStyle: UIFont.TextStyle) -> UIFont {
    let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
    return UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: traitCollection)
}
```

Шрифт сохраняет вес и пропорции стиля, но его размер не зависит от настроек пользователя.

### Ограниченная адаптация

Шрифт растёт до определённого предела, но не дальше:

```swift
static func preferredFont_limited(
    for textStyle: UIFont.TextStyle,
    maxCategory: UIContentSizeCategory = .accessibilityMedium
) -> UIFont {
    let currentCategory = UIApplication.shared.preferredContentSizeCategory
    let category = min(currentCategory, maxCategory)
    let traitCollection = UITraitCollection(preferredContentSizeCategory: category)
    return UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: traitCollection)
}
```

Так шрифт будет расти вместе с настройками, но остановится на указанном максимуме. Это полезно для элементов, которые должны адаптироваться, но не могут стать слишком большими.

> Note: Не злоупотребляйте фиксацией. Большинство элементов должно расти вместе с текстом. Фиксируйте только те элементы, которые действительно не могут увеличиваться — например, табы или компактные навигационные элементы.

## Скролл всего

Любой экран может не поместиться при увеличенном тексте. Даже форма из трёх полей может вылезти за границы экрана при максимальных размерах доступности. Решение — оборачивать контент в скролл.

Используйте обёртку `ScrollingContentViewController`, которая помещает контент в `UIScrollView`:

```swift
class ScrollingContentViewController: UIViewController {

    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
```

Эта обёртка также упрощает работу с клавиатурой — достаточно уменьшить `contentInset` при появлении клавиатуры, и пользователь сможет прокрутить до нужного поля.

## Выравнивание текста

При увеличенном тексте длинные строки могут выглядеть неаккуратно. Меняйте выравнивание в `traitCollectionDidChange`:

```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
        descriptionLabel.textAlignment = .natural
    } else {
        descriptionLabel.textAlignment = .center
    }
}
```

Для многострочных лейблов с текстом описания используйте `preferredMaxLayoutWidth`, чтобы Auto Layout корректно рассчитывал высоту:

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.width
}
```

## Превью

Некоторые элементы не могут расти — например, вкладки в таб-баре. Для них iOS предоставляет `UILargeContentViewerInteraction`: пользователь нажимает и удерживает элемент, и система показывает увеличенное превью с названием и иконкой.

```swift
tabBar.showsLargeContentViewer = true
tabBar.addInteraction(UILargeContentViewerInteraction())

for item in tabBar.items ?? [] {
    item.largeContentSizeImage = item.image
}
```

Для кастомных контролов настройка чуть сложнее:

```swift
nutritionButton.showsLargeContentViewer = true
nutritionButton.addInteraction(UILargeContentViewerInteraction())
nutritionButton.largeContentTitle = nutritionButton.accessibilityLabel
nutritionButton.largeContentImage = nutritionButton.image(for: .normal)
```

Стандартные `UITabBar` и `UINavigationBar` поддерживают `UILargeContentViewerInteraction` из коробки начиная с iOS 13. Для своих контролов нужно добавить протокол `UILargeContentViewerItem`.

## Другое поведение

Некоторые стандартные контролы UIKit автоматически меняют поведение при размерах доступности.

### UISegmentedControl

При обычных размерах сегментированный контрол показывает все сегменты в ряд. При размерах доступности он автоматически переключается на попап-меню — пользователь нажимает на контрол и выбирает значение из списка. Это поведение встроено в систему и не требует дополнительной настройки.

### Горизонтальные карусели

Карусели с горизонтальной прокруткой (например, выбор размера пиццы) плохо работают на крупных размерах: текст не помещается в маленькие карточки. Альтернативное решение — заменить карусель на одну кнопку, которая открывает `UIAlertController` со списком вариантов:

```swift
if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
    showPickerButton()
} else {
    showCarousel()
}
```

Кнопка показывает текущее значение, а при нажатии открывает лист выбора. Это работает лучше, чем горизонтальный скролл крошечных карточек с огромным текстом.

## Все ли нужно увеличивать?

Нет. Не стоит слепо увеличивать абсолютно все элементы интерфейса. Увеличивайте только ключевое содержимое: текст статей, названия товаров, цены, описания. Для вспомогательных элементов — иконок навигации, мелких кнопок управления — используйте превью через `UILargeContentViewerInteraction`.

Пользователи с экстремальными размерами текста привыкли скроллить. Они знают, что контент не поместится на один экран, и готовы к этому. Но они не готовы к сломанной вёрстке, обрезанному тексту или кнопкам, на которые невозможно нажать.

## Стиль для шрифта

Если приложение использует кастомный шрифт вместо системного, Dynamic Type всё равно работает. Используйте `UIFontMetrics` для масштабирования:

```swift
let customFont = UIFont(name: "Montserrat-Bold", size: 17)!
label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
label.adjustsFontForContentSizeCategory = true
```

`UIFontMetrics` берёт ваш шрифт и масштабирует его так же, как система масштабирует стандартный шрифт для указанного стиля. Базовый размер 17pt будет расти и уменьшаться вместе с настройками пользователя.

## Масштаб и лупа

Помимо Dynamic Type, в iOS есть и другие способы увеличить содержимое экрана.

### Масштаб экрана

В **Настройки > Экран и яркость > Увеличение** пользователь может переключить отображение на увеличенный масштаб. Это меняет логическое разрешение экрана — всё становится крупнее, но на экране помещается меньше информации.

Масштаб влияет на `UIScreen.main.scale` и может сломать вёрстку, если вы завязаны на точные размеры экрана в пикселях. Используйте Auto Layout и Safe Area, чтобы избежать проблем.

### Экранная лупа

Для приложений, которые не поддерживают Dynamic Type, iOS предлагает системную лупу: **Настройки > Универсальный доступ > Увеличение**. Пользователь двойным тапом тремя пальцами включает зум и перемещает увеличенную область по экрану.

Это крайний вариант — работать с лупой неудобно, потому что пользователь видит только часть экрана. Полноценная поддержка Dynamic Type всегда лучше.

## Жирный шрифт

4% пользователей включают жирный шрифт в настройках доступности. Это отдельная от Dynamic Type настройка: **Настройки > Универсальный доступ > Дисплей и размер текста > Жирный шрифт**.

Проверяйте состояние и подписывайтесь на изменение:

```swift
if UIAccessibility.isBoldTextEnabled {
    // Применить жирное начертание
}

NotificationCenter.default.addObserver(
    self,
    selector: #selector(boldTextChanged),
    name: UIAccessibility.boldTextStatusDidChangeNotification,
    object: nil
)
```

Если используете системные шрифты через `UIFont.preferredFont`, жирное начертание применяется автоматически. Для кастомных шрифтов нужно переключать начертание вручную через `fontDescriptor`:

```swift
if UIAccessibility.isBoldTextEnabled,
   let boldDescriptor = label.font.fontDescriptor.withSymbolicTraits(.traitBold) {
    label.font = UIFont(descriptor: boldDescriptor, size: 0)
}
```

Размер `0` означает «оставить текущий размер шрифта».

## Другие настройки

`UIAccessibility` предоставляет множество настроек, каждая из которых имеет свойство для проверки состояния и уведомление для отслеживания изменений:

| Свойство | Описание |
|----------|----------|
| `isInvertColorsEnabled` | Инвертирование цветов |
| `isBoldTextEnabled` | Жирный шрифт |
| `buttonShapesEnabled` | Формы кнопок — подчёркивание текстовых кнопок |
| `isGrayscaleEnabled` | Оттенки серого |
| `isReduceTransparencyEnabled` | Уменьшение прозрачности |
| `isReduceMotionEnabled` | Уменьшение движения |
| `prefersCrossFadeTransitions` | Предпочтение перекрёстных переходов вместо анимации |
| `isVideoAutoplayEnabled` | Автовоспроизведение видео |
| `isDarkerSystemColorsEnabled` | Увеличение контраста |
| `isShakeToUndoEnabled` | Встряхивание для отмены |
| `shouldDifferentiateWithoutColor` | Различать без цвета |
| `isOnOffSwitchLabelsEnabled` | Метки вкл./выкл. на переключателях |

Каждая настройка сопровождается уведомлением — например, `UIAccessibility.reduceMotionStatusDidChangeNotification` для уменьшения движения. Подписывайтесь на нужные уведомления и адаптируйте интерфейс:

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(reduceMotionChanged),
    name: UIAccessibility.reduceMotionStatusDidChangeNotification,
    object: nil
)

@objc func reduceMotionChanged() {
    if UIAccessibility.isReduceMotionEnabled {
        // Заменить анимации на простые переходы
    }
}
```

> Tip: Не обязательно поддерживать все настройки сразу. Начните с жирного шрифта и уменьшения движения — это самые распространённые и самые заметные.
