# Miscellaneous

Traits, haptics, errors, loading, voice, and other aspects of accessibility.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

@Comment {
    
    ## Порядок чтения

    За последние 3 страницы мы столкнулись с несколькими трейтами:
    — `.selected`,
    — `.notEnabled`,
    — `.button`.

    Каждый из них описывает одно из стандартных поведений, при этом подписи появляются в разных местах. С другой стороны, у нас есть `accessibilityLabel`, `accessibilityValue` и `accessibilityHint`. Пора разобраться в порядке чтения.

    ![Порядок чтения свойств скринридером](simplify-traits)

    Если вы листаете большой список из элементов, то вам важнее всего узнать, какой элемент выбран. Затем, что это за элемент, его label и value. Когда вы поняли, что за элемент в фокусе, вы можете решить, что нужно с ним делать, поэтому доступность элемента, его тип и подсказка, как с ним взаимодействовать, находятся в самом конце описания. Перед value и hint есть небольшие паузы.

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

}

## Traits

@Comment {
    Extract to article
}

Traits are element properties that affect how VoiceOver voices it and how it interacts with it. They are set via `accessibilityTraits` and split into several categories.

### Element type

The type trait adds a word to the description and changes behavior:

| Trait | Description |
|-------|----------|
| `.button` | Button. VoiceOver adds "button" and allows a double tap |
| `.adjustable` | Adjustable element. Vertical swipes appear for changing the value |
| `.image` | Image. VoiceOver adds "image" |
| `.link` | Link. VoiceOver adds "link", the element appears in the "Links" rotor |
| `.searchField` | Search field. VoiceOver adds "search field" |
| `.keyboardKey` | A keyboard key. Activated by lifting the finger in touch typing mode |
| `.tab` | Tab. VoiceOver adds "tab" |

### State

| Trait | Description |
|-------|----------|
| `.selected` | Selected element. VoiceOver will say "selected" |
| `.notEnabled` | Disabled element. VoiceOver will say "not enabled" |

### Navigation

| Trait | Description |
|-------|----------|
| `.header` | Heading. Appears in the "Headings" rotor, the user can jump between headings |
| `.summaryElement` | Summary element. Read on entering the screen |

### Interaction

| Trait | Description |
|-------|----------|
| `.allowsDirectInteraction` | Direct touch. VoiceOver passes touches directly to the element |
| `.playsSound` | The element plays sound. VoiceOver will fall silent so as not to interrupt |
| `.startsMediaSession` | Starts a media session. VoiceOver will be silent during playback |
| `.causesPageTurn` | Causes a page turn. VoiceOver will wait for the new page |

### Updating

| Trait | Description |
|-------|----------|
| `.updatesFrequently` | Updates frequently. VoiceOver will check the value more often |
| `.staticText` | Static text |
| `.none` | No traits |

### Working with traits

Traits are an `OptionSet`, so they can be combined, added, and removed:

```swift
// Set several traits
cell.accessibilityTraits = [.button, .header]

// Add a trait
cell.accessibilityTraits.insert(.selected)

// Remove a trait
cell.accessibilityTraits.remove(.selected)
```

> Note: Don't use `accessibilityTraits = .selected` for adding — that will replace all existing traits. Instead, use `insert`.

## Hidden traits

In iOS there are undocumented traits, accessible via `rawValue`. They can be found by iterating through bit shifts:

```swift
let trait = UIAccessibilityTraits(rawValue: 1 << 19)
```

Bits 19 through 60 contain hidden traits that Apple uses internally. Among them are traits for tab, status bar, search bar, popup button, subscript text, and other elements.

Using undocumented traits in production is risky — Apple may change them at any moment. But it's useful to know about them for researching the behavior of standard controls.

## Haptics

Tactile feedback helps blind users get confirmation of an action. iOS has two main generators available.

### UISelectionFeedbackGenerator

A light vibration when switching between elements:

```swift
let generator = UISelectionFeedbackGenerator()
generator.prepare()
generator.selectionChanged()
```

Call the `prepare()` method in advance — it warms up the Taptic Engine so the vibration happens instantly.

