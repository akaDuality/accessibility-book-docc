# Grouped controls

How to reduce the number of elements on the screen and simplify navigation

## Reducing the number of elements

By labeling all the elements and specifying their type, we fixed the simplest but most widespread layer of problems. For most apps this will be enough.

Now we need to tackle the next problem: there are very many elements on the screen, the connections between them aren't always clear, and you constantly have to switch between them.

The number of elements can be reduced, connections can be added, and usability can be improved.

## Label + value

![Example of an order subtotal before payment](simplify-label-value)

A common pattern in interfaces is a pair of two labels: a name and a value. For example, "Order total — 799 ₽", or "Payment method — Card".

Without adaptation, VoiceOver will read them as two separate elements. If there are many such elements, the user will have to guess which value belongs to which name. We need to combine them into one element.

We use `accessibilityLabel` for the name and `accessibilityValue` for the value. VoiceOver will read them with different intonation, which is natural for a "question — answer" pair.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        // Parent container (for example, UIView or UIStackView)
        isAccessibilityElement = true
        accessibilityLabel = "Order total"
        accessibilityValue = "799 ₽"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        HStack {
            Text("Order total")
            Spacer()
            Text("799 ₽")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Order total")
        .accessibilityValue("799 ₽")
        ```
    }
}

In real code it'll more likely look like this:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        isAccessibilityElement = true
        accessibilityLabel = titleLabel.text
        accessibilityValue = valueLabel.text
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        ```
    }
}

A good example is the ratings panel in the App Store. The average rating, the number of ratings, and the histogram are combined into a single element: "Ratings and reviews", value "4.8 out of 5". You don't have to swipe through each star separately.

![Example of an app description: rating, age, ranking](simplify-badges)

The example from the App Store shows that sometimes you need to change the text slightly just for VoiceOver:

```
Rating, 4.8 based on 61 thousand ratings
Age, 12 plus
Ranking, number 9 in "Food and drink", button
```

## accessibilityElement(children:) modes

In SwiftUI the way of grouping child elements is set with a single modifier — `accessibilityElement(children:)`. It has three modes, and each solves its own task.

### .ignore — set the label manually

The container becomes a single accessibility element, child views are excluded. The label and value are set explicitly — VoiceOver won't take anything from the children.

```swift
HStack {
    Text("Order total")
    Spacer()
    Text("799 ₽")
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Order total")
.accessibilityValue("799 ₽")
```

Use this when you need to fully control what VoiceOver will read: rewrite abbreviations, change the order, add context. The equivalent of `isAccessibilityElement = true` in UIKit.

### .combine — collect child labels

SwiftUI will itself collect the labels of all child elements into a single string and apply it to the container. Traits and actions are also inherited.

```swift
HStack {
    Text("Pepperoni")
    Text("625 ₽")
}
.accessibilityElement(children: .combine)
// VoiceOver will read: "Pepperoni, 625 ₽"
```

Use this when the visible text is already suitable for VoiceOver and there's no need to rewrite it. Handy for simple cells made of several short labels.

### .contain — logical group

Child elements remain separate — focus still lands on each of them. The container becomes a "container" in the VoiceOver sense: it helps with navigation (rotor by containers, four-finger swipe).

```swift
VStack {
    ForEach(pizzas) { pizza in
        PizzaCard(pizza: pizza)
    }
}
.accessibilityElement(children: .contain)
.accessibilityLabel("Recommendations")
```

Use this for large semantic sections: screen sections, carousels, product groups. There's no need to combine child elements into one in this case.

> Tip: If the mode isn't specified, SwiftUI picks the behavior itself: usually child elements remain accessible, as if the modifier weren't there. For grouping, always specify the mode explicitly.

## UISwitch in a cell

![Example of a switch for subscribing to a marketing mailing list](simplify-switcher)

A switch is a button with state — VoiceOver calls it a "toggle button" and announces the current state: on or off. You can toggle it with a double tap, and VoiceOver will read the new state. In general, it's fully adapted by default.

There's often a label next to the switch. Semantically the label and switch are one control, so VoiceOver should also work with it as a single whole: read the label as the name, and right there give the ability to tap.

It should look like this:
```
label Notify about bonuses, promotions, and new products
value On
trait toggle button, on
```

Interestingly, the "toggle button" trait isn't documented but is available under number 53:

