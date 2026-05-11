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

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        // Родительский контейнер (например, UIView или UIStackView)
        isAccessibilityElement = true
        accessibilityLabel = "Стоимость заказа"
        accessibilityValue = "799 ₽"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        HStack {
            Text("Стоимость заказа")
            Spacer()
            Text("799 ₽")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Стоимость заказа")
        .accessibilityValue("799 ₽")
        ```
    }
}

В реальном коде скорее будет так:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        isAccessibilityElement = true
        accessibilityLabel = titleLabel.text
        accessibilityValue = valueLabel.text
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        ```
    }
}

Хороший пример — панель оценок в App Store. Средняя оценка, количество оценок и гистограмма объединены в один элемент: "Оценки и отзывы", значение "4.8 из 5". Не нужно свайпать по каждой звёздочке отдельно.

![Пример описания приложения: оценка, возраст, рейтинг](simplify-badges)

Пример из апстора показывает, что иногда надо чуть поменять текст специально для VoiceOver:

```
Оценка, 4.8 на основе 61 тысячи оценок
Возраст, 12 плюс
Рейтинг, 9 место в «Еда и напитки», кнопка
```

## Режимы `accessibilityElement(children:)`

В SwiftUI способ объединения дочерних элементов задаётся одним модификатором — `accessibilityElement(children:)`. У него три режима, и каждый решает свою задачу.

### `.ignore` — задать подпись вручную

Контейнер становится единым элементом доступности, дочерние вью исключаются. Подпись и значение задаются явно — VoiceOver не возьмёт ничего из детей.

```swift
HStack {
    Text("Стоимость заказа")
    Spacer()
    Text("799 ₽")
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Стоимость заказа")
.accessibilityValue("799 ₽")
```

Используйте, когда нужно полностью контролировать, что прочитает VoiceOver: переписать сокращения, поменять порядок, добавить контекст. Эквивалент `isAccessibilityElement = true` в UIKit.

### `.combine` — собрать дочерние подписи

SwiftUI сам соберёт подписи всех дочерних элементов в одну строку и применит к контейнеру. Трейты и действия тоже наследуются.

```swift
HStack {
    Text("Пепперони")
    Text("625 ₽")
}
.accessibilityElement(children: .combine)
// VoiceOver прочитает: «Пепперони, 625 ₽»
```

Используйте, когда видимый текст уже подходит для VoiceOver и переписывать его не нужно. Удобно для простых ячеек из нескольких коротких надписей.

### `.contain` — логическая группа

Дочерние элементы остаются отдельными — фокус по-прежнему попадает на каждый из них. Контейнер становится «контейнером» в смысле VoiceOver: помогает в навигации (ротор по контейнерам, свайп четырьмя пальцами).

```swift
VStack {
    ForEach(pizzas) { pizza in
        PizzaCard(pizza: pizza)
    }
}
.accessibilityElement(children: .contain)
.accessibilityLabel("Рекомендации")
```

Используйте для крупных смысловых разделов: секций экрана, каруселей, групп товаров. Объединять при этом дочерние элементы в один не нужно.

> Tip: Если режим не указан, SwiftUI выбирает поведение сам: обычно дочерние элементы остаются доступными, как будто модификатора нет. Для группировки всегда указывайте режим явно.

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

@TabNavigator {
    @Tab("UIKit") {
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
    }
    @Tab("SwiftUI") {
        ```swift
        // SwiftUI Toggle сам объединяет подпись, значение и трейт.
        // Текст лейбла становится accessibilityLabel, состояние — accessibilityValue,
        // тап в любом месте строки переключает свитчер.
        Toggle(isOn: $isSubscribed) {
            VStack(alignment: .leading) {
                Text("Сообщать о бонусах")
                Text("акциях и новых продуктах")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        ```
    }
}

## Activation Point

![Пример переноса точки активации](simplify-activation-point)

По умолчанию `accessibilityActivationPoint` указывает на центр элемента. При двойном тапе VoiceOver имитирует нажатие именно в эту точку. Обычно это работает, но иногда нужно перенаправить нажатие. В примере выше можно подвинуть точку активации с центра ячейки на свитчер (или сделать всю ячейку кликабельной).

Например, если ячейка содержит кнопку выбора не по центру, можно переместить точку активации:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func layoutSubviews() {
            super.layoutSubviews()
            
            accessibilityActivationPoint = selectButton.accessibilityActivationPoint
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        cellView
            .accessibilityActivationPoint(.trailing)
        ```
    }
}

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

@TabNavigator {
    @Tab("UIKit") {
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
    }
    @Tab("SwiftUI") {
        ```swift
        // В SwiftUI объединяем элементы через accessibilityElement(children: .combine).
        // Зона нажатия растягивается на весь контейнер автоматически.
        HStack {
            Text(price)
            Spacer()
            Button("Добавить") { addToCart() }
        }
        .accessibilityElement(children: .combine)
        ```
    }
}

> Tip: `accessibilityFrame` работает в **экранных координатах**, а не в координатах родительского вью. Метод `UIAccessibility.convertToScreenCoordinates(_:in:)` выполняет нужное преобразование.
