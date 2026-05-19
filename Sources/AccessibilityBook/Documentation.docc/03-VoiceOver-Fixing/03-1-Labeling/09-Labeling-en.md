# Labels

How to label interface elements correctly so that VoiceOver reads them clearly and accurately.

## Labels

![VoiceOver gesture reference.](labeling-text)

Regular labels are already adapted for VoiceOver: their size sets the focus frame, and the text in the label is the text of the label itself.

> Tip: A text label is the basic accessibility element.

Most often the text for a blind user is no different from what's already in the interface, but you can set different text.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        label.accessibilityLabel = "Pepperoni pizza"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Text("Pepperoni")
            .accessibilityLabel("Pepperoni pizza")
        ```
    }
}

> Tip: for headings, add the `.header` trait — users switch between headings via the rotor, the way sighted people scan the screen with their eyes.

Apply the trait to section headings in lists, the screen heading, and large text blocks:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        titleLabel.accessibilityTraits = .header
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Text("Menu")
            .accessibilityAddTraits(.isHeader)
        ```
    }
}

## Expand abbreviations

VoiceOver reads text from `accessibilityLabel` exactly as it's written. That means abbreviations and symbols will be read *literally*.

![Pizza with name](labeling-text-advanced)

For example, the label "30 cm" will be read as "thirty cm", not "thirty centimeters". The price "30 ₽" turns into "thirty ruble sign" instead of "thirty rubles". VoiceOver doesn't know how to expand abbreviations and substitute the correct currency names — it reads what it sees.

To fix this, set the `accessibilityLabel` with the full text:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        priceLabel.text = "30 ₽"
        priceLabel.accessibilityLabel = "30 rubles"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Text("30 ₽")
            .accessibilityLabel("30 rubles")
        ```
    }
}

If you need to combine several lines into one label, use a comma — VoiceOver will make a short pause and place the intonation correctly:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        cell.accessibilityLabel = "Pepperoni, 25 centimeters, thin crust, 625 rubles"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        PizzaCell(pizza: pepperoni)
            .accessibilityLabel("Pepperoni, 25 centimeters, thin crust, 625 rubles")
        ```
    }
}

For convenience, you can introduce a structure that stores the visible and accessible text side by side:

```swift
struct AccessibleText {
    let visibleText: String
    let accessibleText: String
}

let size = AccessibleText(
    visibleText: "30 cm",
    accessibleText: "30 centimeters"
)

let price = AccessibleText(
    visibleText: "30 ₽",
    accessibleText: "30 rubles"
)
```

This way the backend or design system can always provide the correct text for VoiceOver along with what's displayed. Something like this also comes in handy for backend-driven UI.

### Numbers: phones, cards, codes

VoiceOver reads long numbers as a whole — this often sounds unintelligible for phone numbers, card numbers, and confirmation codes. Break such numbers apart with spaces so VoiceOver pauses and reads them in groups of digits.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        // Without processing, a long number is read as one block
        phoneLabel.text = "+79991234567"

        // With spaces, VoiceOver reads it in groups
        phoneLabel.accessibilityLabel = "+7 999 123 45 67"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Text("+79991234567")
            .accessibilityLabel("+7 999 123 45 67")
        ```
    }
}

For card numbers it's convenient to break them up by 4 digits, for OTP — one at a time:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        cardLabel.accessibilityLabel = "4242 4242 4242 4242"
        otpLabel.accessibilityLabel = "1 2 3 4"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Text("4242424242424242")
            .accessibilityLabel("4242 4242 4242 4242")

        Text("1234")
            .accessibilityLabel("1 2 3 4")
        ```
    }
}

### Plural forms

In Russian, the number affects the word form: 1 ruble, 2 rubles, 5 rubles. If you're substituting a number into a string, you need to handle declension.

Use `Localizable.stringsdict` for correct declension:

![Example localization file](localizable)

```swift
String(format: NSLocalizedString("%d rubles", comment: ""), price)
```

Now "1" will become "1 ruble", "2" — "2 rubles", and "5" — "5 rubles".

In addition, `NSStringVariableWidthRuleType` helps choose different texts based on available width. This is useful when the interface needs a short form, but VoiceOver needs the full one:

![Description example for different widths](width-rule)

### Punctuation and pauses

Punctuation marks in `accessibilityLabel` affect VoiceOver's intonation and pace:

- **Comma** — a short pause, the next part is read with a slightly different tone
- **Colon, period** — a long pause
- **Dash** — a short pause, not pronounced itself
- **Parentheses and quotation marks** — usually read literally: "opening parenthesis", "quote"

