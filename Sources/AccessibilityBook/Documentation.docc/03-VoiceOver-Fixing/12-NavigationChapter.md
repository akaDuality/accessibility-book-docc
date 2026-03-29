# Навигация

Управление порядком элементов, группировка, ротор, оповещения и другие инструменты навигации VoiceOver.

## Overview

Мы разобрались с основными элементами и их поведением, теперь нужно перемещаться между ними. Обычно, для этого хватает горизонтальных свайпов, но есть еще несколько удобных жестов для упрощения навигации.

Типичные проблемы навигации: элементы перепутали порядок, фокус застрял в горизонтальной карусели, всплывающее окно нельзя закрыть.

Навигацию можно не только исправить, но и улучшить: правильно разметить заголовки, дать название важным областям интерфейса. У VoiceOver есть очень необычный «ротор», с его помощью можно управлять способом навигации по интерфейсу.

## Группировка

VoiceOver читает элементы слева направо, сверху вниз — как текст. При этом он игнорирует иерархию вью: неважно, в каком контейнере лежит элемент, порядок чтения определяется расположением на экране.

Но иногда элементы расположены в одну строку, и визуально они образуют группы, которые VoiceOver должен читать вместе. На панеле оценок в App Store: звёзды, количество оценок и возрастной рейтинг стоят в одну линию. Без группировки VoiceOver прочитает их в одну строку, перемешав данные из разных блоков.

![](Navigation-wrongOrder)

Чтобы VoiceOver обходил элементы внутри группы последовательно, а не чередовал их с соседними, используйте свойство:

```swift
reviewView.shouldGroupAccessibilityChildren = true
ageView.shouldGroupAccessibilityChildren = true
ratingView.shouldGroupAccessibilityChildren = true
```

![](Navigation-fixedOrder)

Когда у контейнера включена группировка, VoiceOver сначала прочитает все дочерние элементы этого контейнера и только потом перейдёт к следующей группе. Это не меняет порядок внутри группы — там он по-прежнему определяется расположением на экране, — но гарантирует, что элементы одной группы не перемешаются с элементами другой.

## Скролл и порядок элементов

Частая проблема: на экране есть `UIScrollView` с контентом и фиксированные кнопки поверх него — например, кнопка закрытия и корзина. VoiceOver начинает обход с первого сабвью экрана, и если это `UIScrollView`, он прочитает весь скролл-контент, прежде чем доберётся до фиксированных кнопок. Порядок ломается.

Решение — явно задать массив `accessibilityElements` у контейнера:

```swift
override var accessibilityElements: [Any]? {
    get {
        return [closeButton, cartButton, scrollView, settingsView]
    }
    set { }
}
```

Теперь VoiceOver сначала прочитает кнопку закрытия, затем корзину, потом содержимое скролла и в конце — панель настроек. Порядок полностью под вашим контролем.

Массив `accessibilityElements` — мощный инструмент. Он позволяет не только задать порядок, но и убрать лишние элементы или добавить новые, которых нет в иерархии вью.

## Карусель

Горизонтальная `UICollectionView` — одна из самых проблемных конструкций для VoiceOver. По умолчанию все ячейки карусели выстраиваются в один ряд, и пользователь свайпает через десятки элементов, не понимая, что это горизонтальный список.

Решение — создать единый доступный элемент с трейтом `.adjustable`:

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

## Ротор

Ротор — жест вращения двумя пальцами, как будто крутите невидимую ручку. Он переключает режим навигации: заголовки, контейнеры, ссылки, элементы формы и другие. После выбора режима вертикальные свайпы будут перепрыгивать между элементами этого типа.

Например, выберите режим «Заголовки» и свайпайте вниз — фокус будет перепрыгивать от заголовка к заголовку, пропуская всё остальное. Это аналог пролистывания глазами структуры страницы.

В iOS 14 у ротора больше 40 режимов: заголовки, контейнеры, ссылки, элементы формы, таблицы, изображения, статический текст, горизонтальная навигация, вертикальная навигация и многие другие. Пользователь сам выбирает, какие из них будут доступны, в настройках VoiceOver.

