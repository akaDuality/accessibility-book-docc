# Notifications

VoiceOver finds out about screen updates through notifications. Usually they're triggered automatically, but you can trigger them yourself too.

## Notifications

VoiceOver needs to be notified about changes on the screen. For this you use `UIAccessibility.Notification` notifications. There are several types of notifications

### .announcement

![](Announcement)

Voices the passed text. VoiceOver will read it without moving focus:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Item added to cart"
)
```

### .screenChanged

![](ScreenChanged)

Tells that a new screen has appeared. VoiceOver will move focus to the passed element or to the first element of the screen if you pass `nil`:

```swift
UIAccessibility.post(
    notification: .screenChanged,
    argument: titleLabel
)
```

Use this when opening a new screen, a modal window, or a complete content swap.

### .layoutChanged

![](LayoutChanged)

Tells that part of the screen has updated. VoiceOver will move focus to the passed element:

```swift
UIAccessibility.post(
    notification: .layoutChanged,
    argument: errorLabel
)
```

Use this when a new element appears — for example, an error message or loaded content.

## .pageScrolled
iOS sends this notification after a scroll, to tell about elements that have appeared. For describing a table, the text from the `accessibilityScrollStatus(for:)` method is used. Example in the chapter <doc:15-Scroll>

## .pause and .resumeAssistiveTechnology
These notifications can be triggered to disable and re-enable VoiceOver, for example, if you're playing a sound and the VoiceOver speech is in your way.

You need to pass the identifier of the technology you're stopping as a parameter:
- UIAccessibilityNotification**SwitchControlIdentifier**
- UIAccessibilityNotification**VoiceOverIdentifier**.

> Warning: After pause, you must call resume, otherwise VoiceOver or Switch Control won't turn back on.

It's worth using only in special cases and for a short time — it's too easy to disorient the user, since we're turning off their main tool for interacting with the phone.
