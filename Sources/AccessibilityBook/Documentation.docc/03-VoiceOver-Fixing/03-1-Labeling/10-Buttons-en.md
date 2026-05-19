# Buttons

How buttons work: the `.button` trait, the `accessibilityActivate` activation function, buttons without text, tabs.


## Button names

![Remove ingredients, button](labeling-button)

*VoiceOver will read "Remove ingredients, button".*

A button with text is read by VoiceOver as **label + "button"**. The word "button" is added automatically if the element has the right trait. The element type description is at the end of the text, to hint what can be done with the element next.

The standard `UIButton` has the `.button` trait by default. If you're making a button from a `UIView` or `UILabel`, don't forget to add the trait manually.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        button.accessibilityTraits = .button
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // SwiftUI Button already has the trait. For a custom control:
        Text("Order")
            .onTapGesture { order() }
            .accessibilityAddTraits(.isButton)
        ```
    }
}

iOS translates the text "button" into the language selected on the phone on its own.

> Warning: There's no need to add the text "button" yourself, iOS will do it for you, the trait is enough.

### Button activation

Pressing a button in VoiceOver is a double tap anywhere on the screen, and the focused button is activated. A double tap calls the `accessibilityActivate()` method:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        override func accessibilityActivate() -> Bool {
            openDetails()
            return true
        }
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        customView
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { openDetails() }
        ```
    }
}

The button performs a normal press on itself and returns true if the action was handled. If it returns false, then VoiceOver will try to call the method on the next object in the UIView hierarchy.

`AccessibilityActivate()` can be called on any accessible object, as long as it has `isAccessibilityElement = true` set. This comes in handy when building complex controls.

> Note: `accessibilityActivate()` usually doesn't need to be specified — VoiceOver will trigger the same action as the button.

### Verifying the description

Always check how VoiceOver reads the button text. Abbreviations and symbols may be voiced differently than you expect:

- "См все" will be read as "S-M all" instead of "See all"
- "179 ₽" will be read as "one hundred seventy-nine ruble sign" instead of "one hundred seventy-nine rubles"

Fix the labels:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        button.setTitle("См. все", for: .normal)
        button.accessibilityLabel = "See all"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button("См. все") { showAll() }
            .accessibilityLabel("See all")
        ```
    }
}

![Example of a "buy" button from the App Store](labeling-button-check)

Buttons can be not only UIButton elements, but also, for example, cells in lists. If a cell can be tapped, we need to tell that. The easiest way is to set the .button trait on the cell. We'll also discuss lists and cells in detail in the next chapter <doc:13-Cells-en>.

### Buttons without text

![Icon buttons next to the pizza](labeling-button-without-text)

Buttons with icons are the most common accessibility problem. If a button has no text, VoiceOver will try to read the name of the image file. The result is unexpected:

- A close button with the `ic_close` icon will be read as "ic close, button"
- A cart button with the `ic_cart` icon — "ic cart, button"

This is completely unintelligible to the user. The fix is easy — set the `accessibilityLabel`:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        closeButton.accessibilityLabel = "Close"
        cartButton.accessibilityLabel = "Cart"
        infoButton.accessibilityLabel = "Nutrition facts"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Button { close() } label: {
            Image("ic_close")
        }
        .accessibilityLabel("Close")

        Button { openCart() } label: {
            Image("ic_cart")
        }
        .accessibilityLabel("Cart")
        ```
    }
}

### Tab bar

![Facebook's tab bar](labeling-tabbar)

A separate story is custom `UITabBarItem`s. If you use your own elements in the tab bar, they too may end up without labels. Without an `accessibilityLabel`, tabs will be read as icon file names or not voiced at all.

For example, in Facebook the tab bar may be read as a set of files instead of clear "Feed", "Friends", "Profile". Always set labels for tab bar items:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        let feedTab = UITabBarItem(
            title: "Feed",
            image: UIImage(named: "ic_feed"),
            tag: 0
        )
        // title will automatically become accessibilityLabel
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", image: "ic_feed")
                }
        }
        // the Label's text will automatically become accessibilityLabel
        ```
    }
}

If the `title` is visually hidden, set `accessibilityLabel` separately:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        feedTab.accessibilityLabel = "Feed"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        TabView {
            FeedView()
                .tabItem {
                    Image("ic_feed")
                }
                .accessibilityLabel("Feed")
        }
        ```
    }
}

> Tip: for the tab bar you also need to set the .tab trait

@Comment {
 Дать ссылку на главу   
}
