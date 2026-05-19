# Images

Images are usually hidden from the screen reader, because they're not valuable to a blind user. But if an image is large, you can make it accessible to describe the structure of the page.

## Images are usually hidden

![Example of a catalog cell with picture, name, description, and price](simplify-cell-compound)

Most often there's no point labeling images for the screen reader: they're either purely decorative, or their description is in the text next to them. For example, in a product cell the name of the pizza will completely duplicate the name of the image of that pizza.

![](cells-chevrons)

The same goes for various decorative parts of the app. For example, chevrons in cells don't need a label: they only visually hint that the cell can be tapped and the next screen will open. VoiceOver does the same when it reads the "button" trait.

- Face ID & Passcode, *Button*
- Emergency SOS, *Button*
- Privacy & Security, *Button*

> How to describe cells we'll discuss in the next chapter <doc:13-Cells-en>

## Large images

On product cards, images are usually large and take up half the screen. If you just hide the picture from the screen reader, it'll feel as if the screen is broken and something got lost, since a large area doesn't respond to touches at all.

![Pizza description screen](labeling-images)

By default, pictures are hidden from VoiceOver: `UIImageView`'s `isAccessibilityElement` property is `false`. This is the right choice for most cases — decorative images carry no meaning and only slow down navigation.

If the image is important for understanding, make it accessible and add the `.image` trait. For example, on the pizza description screen you can combine the picture and the heading because they mean the same thing.

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = [.image, .header]
        imageView.accessibilityLabel = "Pepperoni pizza"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // Image has the .image trait by default
        Image("pepperoni")
            .accessibilityLabel("Pepperoni pizza")
            .accessibilityAddTraits(.isHeader)
        ```
    }
}

iOS can recognize image contents and may voice the description automatically, but it's better not to rely on that — set the labels yourself.

Hide decorative images explicitly:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        decorativeImage.isAccessibilityElement = false
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        Image("decoration")
            .accessibilityHidden(true)

        // Or use Image(decorative:) — it's accessibility-free from the start
        Image(decorative: "decoration")
        ```
    }
}

Badges and marks on pictures are a special case. If a pizza card has a "NEW" badge, don't make it a separate accessible element. Instead, add the information to the label of the main element:

@TabNavigator {
    @Tab("UIKit") {
        ```swift
        // Bad: badge as a separate element
        badgeLabel.isAccessibilityElement = true
        badgeLabel.accessibilityLabel = "NEW"

        // Good: information in the card's label
        cell.accessibilityLabel = "New, Pepperoni, 625 rubles"
        ```
    }
    @Tab("SwiftUI") {
        ```swift
        // Bad: badge is read separately
        PizzaCard(pizza: pepperoni)
            // Text("NEW") inside is voiced by VoiceOver

        // Good: badge is hidden, information is in the card's label
        PizzaCard(pizza: pepperoni)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("New, Pepperoni, 625 rubles")
        ```
    }
}

This way the user immediately hears all the information about the pizza, instead of switching between elements.
