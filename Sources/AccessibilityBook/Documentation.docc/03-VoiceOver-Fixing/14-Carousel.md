# Карусель

Почти в каждом приложении есть «карусель» — горизонтальный скролл из элементов: баннеры, кнопки разделов, блок допродаж и т.п. Такой элемент требует особой адаптации для VoiceOver, чтобы им было удобно пользоваться. 

Горизонтальная `UICollectionView` — одна из самых проблемных конструкций для VoiceOver. По умолчанию все ячейки карусели выстраиваются в один ряд, и пользователь свайпает через десятки элементов, не понимая, что это горизонтальный список.

Решение — создать единый доступный элемент с трейтом `.adjustable`

## Карусель

Карусель — это довольно частый элемент интерфейса. Как правило, элементы внутри карусели имеют один вид и на них можно нажать. Чаще всего люди перемещаются к следующему контролу свайпом. Для VoiceOver карусели становятся проблемой, так как ему сначала приходится пройти по всем элементам внутри нее и только потом получается перейти к следующей группе. Вполне возможно, что следующие контролы тоже будут каруселью и все по новой. Например, после акций идут новинки, а после них виды продуктов. Нужно сделать несколько десятков свайпов, чтобы добраться до первой пиццы.

Было бы намного удобней, если бы вся карусель была одним элементом, а ячейки внутри нее можно было бы переключать вертикальным свайпом. Активировать можно двойным тапом: открыть новый экран, выбрать элемент и т.п. 

Для подобного хорошо подходит элемент регулировки и трейт .adjustable.

Apple предлагает [интересный ход](https://developer.apple.com/documentation/uikit/accessibility_for_ios_and_tvos/delivering_an_exceptional_accessibility_experience): создать доступный элемент, который будет управлять
каруселью, положить его поверх коллекции, а графическую карусель спрятать от
VoiceOver. Попробуем.

![](CarouselExamples)
Горизонтальная `UICollectionView` — одна из самых проблемных конструкций для VoiceOver. По умолчанию все ячейки карусели выстраиваются в один ряд, и пользователь свайпает через десятки элементов, не понимая, что это горизонтальный список.

Решение — создать единый доступный элемент с трейтом `.adjustable`:

Создадим новый UIAccessibilityElement. Можно типизировать контейнер и принимать только коллекции, ведь именно из них мы будем брать все нужные параметры.

```swift
init(accessibilityContainer: UICollectionView, title: String) {
    self.collectionView = accessibilityContainer
    
    super.init(accessibilityContainer: accessibilityContainer)
    
    accessibilityTraits = .adjustable
    accessibilityLabel = title
    accessibilityFrameInContainerSpace = collectionView.frame
}
```

Конструктор предполагает, что фрейм у коллекции уже посчитан, поэтому код можно вызывать только после лейаута, например, во viewDidAppear(:). Вызываю его внутри UICollectionViewController, чтобы все что есть в accessibilityElements заменилось на один новый контрол.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    view.accessibilityElements = [
        AccessibilityCarousel(accessibilityContainer: collectionView,
                              title: "Акции")
    ]
}
```

В первую очередь карусель — это горизонтальный UICollectionView и скрол по нему должен переключать на следующий элемент. Скролить его можно тремя пальцами: пусть показывает следующий элемент, ставит фокус на него и читает описание.

```swift
override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    if direction == .left {
        return collectionView.accessibilityScrollForward()
    } else if direction == .right {
        return collectionView.accessibilityScrollBackward()
    }
    
    return false
} 
```

После скрола VoiceOver будет читать value, для него будем брать центральную ячейку, склеивать eё label и value и выводить как описание текущего элемента. В идеале надо добавить и описание позиции: «3 из 12».
```swift
override var accessibilityValue: String? {
    get {
        guard let сell = centerCell() else { return nil }
        
        return [сell.accessibilityLabel,
                сell.accessibilityValue]
                    .compactMap { $0 }
                    .joined(separator: ", ")
    }
    set {}
}
```

Коллекция имеет тип .adjustable, поэтому нужно реализовать методы, которые вызовутся после свайпов. По вертикальному свайпу пусть тоже скролит до элемента.
```swift
override func accessibilityIncrement() {
    collectionView.accessibilityScrollForward()
}
    
override func accessibilityDecrement() {
    collectionView.accessibilityScrollBackward()
}
```

Функция скрола простая: берем центральный элемент, считаем какой будет следующим и скролим до него. Скрол назад выглядит так же.

```swift
@discardableResult
func accessibilityScrollForward() -> Bool {
    guard let cell = centerCell(),
        let path = indexPath(for: cell),
        let nextPath = nextPath(for: path)
    else { return false }
    
    scrollAndFocus(path: nextPath)
    return true
}
```

После свайпа мы должны проскролить до следующей ячейки и центрировать ее. Дополнительно мы опираемся на свойство selectionFollowFocus — это стандартное свойство позволяет выбирать элемент, как только он попадает в фокус. Такое поведение пригодится, чтобы моментально выбирать тип продукта, а вот для акций это не нужно.

```swift
func scrollAndFocus(path: IndexPath) {
    scrollToItem(at: path,
                 at: .centeredHorizontally,
                 animated: true)
    
    if selectionFollowsFocus {
        selectAsUser(path: path)
    }
}
```

![](CategoriesPicker)
> Tip: Сразу выбирать раздел после скрола можно с помощью свойства selectionFollowsFocus

Если selectionFollowFocus не установлен, то выбрать элемент можно двойным
тапом через функцию accessibilityActivate().

```swift
override func accessibilityActivate() -> Bool {
    guard let path = сollectionView.centerPath() else { return false }
    
    сollectionView.selectAsUser(path: path)
    return true
}
```
О сложном поведении контрола расскажет стандартная подсказка для.adjustable:
«смахните вверх или вниз одним пальцем, чтобы изменить значение».

На самом деле, .adjustable-карусель будет мешать UI-тестам, но об этом будет в разделе
про Voice Control.

Полный код со вспомогательными функциями можно посмотреть [на гитхабе](https://github.com/akaDuality/AccessibilityCarousel).

На этом критичные проблемы навигации внутри страницы заканчиваются и можно
посмотреть, как незрячие еще могут перемещаться по странице.





















```swift
class AccessibilityCarousel: UIAccessibilityElement {

    weak var collectionView: UICollectionView?

    override var accessibilityTraits: UIAccessibilityTraits {
        get { return .adjustable }
        set { }
    }

    override var accessibilityValue: String? {
        get {
            guard let collectionView = collectionView,
                  let currentIndex = currentVisibleIndex else {
                return nil
            }
            let cell = collectionView.cellForItem(
                at: IndexPath(item: currentIndex, section: 0)
            )
            return cell?.accessibilityLabel
        }
        set { }
    }

    override func accessibilityIncrement() {
        scrollToNext()
    }

    override func accessibilityDecrement() {
        scrollToPrevious()
    }

    override func accessibilityScroll(
        _ direction: UIAccessibilityScrollDirection
    ) -> Bool {
        switch direction {
        case .left:
            scrollToNext()
            return true
        case .right:
            scrollToPrevious()
            return true
        default:
            return false
        }
    }
}
```

Трейт `.adjustable` позволяет менять значение вертикальными свайпами: свайп вверх вызывает `accessibilityIncrement()`, свайп вниз — `accessibilityDecrement()`. Пользователь одним свайпом переключает ячейку карусели, а `accessibilityValue` описывает текущую ячейку.