## Заголовки

Трейт `.header` добавляет к описанию элемента слово «заголовок»:

```swift
titleLabel.accessibilityTraits.insert(.header)
```

Заголовки — один из основных способов навигации через ротор. Пользователь переключает ротор в режим «Заголовки» и вертикальными свайпами перемещается от заголовка к заголовку, быстро изучая структуру экрана.

Заголовки секций в `UITableView` поддерживаются автоматически — VoiceOver уже знает, что это заголовки. Но если вы делаете кастомный хедер, не забудьте добавить трейт `.header` вручную.

В отличие от HTML, в iOS нет уровней заголовков (h1, h2, h3). Есть только один трейт `.header`, и ротор перепрыгивает по всем заголовкам одинаково. Поэтому заголовков не должно быть слишком много — иначе навигация по ним теряет смысл.

## Контейнеры

Контейнер — это логическая группа элементов, у которой может быть имя. VoiceOver объявляет имя контейнера, когда фокус в него входит, — это помогает понять структуру экрана.

Задайте тип контейнера через `accessibilityContainerType`:

```swift
stackView.accessibilityContainerType = .semanticGroup
stackView.accessibilityLabel = "Рейтинг и отзывы"
```

Доступные типы:

- `.semanticGroup` — логическая группа элементов. VoiceOver произнесёт имя при входе.
- `.list` — список. VoiceOver скажет количество элементов.
- `.table` — таблица. Требует реализации протокола `UIAccessibilityContainerDataTable`.

Тип `.table` самый сложный. Чтобы VoiceOver мог навигировать по строкам и столбцам таблицы, нужно реализовать протокол `UIAccessibilityContainerDataTable`:

```swift
extension DataTableView: UIAccessibilityContainerDataTable {

    func accessibilityDataTableCellElement(
        forRow row: Int,
        column: Int
    ) -> UIAccessibilityContainerDataTableCell? {
        return cells[row][column]
    }

    func accessibilityRowCount() -> Int {
        return cells.count
    }

    func accessibilityColumnCount() -> Int {
        return cells.first?.count ?? 0
    }
}
```

Каждая ячейка должна поддерживать протокол `UIAccessibilityContainerDataTableCell` с указанием строки и столбца.

## Контейнер без вью

Иногда нужно создать логический контейнер, который не соответствует никакому вью в иерархии. Например, вы хотите сгруппировать несколько элементов, которые лежат в разных частях иерархии.

Создайте `UIAccessibilityElement` как невидимый контейнер:

```swift
let container = UIAccessibilityElement(
    accessibilityContainer: parentView
)
container.accessibilityLabel = "Информация о заказе"
container.accessibilityContainerType = .semanticGroup
container.accessibilityFrameInContainerSpace = combinedFrame
container.accessibilityElements = [
    orderNumberLabel,
    statusLabel,
    dateLabel
]
```

Свойство `accessibilityFrameInContainerSpace` задаёт рамку контейнера в координатах родительского вью. Это удобнее, чем `accessibilityFrame`, которое работает в координатах экрана.

Элемент не отображается визуально, но VoiceOver видит его как контейнер и объявляет имя при входе.

## Кастомный ротор

`UIAccessibilityCustomRotor` позволяет добавить свои режимы навигации в ротор. Это мощный инструмент, когда стандартных режимов недостаточно.

Пример: навигация между секциями таблицы.

```swift
let sectionRotor = UIAccessibilityCustomRotor(
    name: "Секции"
) { predicate in
    let forward = predicate.searchDirection == .next
    let currentItem = predicate.currentItem.targetElement

    // Найти следующую секцию
    guard let nextHeader = self.findNextSectionHeader(
        after: currentItem,
        forward: forward
    ) else {
        return nil
    }

    return UIAccessibilityCustomRotorItemResult(
        targetElement: nextHeader,
        targetRange: nil
    )
}

self.accessibilityCustomRotors = [sectionRotor]
```

