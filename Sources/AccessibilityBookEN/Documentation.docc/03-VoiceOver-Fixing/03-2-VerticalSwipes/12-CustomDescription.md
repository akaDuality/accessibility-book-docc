# Additional descriptions

In complex cells, textual description can be moved onto vertical swipes

![Example of an order cell with time, address, products, and a repeat button](verticalSwipes-customContent)

Not all cells can be simplified to a single accessibility element; sometimes there are too many controls inside the cell. For example, in the order history we show the number, date, order type, address, a list of 5–6 products, the total, and a couple more actions: repeat order and open the detailed description of the order.

In such a case there are two options:
1. Slightly consolidate the elements, combining them in pairs: number and date, type and address, the text "total" and the number. You'll have to go through them one by one, but it's tolerable.

2. Use AXCustomContent — then when focus lands on the cell, VoiceOver will read only one of the values, and the rest can be listened to by swiping vertically. Such descriptions can be seen on photos in the standard "Photos" app: iOS displays the date, time, photo orientation, who or what is depicted, and so on.

For such cases there's `AXCustomContent`. The main information is read immediately on focus, and the details are accessible through vertical swipes.

```swift
    AXCustomContent(label: "Total",
                    value: "1239 rubles")
```

It may be inconvenient the first time, but it greatly speeds up navigation on subsequent occasions.
```
1239 rubles, Total
```

For the description to work, you need to implement the `AXCustomContentProvider` protocol and create the `accessibilityCustomContent` property. Interestingly, the protocol is in the `Accessibility` framework, although until now all the accessibility code was in `UIKit`. Don't forget to import the framework.

```swift
import Accessibility
@available(iOS 14.0, *)
extension OrderHistoryItemCell: AXCustomContentProvider {
    var accessibilityCustomContent: [AXCustomContent] {
        get {
            [AXCustomContent(label: "Total",
                             value: "1239 rubles"),
             AXCustomContent(label: "213",
                             value: "Order number"),
             AXCustomContent(label: "Date",
                             value: "April 24, 2021, at 17:25"),
             AXCustomContent(label: "For delivery",
                             value: "Moscow, Dodo head office, Leninskaya Sloboda, 19с7"),
             productsContent(products: ["Dodo Mix pizza", "Apple pie"])]
        }
        set {}
    }
...
```

CustomContent relies not on the order of elements, but on their importance. The products
seem the most important, they need to be read first, so I gave them high
priority. The product names I glued into a single line with commas, that's enough.

```swift
...
    private func productsContent(_ products: [String]) -> AXCustomContent {
        let content = AXCustomContent(
           label: "Items",
           value: products.joined(separator: ", "))
        
        content.importance = .high

        return content
    }
}    
```

### Summary buttons

![The "Add to cart" button can summarize the screen settings](verticalSwipes-summary)

This kind of description is also good for summary buttons. For example, you've customized a pizza: chose a size, removed onions, added more meat. Before adding it to the cart you want to double-check everything, but not walk through the whole screen again. A description on the add button will greatly simplify the work.

```
label To cart for 754 rubles,
value Pesto pizza, medium, thin crust,
traits Button.
customContent:
- Onions, removed,
- Spicy chicken, Added.
```

### Grouping descriptions
![Example of multiple descriptions for nutritional value](verticalSwipes-Energy)

Another use case is when there's a lot of data. The screenshot shows nutritional value for a combo set of several products. Horizontal swipes will switch the product, and vertical swipes will read one of the descriptions. With the .importance property you can control the order of products, for example, read the weight first.

CustomContent can work together with customActions and even in .adjustable
elements. Which mode the vertical swipes will work in can be chosen via the rotor.

@Comment {
дать ссылку на раздел ротора    
}

## Different actions on a single screen

![Cart screen](verticalSwipes-cart)

On one screen, different approaches can be combined. Take the cart screen: for the item quantity we use `customAction` (add, subtract, delete), and for the amount of sauce — the `.adjustable` trait (just more or less).

This approach significantly reduces the number of elements. The cart screen, which had **31 elements** for VoiceOver, after adaptation turns into **6 elements**. Navigation becomes fast and clear.

Choose the tool by the task:

- **`.adjustable`** — when you need to change one value in steps (quantity, volume, size).
- **`customAction`** — when an element has several different actions (add, delete, share).
- **`AXCustomContent`** — when an element has a lot of information and it needs to be read in parts.

```
    Dodo Mix: Medium 30 centimeters,
    traditional dough, 1 pizza, 695 rubles.
    
    Actions available: add, subtract, delete.
    
    Cheese sauce, 0, adjustable
    
    Barbecue, 1 piece, adjustable
```
