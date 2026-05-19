# Cells in lists

Cells can be of varying complexity, but they can always be a single control for accessibility.

## Lists and cells

Most screens in mobile apps are lists. Each list cell usually contains several views: a picture, a heading, a subheading, an icon. Without adaptation, VoiceOver will focus on each one separately, forcing the user to make extra swipes. It's easy to get lost even on one screen this way.

![Examples of lists in an app](simplify-lists)

For simple navigation, use the rule: **one cell — one accessibility element.** A sighted person perceives the cell as a single whole, and VoiceOver should do the same.

Tables (`UITableView`) have system styles that affect VoiceOver's behavior: section headers, footers. Collections (`UICollectionView`) are more primitive — they don't have built-in semantics, and everything has to be configured manually. Let's look at examples from simple to complex.

### Simple cell

![Simplest cell with a city name](simplify-cell-basic)

For a simple cell, we make the whole cell an accessible element, give it a description, and add the `.button` trait so the user understands it can be tapped.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        class LocaleCell: UITableViewCell {

            @IBOutlet private weak var nameLabel: UILabel!

            override func awakeFromNib() {
                super.awakeFromNib()

                isAccessibilityElement = true
                accessibilityTraits = .button
            }

            var title: String? {
                didSet {
                    nameLabel.text = title
                    accessibilityLabel = title
                }
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // In List, a cell with an action already becomes one element with the "button" trait
        List(locales) { locale in
            Button {
                select(locale)
            } label: {
                Text(locale.title)
            }
        }

        // Outside of List (for example, in ScrollView + VStack) we combine manually:
        // accessibilityElement(children: .combine) makes the row one element,
        // accessibilityAddTraits(.isButton) adds the "button" trait.
        ScrollView {
            VStack {
                ForEach(locales) { locale in
                    HStack {
                        Text(locale.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { select(locale) }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        ```
    }
}

When `isAccessibilityElement = true` is set on the cell, VoiceOver stops looking for accessible elements inside it — all child views become invisible. The cell itself becomes a single focus.

> Tip: for the screen reader, a cell is a "button". It sounds weird, but the semantics matter: the cell can be tapped, so it's a button

### Cell with a subtitle

![Cell with address and opening hours](simplify-cell-subtitle)

Let's make the cell more complex. Now it has a second line with opening hours. There are two semantic parts in the cell: address and opening hours, and the time is only of interest to us if it's the address we want.

We can combine the two texts into one with a comma and write it into accessibilityLabel. We can do something more interesting: write the opening hours into accessibilityValue, then VoiceOver will add a small pause and read the time with a different intonation, which gives the speech some life and makes it easier to perceive by ear.

```
label: Moscow, Miklouho-Maclay street, 36A
value: From 9 to 23
traits: button
```

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        class PizzeriasTableViewCell: UITableViewCell {
            @IBOutlet weak var titleLabel: UILabel!
            @IBOutlet weak var scheduleLabel: UILabel!
            override func awakeFromNib() {
                super.awakeFromNib()
                isAccessibilityElement = true
                accessibilityTraits = .button
            }
            var title: String? {
                didSet {
                    titleLabel.text = title
                    accessibilityLabel = title
                }
            }
            var schedule: String? {
                didSet {
                    scheduleLabel.text = schedule
                    accessibilityValue = schedule
                }
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button {
            select(pizzeria)
        } label: {
            VStack(alignment: .leading) {
                Text(pizzeria.title)
                Text(pizzeria.schedule)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pizzeria.title)
        .accessibilityValue(pizzeria.schedule)
        ```
    }
}

> Tip: Splitting into `label` and `value` creates a pause and different intonation in VoiceOver's speech: the name is read confidently, while the value — a bit quieter and after a pause. This helps the user structure information by ear.

### Selectable cell

![Cell with address, opening hours, and a selected marker](simplify-cell-trait)

Let's keep making the cell more complex.
A cell may have a checkmark — that's how we mark the current pizzeria. VoiceOver has a
standard approach for marking the selected element — the .selected trait.
An element can be marked simultaneously with a type (button) and a state (selected),
so traits must be specified through OptionSet operations.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override public var isSelected: Bool {
            didSet {
                if isSelected {
                    accessibilityTraits.insert(.selected)
                } else {
                    accessibilityTraits.subtract(.selected)
                }
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        pizzeriaRow
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        ```
    }
}

Interestingly, even in this format VoiceOver reads the time as "from nine to twenty three". It doesn't decline the words, but doesn't read unnecessary zeros either.

### Disabled cell

![The pizzeria at the address is currently closed](simplify-cell-disabled)

```
label: Moscow, Miklouho-Maclay street, 36A
value: From 9 to 23, currently closed
traits: not enabled, button    
```

If you need to show that a cell can't be selected right now, use the
standard `.notEnabled` trait — it will add "not enabled" to the description.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        accessibilityTraits.insert(.notEnabled)
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // .disabled both blocks interaction and adds the "not enabled" trait
        pizzeriaRow
            .disabled(isClosed)
        ```
    }
}

The `.notEnabled` trait should only be used for elements you can't interact with. If I can select the address, the `.notEnabled` trait doesn't need to be specified, and the closed pizzeria should be communicated through the value.

## Reading order

Over the past 3 pages we've encountered several traits:
— `.selected`,
— `.notEnabled`,
— `.button`.

Each describes one of the standard behaviors, while the labels appear in different places. On the other hand, we have `accessibilityLabel`, `accessibilityValue`, and `accessibilityHint`. Time to sort out the reading order.

![Order in which the screen reader reads properties](simplify-traits)

If you're scrolling through a large list of elements, the most important thing for you is to know which element is *selected*. Then, what kind of element this is, its *label* and *value*. Once you've understood what element is in focus, you can decide what to do with it, so the element's *availability*, its *type*, and the *hint* on how to interact with it are at the very end of the description. Before `value` and `hint` there are small pauses.

VoiceOver reads information about the element in strict order:

1. **Label** — the element's name. Read first, in a confident voice.
2. **Value** — the value. Read after a pause, with slightly different intonation.
3. **Traits** — properties. Voiced in a specific order:
   - `.selected` — "selected"
   - `.notEnabled` — "not enabled"
   - `.button` — "button"
4. **Hint** — the hint. Read last, after a long pause. If the user swipes before the hint finishes — it won't be played.

Example:

``` 
  Pepperoni, 625 rubles,  selected,   button, double tap to remove
 ─────────────────────── ────────── ──────── ──────────────────────
   label        value     selected   button              hint
```

Understanding the reading order helps to distribute the information correctly: the most important — in `label`, what varies — in `value`, behavior — in `traits`.

## Complex cell

![Example of a catalog cell with picture, name, description, and price](simplify-cell-compound)

Let's move on to complex cells, when there are several controls inside. Without adaptation, focus will read each label separately, and you'll need to swipe at least three times to move to the next product.

Not all cells consist of a single label. Imagine a product cell: **name**, **ingredients**, and **price**. A sighted person sees this as a single block, and VoiceOver should work the same way. For comfortable use, the cell should be one element, then the text will be read one after another. At the same time, it can be interrupted by performing one of the actions: tap on the cell, move to the next one, or simply stop reading.

### Composing the cell model

A blind user doesn't need the picture, and knowing it's there is also useless. That leaves 3 labels. How does a sighted person read them? The pizza name is first and bold. Most likely, they'll read the price next, since it has a color accent, and the ingredients last because it's long and faded. So the perception order is:
— name,
— price,
— ingredients.

Name and price can be combined with a comma and put in label. Ingredients can be separated by intonation and saved in value.

```
label: Crazy pepperoni, from 395 rubles
value: Spicy pepperoni, chicken, mozzarella, tomato sauce, sweet and sour sauce.
trait: button
```

> Hint: in graphic design, the perception order isn't always correct,
the tidiness of the layout is sometimes more important than the meaning.

The accessibility code is fairly simple: we make the cell accessible, give it a description and button behavior, and then just assemble two lines of description.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func awakeFromNib() {
            super.awakeFromNib()
            isAccessibilityElement = true
            accessibilityTraits = .button
        }

        func updateAccessibility(title: String,
                                 price: String,
                                 ingredients: String?) {
            accessibilityLabel = [title, price].joined(separator: ", ")
            accessibilityValue = ingredients
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button {
            select(pizza)
        } label: {
            VStack(alignment: .leading) {
                Text(pizza.title)
                Text(pizza.price)
                Text(pizza.ingredients ?? "")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pizza.title), \(pizza.price)")
        .accessibilityValue(pizza.ingredients ?? "")
        ```
    }
}
    
If the product isn't available, the button with the price is replaced with a "coming soon" label. For VoiceOver the graphical swap of controls doesn't matter, so we just change the price text:
```
label: Crazy pepperoni, coming soon
value: Spicy pepperoni, chicken, mozzarella, tomato sauce, sweet and sour sauce.
trait: button
```

Taking this into account, the code becomes only slightly more complex:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        func updateAccessibility(
            title: String,
            price: String,
            ingredients: String?,
            isProductAvailable: Bool
        ) {
            let price = isProductAvailable ? price : "Coming soon"
            accessibilityLabel = [title, price].joined(separator: ", ")
            accessibilityValue = ingredients
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        let displayPrice = pizza.isAvailable ? pizza.price : "Coming soon"

        pizzaRow
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(pizza.title), \(displayPrice)")
            .accessibilityValue(pizza.ingredients ?? "")
        ```
    }
}

You can add the disabled trait on the element, but only if the cell can't be tapped.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        func updateAccessibility(
            title: String,
            price: String,
            ingredients: String,
            isProductAvailable: Bool
        ) {
            isAccessibilityElement = true

            let price = isProductAvailable ? price : "Coming soon"
            accessibilityLabel = [title, price].joined(separator: ", ") 
            accessibilityValue = ingredients

            if isProductAvailable {
                accessibilityTraits = .button
            } else {
                accessibilityTraits = [.button, .notEnabled]
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        let displayPrice = pizza.isAvailable ? pizza.price : "Coming soon"

        pizzaRow
            .disabled(!pizza.isAvailable)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(pizza.title), \(displayPrice)")
            .accessibilityValue(pizza.ingredients)
        ```
    }
}

We'll look at an even more complex example in the chapter <doc:12-CustomDescription>
