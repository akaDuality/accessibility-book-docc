# Ячейки в списках

Ячейки могут быть разной сложности, но всегда могут быть целым контролом для доступности. 

## Списки и ячейки

Большинство экранов в мобильных приложениях — это списки. Каждая ячейка списка обычно содержит несколько вью: картинку, заголовок, подзаголовок, иконку. Без адаптации VoiceOver будет фокусироваться на каждом из них по отдельности, заставляя пользователя совершать лишние свайпы. Так легко заблудиться и на одном экране.

![Примеры списков в приложении](simplify-lists)

Для простой навигации используйте правило: **одна ячейка — один элемент доступности.** Зрячий человек воспринимает ячейку как единое целое, и VoiceOver должен делать то же самое.

У таблиц (`UITableView`) есть системные стили, которые влияют на поведение VoiceOver: заголовки секций, футеры. Коллекции (`UICollectionView`) более примитивны — у них нет встроенной семантики, и всё нужно настраивать вручную. Рассмотрим примеры от простого к сложному.

### Простая ячейка

![Простейшая ячейка с названием города](simplify-cell-basic)

Для простой ячейки делаем всю ячейку доступным элементом, даём ей описание и добавляем свойство `.button`, чтобы пользователь понял, что на неё можно нажать.

@TabNavigator {
    @Tab("UIKit") {
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
    }
    @Tab("SwiftUI") {
        ```swift
        // В List ячейка с действием уже становится одним элементом с трейтом «кнопка»
        List(locales) { locale in
            Button {
                select(locale)
            } label: {
                Text(locale.title)
            }
        }

        // Вне List (например, в ScrollView + VStack) объединяем вручную:
        // accessibilityElement(children: .combine) делает строку одним элементом,
        // accessibilityAddTraits(.isButton) добавляет трейт «кнопка».
        ScrollView {
            VStack {
                ForEach(locales) { locale in
                    HStack {
                        Text(locale.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { select(locale) }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        ```
    }
}

Когда `isAccessibilityElement = true` стоит на ячейке, VoiceOver перестаёт искать доступные элементы внутри неё — все дочерние вью становятся невидимыми. Ячейка сама становится единым фокусом.

> Tip: для скринридера ячейка это «кнопка». Звучит странно, но важна семантика: на ячейку можно нажать, поэтому это кнопка

### Ячейка с подписью

![Ячейка с адресом и временем работы](simplify-cell-subtitle)

Усложним ячейку. Теперь у нее есть вторая строчка со временем работы. В ячейке две смысловые части: адрес и время работы, причем время нам интересно, только если это нужный нам адрес.

Мы можем объединить два текста в один через запятую и записать в accessibilityLabel. Можно интересней: время работы записать в accessibilityValue, тогда VoiceOver добавит небольшую паузу и прочитает время с другой интонацией, так появится живость речи и будет проще воспринимать на слух. 