```swift
let switchButtonTrait = UIAccessibilityTraits(rawValue: 53)    
```

How to handle it:
- make the entire cell an accessible element,
- carry the text of the label into the cell's label,
- carry the trait over from the switch,
- take the value dynamically from the switch.

We make the cell an accessible element and copy data from the switch:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        class SwitchCell: UITableViewCell {

            private var titleLabel: UILabel!
            private var subtitleLabel: UILabel!
            private var switcher: UISwitch!

            // Make the whole cell accessible, set the trait to the switch's.
            override func awakeFromNib() {
                super.awakeFromNib()

                isAccessibilityElement = true
                accessibilityTraits = switcher.accessibilityTraits
            }

            // Provide the right label of two strings.
            func configure(title: String, subtitle: String) {
                titleLabel?.text = title
                subtitleLabel?.text = subtitle

                accessibilityLabel = [title, subtitle]
                    .joined(separator: ", ")
            }

            // The value should be read directly from the switch. It's already localized, but you can write your own text.
            override var accessibilityValue: String? {
                get {
                    switcher.accessibilityValue
                }
                set {}
            }

            // Tapping on the cell should activate the switch
            override func accessibilityActivate() -> Bool {
                switcher.accessibilityActivate()
                return true
            }
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // SwiftUI Toggle itself combines the label, value, and trait.
        // The label text becomes accessibilityLabel, the state — accessibilityValue,
        // and a tap anywhere on the row toggles the switch.
        Toggle(isOn: $isSubscribed) {
            VStack(alignment: .leading) {
                Text("Notify about bonuses")
                Text("promotions, and new products")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        ```
    }
}

## Activation Point

![Example of moving the activation point](simplify-activation-point)

By default, `accessibilityActivationPoint` points to the center of the element. On a double tap, VoiceOver simulates a press at exactly this point. Usually this works, but sometimes you need to redirect the press. In the example above, you can move the activation point from the center of the cell to the switch (or make the entire cell tappable).

For example, if a cell contains a selection button that isn't in the center, you can move the activation point:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func layoutSubviews() {
            super.layoutSubviews()
            
            accessibilityActivationPoint = selectButton.accessibilityActivationPoint
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        cellView
            .accessibilityActivationPoint(.trailing)
        ```
    }
}

If you want to calculate the coordinates yourself, it's important that the activation point is calculated **in screen coordinates**. For that there's a special function `UIAccessibility.convertToScreenCoordinates`:

```swift
override func layoutSubviews() {
    super.layoutSubviews()

    let buttonCenter = CGPoint(
        x: selectButton.frame.midX,
        y: selectButton.frame.midY
    )

    accessibilityActivationPoint = UIAccessibility.convertToScreenCoordinates(
           buttonCenter,
           in: self
    )
}
```

> Tip: If the behavior on tap is more complex than just tapping a button, it's better to use `accessibilityActivate()` — that's more reliable than moving the point.

### Tap zone

![](VoiceOver-areas)

*Labeled screen → Grouped elements → Enlarged zones*

By combining elements, we increase their tap zone, but we can go further and think about which zones on the screen will be active for explore-by-touch.

For example, we can enlarge the zones around headings and stretch them to the full available width. The empty center can be described as "Cappuccino, image": not much use, but at least it's clear that accessibility isn't broken.

In the end, the entire screen can describe what's on it.

To enlarge the zone, you can set `accessibilityFrame`.

The size recalculation should be written in `layoutSubviews()` so that it updates when the size and position of the view change. For example, we want to combine the zone of the add button and the price label:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func layoutSubviews() {
            super.layoutSubviews()

            let combinedFrame = addToCartButton.frame.union(priceLabel.frame)

            accessibilityFrame = UIAccessibility.convertToScreenCoordinates(
                combinedFrame,
                in: self
            )
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // In SwiftUI we combine elements via accessibilityElement(children: .combine).
        // The tap zone stretches across the entire container automatically.
        HStack {
            Text(price)
            Spacer()
            Button("Add") { addToCart() }
        }
        .accessibilityElement(children: .combine)
        ```
    }
}

> Tip: `accessibilityFrame` works in **screen coordinates**, not in the parent view's coordinates. The `UIAccessibility.convertToScreenCoordinates(_:in:)` method performs the necessary conversion.