### UINotificationFeedbackGenerator

Three types of notifications with different intensity:

```swift
let generator = UINotificationFeedbackGenerator()
generator.prepare()

generator.notificationOccurred(.success) // Light: operation completed
generator.notificationOccurred(.warning) // Medium: warning
generator.notificationOccurred(.error)   // Strong: error
```

Example of use:

```swift
func submitForm() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()

    if validate() {
        save()
        generator.notificationOccurred(.success)
    } else {
        generator.notificationOccurred(.error)
    }
}
```

> Tip: To pick the right vibration you can use Apple's Haptic Composer app, which is included in Xcode Additional Tools.

## Errors

Error messages in forms are a common accessibility problem. Here are a few rules.

### Show the error next to the field

Don't display a single error at the top of the whole screen — a blind user may not notice it. Tie the error text to the specific field:

```swift
emailField.accessibilityLabel = "Email"
emailField.accessibilityValue = "Error: invalid address format"
```

### Announce errors through notifications

When an error appears, tell VoiceOver about it:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Error: invalid email format"
)
```

### Don't hide errors on a timer

If the error message disappears after a few seconds, a blind user may not manage to get to it. The error should stay on the screen until the user fixes it.

### Submit button

When the user taps the submit button and there are errors, voice the count:

```swift
func submitTapped() {
    let errors = validate()

    if errors.isEmpty {
        submit()
    } else {
        UIAccessibility.post(
            notification: .announcement,
            argument: "\(errors.count) \(pluralizeError(errors.count)). First: \(errors[0].message)"
        )
    }
}
```

For navigation through errors, add them to the rotor via `UIAccessibilityCustomRotor`:

```swift
let errorRotor = UIAccessibilityCustomRotor(name: "Errors") { predicate in
    // Go to the next/previous field with an error
    let direction = predicate.searchDirection
    let nextField = findNextErrorField(
        after: predicate.currentItem.targetElement,
        direction: direction
    )

    guard let field = nextField else { return nil }
    return UIAccessibilityCustomRotorItemResult(
        targetElement: field,
        targetRange: nil
    )
}

view.accessibilityCustomRotors = [errorRotor]
```

## Loading

Behavior during loading depends on its duration and type.

### Short loading (less than 0.5 seconds)

Nothing needs to be done. The user won't notice the delay, and an extra notification will only confuse them.

### Long blocking loading

If the screen is blocked by a loading indicator, move focus to the indicator:

```swift
activityIndicator.accessibilityLabel = "Loading"
activityIndicator.isAccessibilityElement = true

// Showed the indicator — focus on it
UIAccessibility.post(
    notification: .screenChanged,
    argument: activityIndicator
)
```

When loading completes and the screen updates, VoiceOver will automatically switch to the new content when `.screenChanged` is used.

### Long background loading

If the loading is in the background and the user can continue working, don't intercept focus. Just announce completion:

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "Data loaded"
)
```

## Progress

For long operations with progress you need more information.

```swift
progressView.accessibilityLabel = "File download"
progressView.accessibilityValue = "45 percent, about 2 minutes"
progressView.accessibilityTraits = .updatesFrequently
```

The `.updatesFrequently` trait tells VoiceOver that the value needs to be checked more often.

Update `accessibilityValue` as it progresses, and on completion notify the user:

```swift
func updateProgress(_ fraction: Float) {
    let percent = Int(fraction * 100)
    progressView.accessibilityValue = "\(percent) percent"

    if fraction >= 1.0 {
        UIAccessibility.post(
            notification: .announcement,
            argument: "Download finished"
        )
    }
}
```

Don't update the value on every percent — VoiceOver won't have time to read it. It's enough to update every 10% or at key milestones.

## 3D Touch

3D Touch works with VoiceOver enabled. The user can press harder on the focused element to invoke Peek & Pop. But they may not know that the element supports 3D Touch.

Use `accessibilityHint` to hint:

```swift
cell.accessibilityHint = "Press harder for quick preview"
```

VoiceOver will read the hint after a short pause, and the user will know about the additional capability.

## Toast with an action

