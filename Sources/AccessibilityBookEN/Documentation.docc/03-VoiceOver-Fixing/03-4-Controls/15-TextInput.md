# Text input

How VoiceOver works with input fields, the on-screen keyboard, and the Braille keyboard.

@Metadata {
    @PageImage(purpose: card, source: "cover")
}

## Input fields

When VoiceOver focuses on a text field, it reads several things in order:

1. **Label** — the field's name: "Name", "Email", "Password".
2. **Value** — the current text in the field. If empty — nothing is read.
3. **Type** — "text field" or "secure text field".
4. **Hint** — a hint: "Enter your email".

```swift
let emailField = UITextField()
emailField.accessibilityLabel = "Email"
emailField.accessibilityHint = "Enter the address for registration"
emailField.placeholder = "example@mail.com"
```

For an input field, `placeholder` is automatically used as `accessibilityLabel` if you didn't set it explicitly. But it's not worth relying on this — the placeholder often contains an example value, not the field's name. It's better to set `accessibilityLabel` separately.

### Entering text

A double tap on a text field opens the keyboard and starts editing. VoiceOver will say "is editing" and move focus to the keyboard.

### Dictation

VoiceOver supports the Magic Tap gesture — **a double tap with two fingers**. In the context of a text field this gesture starts dictation: the user says the text, and the system enters it. This is the fastest input method for blind users.

### Don't substitute the value

If the field formats the text on input (for example, a phone number or a bank card), don't put the formatted text back into the field through code. VoiceOver will read every change, and the user will hear extra text on every key press.

```swift
// Bad: VoiceOver will read the change on every character
func textField(_ textField: UITextField,
               shouldChangeCharactersIn range: NSRange,
               replacementString string: String) -> Bool {
    let formatted = format(phone: newText)
    textField.text = formatted // VoiceOver will read out the whole text
    return false
}

// Better: format the display separately from the value
// or use accessibilityValue for what's voiced
```

If formatting is necessary, control `accessibilityValue` manually so that VoiceOver reads only the meaningful result.

## On-screen keyboard

VoiceOver has three text typing modes on the on-screen keyboard. They are switched through the rotor (a two-finger rotation gesture).

### Standard typing

The default mode. The user swipes over the keyboard, VoiceOver reads the letter under the finger. When the desired letter is found, a double tap anywhere on the screen enters it. Reliable, but slow.

### Touch typing

The user touches the keyboard and listens to which letter is under the finger. When the desired letter is found, it's enough to **lift the finger** — the letter will be entered immediately. Faster than the standard mode, because no second tap is needed.

### Direct touch typing

The keyboard works as if VoiceOver were turned off: tapped on a letter — it's entered. This mode is used by those who remember the layout of the keys well. The fastest, but requires skill.

### The .keyboardKey trait

If you're creating custom buttons next to the keyboard (for example, an autocompletion bar or a custom view over the keyboard), add the `.keyboardKey` trait:

```swift
suggestionButton.accessibilityTraits = .keyboardKey
```

This trait tells VoiceOver that the element behaves like a key: in touch typing mode it will activate on lifting the finger, not on a double tap.

## Braille keyboard

VoiceOver includes a special mode — **the on-screen Braille keyboard**. Activated through the rotor.

### How it's set up

The phone needs to be held screen away from you — as if you were showing the screen to someone else. 6 dots appear on the screen — 3 on each edge, like in a Braille cell. Each dot corresponds to a finger.

The user presses the desired dots simultaneously, and the system enters a letter. It's a fast and accurate input method for people familiar with the Braille alphabet.

### Gestures

The Braille keyboard has a set of gestures for control:

| Gesture | Action |
|------|----------|
| One-finger swipe right | Space |
| One-finger swipe left | Delete a character |
| Two-finger swipe right | Enter |
| Two-finger swipe left | Delete a word |
| Two-finger swipe up | Switch language |
| Three-finger swipe down | Close the Braille keyboard |

### Specifics

The Braille keyboard is especially handy in a noisy environment, when voice input is impossible. It works silently and doesn't require any external hardware.

> Tip: If your app uses a custom keyboard (Custom Keyboard Extension), make sure all keys are accessible for VoiceOver and have correct labels. The standard iOS keyboard is already fully adapted.
