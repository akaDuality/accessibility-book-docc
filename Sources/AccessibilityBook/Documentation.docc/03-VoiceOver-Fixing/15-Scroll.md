# Скролл
Скролл редко приходится адаптировать самостоятельно, но интересно разобрать как он работает для доступности. 

> Warning: Это сложная глава для самых опытных, чтобы лучше понять как всё работает изнутри.

UIScrollView — это интересный пример контейнера для доступных элементов:
— он реагирует на перемещение фокуса и подскроливает, чтобы элемент был виден;
— его можно проскролить тремя пальцами и он обновит положение фокуса;
— после скрола он прочитает описание контента: на какой вы странице (2 из 3), где стоит фокус (в центре экрана).

Обычно для адаптации ничего дополнительного делать не нужно, UIScrollView сам по себе работает хорошо. Тем не менее посмотрим, какие методы нужно реализовать, если вам нужно повторить его поведение. Сценарий VoiceOver такой:

1. Пользователь свайпает тремя пальцами в одном из четырех направлений.
2. VoiceOver ищет элемент, который может обработать событие accessibilityScroll(:) и передает ему направление скрола.
3. Вы можете на каком-то уровне перехватить это событие и проскролить. Если вы обработали событие, то верните true, так закончится поиск. По дефолту возвращается false и VoiceOver продолжает подниматься по иерархии UIView, пока не найдет того, кто может обработать.
4. Внутри функции вы решаете, что делать с направлением скрола. Скрол, таблицы и коллекции сдвигаются на один экран.
5. Допустим, вы решили тоже проскролить на один экран. После скрола нужно отправить оповещение .pageScrolled и описать новое состояние экрана. UITableView запрашивает описание из accessibilityScrollStatus(for:), а UIScrollView читает текущее положение: «Страница 3 из 12». Вместе с оповещением VoiceOver издаст специальную вибрацию.

В итоге вам надо реализовать accessibilityScroll(:), правильно проскролить и вызвать оповещение. Давайте посмотрим на примере. Карточка продукта может быть длинной, дополнительных ингредиентов может быть много, они прячутся под кнопкой добавления в корзину. При этом весь экран находится в UIPageViewController, его можно свайпнуть горизонтально, чтобы сменить продукт (жаль, что пока визуально это никак не видно).

Проскролить экран нужно в двух случаях:
- если вы свайпнули тремя пальцами вертикально, чтобы посмотреть, что ниже. При этом нужно не сломать горизонтальный скрол для смены продуктов.
- если фокус попал за пределы экрана, то нужно подскролить, чтобы фокус стал виден.

На уровне контроллера, который содержит UIScollView, нужно реализовать метод accessibilityScroll(:), обработать только вертикальные свайпы, а для горизонтальных вернуть false, так VoiceOver пойдет по иерархии контроллеров к дочерним, чтобы проверить, могут ли они обработать свайп. А они могут: родительский UIPageController может обработать горизонтальный свайп и показать другой продукт.

По направлению свайпа можно понять, в какую сторону скролить. Экран простой, поэтому нужно скролить либо до начала экрана, либо до конца, этого достаточно. После скрола сообщите VoiceOver об обновлении через оповещение и расскажите о новом состоянии экрана. Ничего лучше, чем «верх» и «низ» я не придумал.

```swift
override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    switch direction {
    case .up:
        view().contentScrollView.scrollToTop()
        UIAccessibility.post(notification: .pageScrolled, argument: "Верх")
        return true
        
    case .down:
        view().contentScrollView.scrollToBottom()
        UIAccessibility.post(notification: .pageScrolled, argument: "Низ")
        return true
                             
    default:
        return false
    }
} 
```

Теперь нужно скролить экран после переключения фокуса на контрол за границами видимой области. Обычно UIScrollView обрабатывает это самостоятельно, реализуя протокол UIFocusItemScrollableContainer. Если стандартное поведение не срабатывает, то мы можем написать свое: наследоваться от UIScrollView и реализовать все, что нужно.

О смене фокуса UIKit оповещает через.elementFocusedNotification. Подпишемся на него в тот момент, когда вью становится частью иерархии. Отписываться от него не нужно, если мы пишем для iOS 9+.

```swift
override func didMoveToSuperview() {
    super.didMoveToSuperview()
    observeFocusUpdate()
}
    
private func observeFocusUpdate() {
    NotificationCenter.default
        .addObserver(
            self,
            selector: #selector(focusDidChanged(_:)),
            name: UIAccessibility.elementFocusedNotification,
            object: nil)
}
```

При смене фокуса нужно получить текущий элемент, на котором стоит фокус, проскролить до него, чтобы его стало видно и сообщить о том, что лейаут страницы поменялся. Фокус оставим на самом элементе.

```swift
@objc private func focusDidChanged(_ notification: Notification) {
    guard let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIView 
    else { return }

    scrollRectToVisible(element.bounds, animated: false)
    UIAccessibility.post(notification: .layoutChanged, argument: element)
}
```

Для правильной работы VoiceOver нужно выполнить еще несколько условий:
1. Нужно проверять, что элемент является дочерним для вью, так как мы получаем оповещение от всех контролов на экране, а нужны только те, что внутри скрола.
2. Нужно конвертировать фрейм элемента в координаты UIScrollView, потому что он может быть вложенным в другие вью.
3. Оповещение нужно, только если скрол реально произошел, иначе VoiceOver будет неправильно ставить фокус, когда вы выходите из UIScrollView.

```swift
@objc private func focusDidChanged(_ notification: Notification)
    {
    guard let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey]
    as? UIView else { return }
    
    guard element.isChild(of: self) else { return }
    
    let offsetChanged = scroll(to: element)
    guard offsetChanged
    else { return } // No need to set focus of items that has been focused already
    
    UIAccessibility.post(notification: .layoutChanged, argument: element)
}
```

Вспомогательный код из предыдущих примеров кода:
4. Функция, что конвертирует фреймы, скролит и проверяет изменился ли оффсет. По
смещению мы поймем, что надо оповещать VoiceOver о смене лейаута.

```swift
extension UIScrollView {
    fileprivate func scroll(to view: UIView) -> Bool {
        let oldOffset = contentOffset
    
        scrollRectToVisible(convert(view.bounds, from: view), animated: false)
    
        let offsetChanged = oldOffset != contentOffset
        return offsetChanged
    }
}
```

5. Рекурсивная функция проверяет, является ли элемент дочерним, чтобы UIScrollView обрабатывал только свои элементы.

```swift
extension UIView {
    fileprivate func isChild(of parentView: UIView) -> Bool {
        for subview in parentView.subviews {
            if subview === self {
                return true
            }
            
            if isChild(of: subview) {
                return true
            }
        }
        
        return false
    }
}
```

Теперь при смене фокуса UIScrollView будет подскроливать так, чтобы элемент в фокусе был виден на экране. Обычно он работает и сам, но если что-то пойдет не так, вы знаете как поправить.

@Comment {
    Рассказать про кастомные заголовки
}  