Toasts are pop-up notifications that disappear after a few seconds. The most common example is a toast with action undo: "Email deleted. Undo".

### Problems for VoiceOver

A blind user may not notice the toast, because focus doesn't move to it automatically. Even if they hear the notification, they may not have time to find the "Undo" button before the toast disappears.

### Solutions

**Increase the display time for VoiceOver:**

```swift
let duration: TimeInterval = UIAccessibility.isVoiceOverRunning ? 10.0 : 3.0
showToast(duration: duration)
```

**Place the toast at the edge of the screen** — at the top or bottom. This way a blind user can find it faster while exploring the screen by touch.

**Add Shake to Undo.** Shaking the phone to undo is a standard iOS gesture that works with VoiceOver:

```swift
override var canBecomeFirstResponder: Bool { true }

override func motionEnded(
    _ motion: UIEvent.EventSubtype,
    with event: UIEvent?
) {
    if motion == .motionShake {
        undoLastAction()
    }
}
```

**Use the `.warning` haptic** to draw attention:

```swift
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.warning)

UIAccessibility.post(
    notification: .announcement,
    argument: "Email deleted. Shake the phone to undo"
)
```

## Voice

`NSAttributedString` supports special attributes that control VoiceOver's pronunciation.

### Punctuation

Turns on reading punctuation marks aloud — periods, commas, parentheses:

```swift
let code = NSAttributedString(
    string: "func hello() { }",
    attributes: [
        .accessibilitySpeechPunctuation: true
    ]
)
label.accessibilityAttributedLabel = code
// VoiceOver: "func hello open parenthesis close parenthesis
//             open brace close brace"
```

### Language

Sets the language for a piece of text. VoiceOver will switch the voice engine:

```swift
let text = NSMutableAttributedString(string: "Добро пожаловать, welcome!")

text.addAttribute(
    .accessibilitySpeechLanguage,
    value: "ru-RU",
    range: NSRange(location: 0, length: 19) // "Добро пожаловать, "
)

text.addAttribute(
    .accessibilitySpeechLanguage,
    value: "en-US",
    range: NSRange(location: 19, length: 8) // "welcome!"
)

label.accessibilityAttributedLabel = text
```

### Voice pitch

A value from 0 to 2, where 1 is the normal pitch. Useful for emphasizing important parts:

```swift
let text = NSMutableAttributedString(string: "Error: incorrect password")

// "Error" — in a higher voice to draw attention
text.addAttribute(
    .accessibilitySpeechPitch,
    value: 1.5,
    range: NSRange(location: 0, length: 5)
)

label.accessibilityAttributedLabel = text
```

### Phonetic pronunciation

`speechIPANotation` sets the pronunciation via IPA transcription:

```swift
let name = NSAttributedString(
    string: "Xiaomi",
    attributes: [
        .accessibilitySpeechIPANotation: "ˈʃaʊmiː"
    ]
)
label.accessibilityAttributedLabel = name
// VoiceOver will pronounce "Shaomi" instead of "Ksiaomi"
```

### Spelling out

Forces VoiceOver to pronounce text one letter at a time:

```swift
let code = NSAttributedString(
    string: "ABC123",
    attributes: [
        .accessibilitySpeechSpellOut: true
    ]
)
label.accessibilityAttributedLabel = code
// VoiceOver: "A B C one two three"
```

Useful for confirmation codes, serial numbers, and abbreviations.


## Hints

`accessibilityHint` is an additional hint that VoiceOver reads after a short pause. The user can disable hints in the settings, so don't put important information there.

Rules for a good hint:

- Starts with a verb in the third person: "Turns on", "Opens", "Deletes".
- First letter capitalized.
- Ends with a period.
- Short — one sentence.
- Describes the result of the action, not the method.

```swift
// Good
cell.accessibilityHint = "Plays the song."
deleteButton.accessibilityHint = "Deletes the selected messages."

// Bad
cell.accessibilityHint = "Double tap to play"
deleteButton.accessibilityHint = "Delete button"
```

Don't duplicate `accessibilityLabel` in `accessibilityHint`. The hint answers the question "What will happen?", not "What is this?".
