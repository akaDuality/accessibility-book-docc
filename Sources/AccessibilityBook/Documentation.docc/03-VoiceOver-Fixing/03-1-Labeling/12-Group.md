# Сгруппированные контролы

Как уменьшить количество элементов на экране и упростить навигацию

## Уменьшать количество элементов

Подписав все элементы и указав их тип, мы исправили самый простой, но массовый слой проблем. Для большинства приложений этого будет достаточно.

Теперь надо разобраться со следующей проблемой: на экране очень много элементов, связи между ними не всегда понятны, нужно постоянно между ними переключаться. 

Количество элементов можно уменьшить, связи добавить, а удобство использования повысить. 

## Название + значение

![Пример подитога суммы перед оплатой](simplify-label-value)

Частый паттерн в интерфейсе — пара из двух надписей: название и значение. Например, «Стоимость заказа — 799 ₽», или «Способ оплаты — Картой».

Без адаптации VoiceOver прочитает их как два отдельных элемента. Если таких элементов много, то пользователю придётся догадываться, какое значение к какому названию относится. Нужно объединить их в один элемент.

Используем `accessibilityLabel` для названия и `accessibilityValue` для значения. VoiceOver прочитает их с разной интонацией, что естественно для пары "вопрос — ответ".

```swift
// Родительский контейнер (например, UIView или UIStackView)
isAccessibilityElement = true
accessibilityLabel = "Стоимость заказа"
accessibilityValue = "799 ₽"
```

В реальном коде скорее будет так:
```swift
isAccessibilityElement = true
accessibilityLabel = titleLabel.text
accessibilityValue = valueLabel.text
```

Хороший пример — панель оценок в App Store. Средняя оценка, количество оценок и гистограмма объединены в один элемент: "Оценки и отзывы", значение "4.8 из 5". Не нужно свайпать по каждой звёздочке отдельно.

![Пример описания приложения: оценка, возраст, рейтинг](simplify-badges)

Пример из апстора показывает, что иногда надо чуть поменять текст специально для VoiceOver:

```
Оценка, 4.8 на основе 61 тысячи оценок
Возраст, 12 плюс
Рейтинг, 9 место в «Еда и напитки», кнопка
```

## UISwitch в ячейке

![Пример свитчера подписки на маркетинговую рассылку](simplify-switcher)

Свитчер — это кнопка с состоянием, VoiceOver его называет «кнопка-переключатель» и сообщает текущее состояние: включено или выключено. Переключить можно двойным тапом, VoiceOver прочитает новое состояние. В общем, по умолчанию все адаптировано.

Часто рядом со свитчером есть подпись. Семантически подпись и свитчер — это один контрол, поэтому и VoiceOver должен работать с ним как одним целым: читать подпись в качестве названия и тут же давать возможность нажать.

Должно получиться так:
```
label Сообщать о бонусах, акциях и новых продуктах
value Включено
trait кнопка-переключатель, вкл.
```

Интересно, что трейт «кнопка-переключатель» незадокументирован, но доступен под номером 53:

```swift
let switchButtonTrait = UIAccessibilityTraits(rawValue: 53)    
```

Как можно обработать:
- сделать всю ячейку доступным элементом,
- перенести текст надписи в лейбл ячейки,
- перенести трейт со свитчера,
- value брать динамически из свитчера.

Делаем ячейку доступным элементом и копируем данные из свитчера:

```swift
class SwitchCell: UITableViewCell {

    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var switcher: UISwitch!

    // Делаем всю ячейку доступной, указываем трейт как у свитчера.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isAccessibilityElement = true
        accessibilityTraits = switcher.accessibilityTraits
    }

    // Даем правильный label из двух строк.
    func configure(title: String, subtitle: String) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        
        accessibilityLabel = [title, subtitle]
            .joined(separator: ", ")
    }
    
    // Значение должно считываться прямо из свитчера. Оно уже локализовано, но вы можете написать свой текст.
    override var accessibilityValue: String? {
        get {
            switcher.accessibilityValue
        }
        set {}
    }
    
    // Нажатие на ячейку должно активировать свитчер
    override func accessibilityActivate() -> Bool {
        switcher.accessibilityActivate()
        return true
    }
}
```

> Note: Можно иначе обработать нажатие на элемент перенеся `activationPoint` на свитчер. Про это дальше.

## Activation Point

![Пример переноса точки активации](simplify-activation-point)

По умолчанию `accessibilityActivationPoint` указывает на центр элемента. При двойном тапе VoiceOver имитирует нажатие именно в эту точку. Обычно это работает, но иногда нужно перенаправить нажатие.

Например, если ячейка содержит кнопку выбора не по центру, можно переместить точку активации:

```swift
    override func layoutSubviews() {
        super.layoutSubviews()
        
        accessibilityActivationPoint = selectButton.accessibilityActivationPoint
    }
```

Если вы хотите сами рассчитывать координаты, то важно, чтобы точка активации рассчитывалась **в координатах экрана**. Для этого есть специальная функция `UIAccessibility.convertToScreenCoordinates`:

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

> Tip: Если поведение при нажатии сложнее, чем просто тап по кнопке, лучше использовать `accessibilityActivate()` — это надёжнее, чем перемещение точки.

### Зона нажатия

![](VoiceOver-areas)

*Подписанный экран → Сгруппированные элементы → Увеличенные зоны*

Объединяя элементы, мы увеличиваем зону их нажатия, но можно пойти дальше и вообще подумать о том, какие зоны на экране будут активными для изучения касанием. 

Например, мы можем увеличить зоны вокруг заголовков и растянуть их на всю возможную ширину. Пустой центр можно описать как «Капучино, изображение»: пользы немного, но хотя бы понятно, что доступность не сломана.  

В итоге получается, что весь экран может описать, что на нём находится. 

Для увеличения зоны вы можете задать `accessibilityFrame`. 

Пересчёт размеров стоит писать в `layoutSubviews()`, чтобы он обновлялся при изменении размеров и положения вью. Например, мы хотим объединить зону кнопки добавления и подписи с ценой:

```swift
override func layoutSubviews() {
    super.layoutSubviews()

    let combinedFrame = addToCartButton.frame.union(priceLabel.frame)

    accessibilityFrame = UIAccessibility.convertToScreenCoordinates(
        combinedFrame,
        in: self
    )
}
```

> Tip: `accessibilityFrame` работает в **экранных координатах**, а не в координатах родительского вью. Метод `UIAccessibility.convertToScreenCoordinates(_:in:)` выполняет нужное преобразование.