Ротор создаётся с именем и обработчиком. Обработчик получает `UIAccessibilityCustomRotorSearchPredicate` с направлением поиска и текущим элементом. Он должен вернуть `UIAccessibilityCustomRotorItemResult` с целевым элементом или `nil`, если элементов больше нет.

Кастомные роторы появляются в списке после стандартных. Пользователь крутит ротор и видит ваш пункт наравне с «Заголовками» и «Контейнерами». Присваивайте роторам понятные имена.

## Оповещения

VoiceOver нужно оповещать об изменениях на экране. Для этого используются нотификации `UIAccessibility.Notification`:

### .announcement

Озвучивает переданный текст. VoiceOver прочитает его без перемещения фокуса:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Товар добавлен в корзину"
)
```

### .screenChanged

Сообщает, что появился новый экран. VoiceOver переместит фокус на переданный элемент или на первый элемент экрана, если передать `nil`:

```swift
UIAccessibility.post(
    notification: .screenChanged,
    argument: titleLabel
)
```

Используйте при открытии нового экрана, модального окна или полной смене содержимого.

### .layoutChanged

Сообщает, что часть экрана обновилась. VoiceOver переместит фокус на переданный элемент:

```swift
UIAccessibility.post(
    notification: .layoutChanged,
    argument: errorLabel
)
```

Используйте, когда появляется новый элемент — например, сообщение об ошибке или подгруженный контент.

### Другие нотификации

- `.pageScrolled` — сообщает новое положение скролла. VoiceOver прочитает переданный текст после скролла.
- `.pauseAssistiveTechnology` — приостановить VoiceOver. Используйте осторожно, только когда это действительно нужно.
- `.resumeAssistiveTechnology` — возобновить работу VoiceOver.

## Списки в таблице

Когда `UITableView` скроллится жестом трёх пальцев, VoiceOver должен рассказать, что сейчас видно на экране. Для этого реализуйте `UIScrollViewAccessibilityDelegate`:

```swift
extension ViewController: UIScrollViewAccessibilityDelegate {

    func accessibilityScrollStatus(
        for scrollView: UIScrollView
    ) -> String? {
        let visibleRows = tableView.indexPathsForVisibleRows ?? []
        guard let first = visibleRows.first,
              let last = visibleRows.last else {
            return nil
        }
        return "Показаны строки с \(first.row + 1) по \(last.row + 1) из \(items.count)"
    }
}
```

VoiceOver вызывает `accessibilityScrollStatus(for:)` после каждого скролла и озвучивает возвращённую строку. Это помогает пользователю понять, где он находится в списке.

Для ручного управления скроллом реализуйте `accessibilityScroll(_:)`:

```swift
override func accessibilityScroll(
    _ direction: UIAccessibilityScrollDirection
) -> Bool {
    switch direction {
    case .down:
        scrollToNextPage()
        return true
    case .up:
        scrollToPreviousPage()
        return true
    default:
        return false
    }
}
```

Верните `true`, если скролл выполнен, `false` — если нет.

## Назад

Кнопка «Назад» или «Закрыть» — важнейший элемент навигации. Она должна быть первым элементом на экране, чтобы пользователь сразу нашёл способ вернуться.

VoiceOver поддерживает жест Scrub — зигзаг двумя пальцами (буква Z). Это универсальный жест «назад», который работает везде в iOS. Он вызывает метод:

```swift
override func accessibilityPerformEscape() -> Bool {
    dismiss(animated: true)
    return true
}
```

Стандартные `UINavigationController` и `UIAlertController` поддерживают Scrub автоматически. Но если вы показываете кастомное модальное окно или самописную навигацию, реализуйте `accessibilityPerformEscape()` вручную. Верните `true`, если действие выполнено.

Без поддержки Scrub пользователь застрянет на экране, если не сможет найти кнопку закрытия свайпами.

## Вперёд (Magic Tap)

Magic Tap — двойной тап двумя пальцами. Это жест для главного действия на экране: начать воспроизведение, ответить на звонок, запустить таймер.

```swift
override func accessibilityPerformMagicTap() -> Bool {
    togglePlayback()
    return true
}
```

Magic Tap поднимается по цепочке респондеров: если текущий элемент не реализует метод, VoiceOver спросит у его родителя и так далее до `UIApplication`.

Чтобы пользователь узнал про Magic Tap, добавьте подсказку:

```swift
playButton.accessibilityHint = "Нажмите дважды двумя пальцами для воспроизведения."
```

## Подсказки

`accessibilityHint` — это дополнительная подсказка, которую VoiceOver читает после короткой паузы. Пользователь может отключить подсказки в настройках, поэтому не кладите туда важную информацию.

Правила хорошей подсказки:

- Начинается с глагола в третьем лице: «Включит», «Откроет», «Удалит».
- Первая буква заглавная.
- Заканчивается точкой.
- Кратко — одно предложение.
- Описывает результат действия, а не способ.

```swift
// Хорошо
cell.accessibilityHint = "Включит песню."
deleteButton.accessibilityHint = "Удалит выбранные сообщения."