Compare how the same information sounds with different punctuation:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        // Periods break it into separate sentences, reading slows down
        cell.accessibilityLabel = "Pepperoni. 25 cm. Thin crust. 625 rubles."

        // Commas give smooth intonation with short pauses
        cell.accessibilityLabel = "Pepperoni, 25 cm, thin crust, 625 rubles"

        // Parentheses are read literally: "Pepperoni, opening parenthesis, spicy, closing parenthesis"
        cell.accessibilityLabel = "Pepperoni (spicy)"

        // Better to use a comma
        cell.accessibilityLabel = "Pepperoni, spicy"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // Periods break it into separate sentences, reading slows down
        cellView.accessibilityLabel("Pepperoni. 25 cm. Thin crust. 625 rubles.")

        // Commas give smooth intonation with short pauses
        cellView.accessibilityLabel("Pepperoni, 25 cm, thin crust, 625 rubles")

        // Parentheses are read literally
        cellView.accessibilityLabel("Pepperoni (spicy)")

        // Better to use a comma
        cellView.accessibilityLabel("Pepperoni, spicy")
        ```
    }
}

Use commas for structure and don't overuse periods — they break the description into separate sentences and slow reading down.

### When labels break

If you draw text through `CATextLayer`, accessibility information is lost. You can restore it yourself by specifying the parameters. Let's go through such a case and see what UILabel does for us.

To start with, let's mark that the element is accessible, which means it can receive focus.

```swift
isAccessibilityElement = true
```

> Note: If the value is false, VoiceOver will try to find an accessible element among the children.

Then we need to label the element; for the description we'll take the text from the element. VoiceOver will read this text when focus lands on the control.

```swift 
accessibilityLabel = text
```

Finally, we need to set the element's frame: this way the focus will be visible on the screen and you'll be able to land on it by touch. Focus is needed not only for blind users and VoiceOver, but also for Switch Control.

```swift
accessibilityFrame = frameInScreenCoordinates
```

Done, accessibility in its simplest form is up and running.

@Comment {
    Добавить ссылку на заголовки
}

## Pronunciation and language

VoiceOver picks the voice by the system language. If an English word appears in a Russian label, it'll be read with a Russian pronunciation: "iPhone" as "iphone", "AirPods" as "airpods", "Wi-Fi" as "wi-fi". For brand names, this is the most common source of awkward reading.

If the entire label is in another language, specify it via `accessibilityLanguage`:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        button.accessibilityLabel = "Settings"
        button.accessibilityLanguage = "en-US"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        var label = AttributedString("Settings")
        label.accessibilitySpeechLanguage = "en-US"

        Button("Settings") { }
            .accessibilityLabel(label)
        ```
    }
}

If the language changes inside a string, use `accessibilityAttributedLabel` with the `.accessibilitySpeechLanguage` attribute:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        let label = NSMutableAttributedString(string: "Подключите iPhone")
        label.addAttribute(
            .accessibilitySpeechLanguage,
            value: "en-US",
            range: NSRange(location: 11, length: 6)
        )
        button.accessibilityAttributedLabel = label
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        var label = AttributedString("Подключите ")
        var brand = AttributedString("iPhone")
        brand.accessibilitySpeechLanguage = "en-US"
        label.append(brand)

        Button("Подключите iPhone") { }
            .accessibilityLabel(label)
        ```
    }
}

Now VoiceOver will switch the voice to English on the word "iPhone" and read it correctly.

> Tip: Check how brand names and foreign words sound — by ear it's easy to miss a mistake.

## How to verify a label

After changing a label, you need to make sure VoiceOver reads it exactly the way you wanted.

### RocketSim

It would be most convenient to check directly in the simulator and see VoiceOver's work on every run. For this you can use [RocketSim](https://www.rocketsim.app) — it shows all accessible elements, their labels, traits, and order, alongside the simulator.

The app also makes it easier to work [with other accessibility settings](https://www.rocketsim.app/features/accessibility/)

![](rocketsim-voiceover)

@Comment {
    - Вынести в отдельную главу про рокетсим
    - Добавить про SwiftUI Preview когда либа будет доступна
}

### Captions panel

If you're checking on the phone, it's convenient to turn on **captions** (see <doc:02-EnablingVoiceOver-en>).

Captions show the text VoiceOver is speaking right now. You don't need to listen — bring focus to the element and read the line at the bottom of the screen. This is especially handy for debugging: change the label, relaunch the app, check the line — and immediately see the result.

> Tip: Turn on captions when you're working with long labels, numbers, or foreign words — it's easy to miss a mistake by ear.

## What to call elements?

A good label has several properties:

1. **Short description.** One word or a short phrase: "Add", "Cart", "Settings". Blind users listen to VoiceOver at high speed — long descriptions slow work down.

2. **Without indicating the type.** Don't write "Close button" or "Pepperoni image" — the element type is added automatically through traits. If you write "Close button", VoiceOver will read "Close button, button".

3. **Starts with a capital letter.** VoiceOver may use case for intonation.

4. **No period at the end.** A period creates an unnecessary pause. If you need to list several properties, use a comma.

5. **In the user's language.** If the interface is in Russian — labels in Russian. "NEW" in `accessibilityLabel` will sound like "nyu", better to write "Новинка".

6. **Compound labels separated by commas.** VoiceOver makes a short pause at a comma — use this for structuring:

```swift
cell.accessibilityLabel = "Pepperoni, 25 cm, thin crust"
```

7. **Don't leave the label empty.** If `accessibilityLabel = nil` or an empty string, VoiceOver will only read the trait ("button", "image") without the name. The user won't understand what kind of element this is. Especially dangerous for icons without text.

8. **Close to the visible text.** The label should be similar to what's written on the screen. "Sm. все" → "See all" — fine. "More" → "Go to the product specifications screen" — bad: a sighted helper reading the label out loud won't understand what's shown on the screen.

> Tip: A good check: imagine you're describing an element to a friend over the phone. How would you name it in one or two words?