```
label: Москва, улица Миклухо-Маклая, 36А
value: С 9 до 23
traits: кнопка
```

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        class PizzeriasTableViewCell: UITableViewCell {
            @IBOutlet weak var titleLabel: UILabel!
            @IBOutlet weak var scheduleLabel: UILabel!
            override func awakeFromNib() {
                super.awakeFromNib()
                isAccessibilityElement = true
                accessibilityTraits = .button
            }
            var title: String? {
                didSet {
                    titleLabel.text = title
                    accessibilityLabel = title
                }
            }
            var schedule: String? {
                didSet {
                    scheduleLabel.text = schedule
                    accessibilityValue = schedule
                }
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button {
            select(pizzeria)
        } label: {
            VStack(alignment: .leading) {
                Text(pizzeria.title)
                Text(pizzeria.schedule)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pizzeria.title)
        .accessibilityValue(pizzeria.schedule)
        ```
    }
}

> Tip: Разделение на `label` и `value` создаёт паузу и разную интонацию в речи VoiceOver: название читается уверенно, а значение — чуть тише и после паузы. Это помогает пользователю структурировать информацию на слух.

### Выбираемая ячейка

![Ячейка с адресом, временем работы и маркером выбранности](simplify-cell-trait)

Продолжим усложнять ячейку.
У ячейки может стоять галочка, так мы отмечаем текущую пиццерию. У VoiceOver есть
стандартный подход к обозначению выбранного элемента — трейт .selected.
Элемент можно отметить одновременно и типом (кнопка), и состоянием (выбрано),
поэтому трейты надо указывать через функции работы с OptionSet.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override public var isSelected: Bool {
            didSet {
                if isSelected {
                    accessibilityTraits.insert(.selected)
                } else {
                    accessibilityTraits.subtract(.selected)
                }
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        pizzeriaRow
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        ```
    }
}

Интересно, что даже в таком формате VoiceOver читает время как «с девять до двадцать три». Слова не склоняет, но и лишние ноли не читает.

### Отключенная ячейка

![Пиццерия по адресу сейчас закрыта](simplify-cell-disabled)

```
label: Москва, улица Миклухо-Маклая, 36А
value: С 9 до 23, сейчас закрыто
traits: недоступно, кнопка    
```

Если вам нужно показать, что ячейку сейчас выбрать нельзя, то используйте
стандартный трейт .notEnabled, он добавит к описанию «недоступно».

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        accessibilityTraits.insert(.notEnabled)
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // .disabled и блокирует взаимодействие, и добавляет трейт «недоступно»
        pizzeriaRow
            .disabled(isClosed)
        ```
    }
}

Использовать трейт `.notEnabled` нужно только для тех элементов, с которыми нельзя взаимодействовать. Если я могу выбрать адрес, то трейт `.notEnabled` указывать не нужно, и о закрытой пиццерии надо рассказать через value.

## Порядок чтения

За последние 3 страницы мы столкнулись с несколькими трейтами:
— `.selected`,
— `.notEnabled`,
— `.button`.

Каждый из них описывает одно из стандартных поведений, при этом подписи появляются в разных местах. С другой стороны, у нас есть `accessibilityLabel`, `accessibilityValue` и `accessibilityHint`. Пора разобраться в порядке чтения.

![Порядок чтения свойств скринридером](simplify-traits)

Если вы листаете большой список из элементов, то вам важнее всего узнать, какой элемент *выбран*. Затем, что это за элемент, его *label* и *value*. Когда вы поняли, что за элемент в фокусе, вы можете решить, что нужно с ним делать, поэтому *доступность* элемента, его *тип* и *подсказка*, как с ним взаимодействовать, находятся в самом конце описания. Перед `value` и `hint` есть небольшие паузы.

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
  Пепперони, 625 рублей,  выбрано,   кнопка, коснитесь дважды чтобы убрать
 ─────────────────────── ────────── ──────── ──────────────────────────────
   label        value     selected   button              hint
```

Понимание порядка чтения помогает правильно распределить информацию: самое важное — в `label`, переменное — в `value`, поведение — в `traits`.

## Сложная ячейка

![Пример ячейки в каталоге с картинкой, названием, описанием и ценой](simplify-cell-compound)

Перейдем к сложным ячейкам, когда внутри несколько контролов. Без адаптации фокус будет читать каждую надпись отдельно, и надо будет свайпнуть минимум три раза, чтобы перейти к следующему продукту.

Не все ячейки состоят из одной надписи. Представим ячейку товара: **название**, **состав** и **цена**. Зрячий человек видит это как единый блок, и VoiceOver должен работать так же. Для комфортной работы ячейка должна быть одним элементом, тогда текст будет читаться один за другим. При этом, его можно прервать, выполнив одно из действий: нажать на ячейку, перейти к следующей, или просто остановить чтение.

### Составим модель ячейки

Картинка незрячему не нужна, знать, что она там есть, тоже бесполезно. Остается 3 надписи. Как их считывает зрячий человек? Название пиццы первое и выделено жирным. Скорее всего, следующим он прочитает цену, ведь на ней цветовой акцент, а состав в последнюю очередь, потому что он длинный и блеклый. Итак, порядок восприятия такой:
— название,
— цена,
— состав.

Название и цену можно объединить через запятую и поставить в label. Состав отделить интонацией и сохранить в value.

```
label: Крэйзи пепперони, от 395 рублей
value: Пикантная пепперони, цыпленок, моцарелла, томатный соус, кисло-сладкий соус.
trait: кнопка
```

> Hint: в графическом дизайне порядок восприятия не всегда правильный,
опрятность верстки иногда важнее смысла.

Код для доступности достаточно прост: делаем ячейку доступной, даем ей описание и поведение кнопки, а затем лишь собираем две строчки с описанием.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func awakeFromNib() {
            super.awakeFromNib()
            isAccessibilityElement = true
            accessibilityTraits = .button
        }

        func updateAccessibility(title: String,
                                 price: String,
                                 ingredients: String?) {
            accessibilityLabel = [title, price].joined(separator: ", ")
            accessibilityValue = ingredients
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button {
            select(pizza)
        } label: {
            VStack(alignment: .leading) {
                Text(pizza.title)
                Text(pizza.price)
                Text(pizza.ingredients ?? "")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pizza.title), \(pizza.price)")
        .accessibilityValue(pizza.ingredients ?? "")
        ```
    }
}
    
Если продукт недоступен, то кнопка с ценой заменится на надпись «будет позже». Для VoiceOver графическая смена контролов неважна, поэтому просто меняем текст цены:
```
label: Крэйзи пепперони, будет позже
value: Пикантная пепперони, цыпленок, моцарелла, томатный соус, кисло-сладкий
соус.
trait: кнопка
```

С учетом этого, код становится лишь чуть сложнее:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        func updateAccessibility(
            title: String,
            price: String,
            ingredients: String?,
            isProductAvailable: Bool
        ) {
            let price = isProductAvailable ? price : "Будет позже"
            accessibilityLabel = [title, price].joined(separator: ", ")
            accessibilityValue = ingredients
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        let displayPrice = pizza.isAvailable ? pizza.price : "Будет позже"

        pizzaRow
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(pizza.title), \(displayPrice)")
            .accessibilityValue(pizza.ingredients ?? "")
        ```
    }
}

Можно добавить трейт отключенности элемента, но только если на ячейку нельзя нажать. 

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        func updateAccessibility(
            title: String,
            price: String,
            ingredients: String,
            isProductAvailable: Bool
        ) {
            isAccessibilityElement = true

            let price = isProductAvailable ? price : "Будет позже"
            accessibilityLabel = [title, price].joined(separator: ", ") 
            accessibilityValue = ingredients

            if isProductAvailable {
                accessibilityTraits = .button
            } else {
                accessibilityTraits = [.button, .notEnabled]
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        let displayPrice = pizza.isAvailable ? pizza.price : "Будет позже"

        pizzaRow
            .disabled(!pizza.isAvailable)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(pizza.title), \(displayPrice)")
            .accessibilityValue(pizza.ingredients)
        ```
    }
}

Еще более сложный пример мы разберем в главе <doc:12-CustomDescription>