// Плохо
cell.accessibilityHint = "Тапните дважды чтобы включить"
deleteButton.accessibilityHint = "Кнопка удаления"
```

Не дублируйте `accessibilityLabel` в `accessibilityHint`. Подсказка отвечает на вопрос «Что произойдёт?», а не «Что это?».

## Модальное

Когда на экране появляется модальное окно, фокус VoiceOver не должен уходить за его пределы. Без дополнительной настройки пользователь сможет свайпать на элементы под модальным окном, что приводит к путанице.

Решение:

```swift
modalView.accessibilityViewIsModal = true

UIAccessibility.post(
    notification: .screenChanged,
    argument: modalView
)
```

Свойство `accessibilityViewIsModal` заставляет VoiceOver игнорировать все элементы за пределами модального вью. Фокус «ловится» внутри окна.

Не забудьте три вещи:
1. Установить `accessibilityViewIsModal = true`.
2. Отправить `.screenChanged`, чтобы фокус переместился на модальное окно.
3. Реализовать `accessibilityPerformEscape()`, чтобы пользователь мог закрыть окно жестом Scrub.

## Крайние элементы

VoiceOver позволяет быстро перейти к первому или последнему элементу экрана: тап четырьмя пальцами вверху экрана переместит фокус на первый элемент, тап четырьмя пальцами внизу — на последний.

Этим пользуются часто, поэтому продумайте, какой элемент будет первым и каким — последним:

- **Первый элемент** — кнопка «Закрыть» или «Назад». Пользователь ожидает найти способ выйти с экрана в самом начале.
- **Последний элемент** — кнопка подтверждения, «Оплатить», «Сохранить». Пользователь перепрыгивает в конец, чтобы выполнить целевое действие.

Управляйте порядком через `accessibilityElements`, чтобы крайние элементы были именно теми, которые нужны пользователю.

## Скролл

`UIScrollView` по умолчанию работает как контейнер доступности: VoiceOver обходит его дочерние элементы и скроллит содержимое автоматически. Но иногда нужен контроль.

Для кастомного скролла реализуйте `accessibilityScroll(_:)`:

```swift
override func accessibilityScroll(
    _ direction: UIAccessibilityScrollDirection
) -> Bool {
    switch direction {
    case .down:
        guard currentPage < totalPages - 1 else { return false }
        currentPage += 1
        scrollToPage(currentPage)

        UIAccessibility.post(
            notification: .pageScrolled,
            argument: "Страница \(currentPage + 1) из \(totalPages)"
        )
        return true

    case .up:
        guard currentPage > 0 else { return false }
        currentPage -= 1
        scrollToPage(currentPage)

        UIAccessibility.post(
            notification: .pageScrolled,
            argument: "Страница \(currentPage + 1) из \(totalPages)"
        )
        return true

    default:
        return false
    }
}
```

После скролла обязательно отправьте нотификацию `.pageScrolled` с описанием текущего положения. VoiceOver прочитает этот текст, и пользователь поймёт, куда он проскроллил. Без этой нотификации скролл будет «тихим», и пользователь потеряется в содержимом.
