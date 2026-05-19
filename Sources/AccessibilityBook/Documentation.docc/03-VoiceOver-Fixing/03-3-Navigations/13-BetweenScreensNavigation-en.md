# Navigation between screens

How to simplify back navigation, trigger the primary action, and what you mustn't forget for modal windows.

## Back

![](NavigationBack)

The "Back" or "Close" button is the most important navigation element. It should be the first element on the screen, so the user immediately finds a way to return.

VoiceOver supports the Scrub gesture — a two-finger zigzag (the letter Z). It's the universal "back" gesture that works everywhere in iOS. It calls the method:

```swift
override func accessibilityPerformEscape() -> Bool {
    dismiss(animated: true)
    return true
}
```

The standard `UINavigationController` and `UIAlertController` support Scrub automatically. But if you're showing a custom modal window or your own navigation, implement `accessibilityPerformEscape()` manually. Return `true` if the action was performed.

Without Scrub support, the user will get stuck on the screen if they can't find the close button with swipes.

## Forward (Magic Tap)

![](MagicTap)

**Magic Tap — a double tap with two fingers.** It's the gesture for the primary action on the screen: start playback, answer a call, start a timer.

```swift
override func accessibilityPerformMagicTap() -> Bool {
    togglePlayback()
    return true
}
```

Magic Tap bubbles up the responder chain: if the current element doesn't implement the method, VoiceOver will ask its parent and so on up to `UIApplication`.

So the user knows about Magic Tap, add a hint:

```swift
playButton.accessibilityHint = "Double tap with two fingers to play."
```

## Modal windows

![](ModalNavigation)

When a modal window appears on the screen, VoiceOver focus shouldn't leave its boundaries. Without additional setup, the user will be able to swipe to elements under the modal window, which leads to confusion.

The solution:

```swift
modalView.accessibilityViewIsModal = true

UIAccessibility.post(
    notification: .screenChanged,
    argument: modalView
)
```

The `accessibilityViewIsModal` property makes VoiceOver ignore all elements outside the modal view. The focus is "trapped" inside the window.

Don't forget three things:
1. Set `accessibilityViewIsModal = true`.
2. Post `.screenChanged` so that focus moves to the modal window.
3. Implement `accessibilityPerformEscape()` so the user can close the window with the Scrub gesture.
