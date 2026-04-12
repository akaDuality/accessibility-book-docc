# Навигация между экранами

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->


## Назад

![](NavigationBack)

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

![](MagicTap)

**Magic Tap — двойной тап двумя пальцами.** Это жест для главного действия на экране: начать воспроизведение, ответить на звонок, запустить таймер.

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

## Модальные окна

![](ModalNavigation)

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
