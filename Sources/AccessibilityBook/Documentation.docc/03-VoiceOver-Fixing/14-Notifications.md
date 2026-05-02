# Оповещения

VoiceOver узнает об обновлении экрана через оповещения. Обычно они вызываются автоматически, но вы можете вызывать их и самостоятельно.

## Оповещения

VoiceOver нужно оповещать об изменениях на экране. Для этого используются оповещения `UIAccessibility.Notification`. Есть несколько типов оповещений

### .announcement

![](Announcement)

Озвучивает переданный текст. VoiceOver прочитает его без перемещения фокуса:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Товар добавлен в корзину"
)
```

### .screenChanged

![](ScreenChanged)

Сообщает, что появился новый экран. VoiceOver переместит фокус на переданный элемент или на первый элемент экрана, если передать `nil`:

```swift
UIAccessibility.post(
    notification: .screenChanged,
    argument: titleLabel
)
```

Используйте при открытии нового экрана, модального окна или полной смене содержимого.

### .layoutChanged

![](LayoutChanged)

Сообщает, что часть экрана обновилась. VoiceOver переместит фокус на переданный элемент:

```swift
UIAccessibility.post(
    notification: .layoutChanged,
    argument: errorLabel
)
```

Используйте, когда появляется новый элемент — например, сообщение об ошибке или подгруженный контент.

## .pageScrolled
iOS вызывает такое оповещение после скрола, чтобы рассказать о появившихся элементах. Для описания таблицы используют текст из метода `accessibilityScrollStatus(for:)`. Пример в главе <doc:15-Scroll>

## .pause и .resumeAssistiveTechnology
Эти оповещения можно вызвать для отключения и включения VoiceOver, например, если вы проигрываете звук и озвучка от VoiceOver вам мешает.

Параметром нужно передать идентификатор технологии, которую вы останавливаете: 
- UIAccessibilityNotification**SwitchControlIdentifier**
- UIAccessibilityNotification**VoiceOverIdentifier**. 

> Warning: После pause обязательно надо вызвать resume, иначе VoiceOver или Switch Control не включатся. 

Использовать стоит только в особых случаях и на короткое время, слишком легко дезориентировать пользователя, ведь мы отключаем его главный инструмент взаимодействия с телефоном.

