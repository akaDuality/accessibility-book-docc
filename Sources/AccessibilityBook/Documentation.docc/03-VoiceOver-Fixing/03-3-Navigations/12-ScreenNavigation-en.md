# Navigation within a screen

Managing element order, grouping, the rotor, notifications, and other VoiceOver navigation tools.

## Overview

We've dealt with the basic elements and their behavior; now we need to move between them. Usually horizontal swipes are enough for this, but there are several more convenient gestures to simplify navigation.

Typical navigation problems: elements have their order swapped, focus gets stuck in a horizontal carousel, a popup can't be closed.

Navigation can be not only fixed but also improved: properly mark up headings, name important areas of the interface. VoiceOver has a very unusual "rotor", with its help you can manage the way of navigating the interface.

## Grouping

VoiceOver reads elements left to right, top to bottom — like text. At the same time, it ignores the view hierarchy: it doesn't matter which container the element is in, the reading order is determined by the position on the screen.

But sometimes elements are positioned in a single row, and visually they form groups that VoiceOver should read together. On the ratings panel in the App Store: the stars, the rating count, and the age rating are in one line. Without grouping, VoiceOver will read them in a single line, mixing data from different blocks.

![](Navigation-wrongOrder)

To have VoiceOver traverse elements inside a group sequentially, rather than alternating them with neighbors, use the property:

```swift
reviewView.shouldGroupAccessibilityChildren = true
ageView.shouldGroupAccessibilityChildren = true
ratingView.shouldGroupAccessibilityChildren = true
```

![](Navigation-fixedOrder)

When grouping is enabled on a container, VoiceOver first reads all the child elements of this container and only then moves to the next group. This doesn't change the order within the group — there it's still determined by the position on the screen — but it guarantees that the elements of one group don't get mixed with elements of another.

## Element order

Screen|Element order 
--- | ---
![](ScrollOrder) | ![](ScrollOrderHierarchy)

A common problem: there's a `UIScrollView` with content on the screen and fixed buttons on top of it — for example, a close button and a cart. VoiceOver starts the traversal from the first subview of the screen, and if it's a `UIScrollView`, it will read all the scroll content before it gets to the fixed buttons. The order breaks.

The solution is to explicitly set the container's `accessibilityElements` array:

```swift
override var accessibilityElements: [Any]? {
    get {
        return [closeButton, cartButton, scrollView, settingsView]
    }
    set { }
}
```

Now VoiceOver will first read the close button, then the cart, then the scroll contents, and finally — the settings panel. The order is fully under your control.

Notice that I'm passing the entire scrollView, even though it's just a container for nested controls and isn't an accessible element itself. It's important to pass it, because it knows the number of elements inside it:
- it reacts correctly to a three-finger scroll (describing the number of pages and
the focus position after the scroll);
- it scrolls the list when switching focus between controls.

We shouldn't be worried that inside the containers there are other views, and they have their own elements — VoiceOver will figure this out by itself. In a sense, through `accessibilityElements` we're describing not the final elements but only the branches for the `accessibility tree`.

The `accessibilityElements` array is a powerful tool. It allows not only setting the order, but also removing extra elements or adding new ones that aren't in the view hierarchy.

If there are too many elements or they're loaded lazily, you can use the "dynamic" functions. With them, you don't have to load all the objects into memory, but you can describe enough for VoiceOver to work.

```swift
func accessibilityElementCount() -> Int
func accessibilityElement(at index: Int) -> Any?
func index(ofAccessibilityElement element: Any) -> Int 
```

## Hiding a subtree

Sometimes a whole block of elements shouldn't participate in navigation: a modal window covers the main content, a loader blocks the screen, or part of the interface is temporarily inactive. The `accessibilityElementsHidden = true` property excludes the entire view subtree from the accessibility tree — VoiceOver doesn't see it.

```swift
loadingOverlay.accessibilityElementsHidden = true
```

The main scenario is modal windows and overlays. When you show a popup over the screen, the background content should be inaccessible, otherwise VoiceOver will continue to focus on elements under the modal:

```swift
func presentModal() {
    backgroundView.accessibilityElementsHidden = true
    view.addSubview(modalView)
}

func dismissModal() {
    modalView.removeFromSuperview()
    backgroundView.accessibilityElementsHidden = false
}
```

> Note: `accessibilityElementsHidden` differs from `isAccessibilityElement = false`: the first hides the entire subtree, the second — only the element itself, while its children are still accessible.

## Headings

![](Headers)

The `.header` trait adds the word "heading" to the element's description:

```swift
titleLabel.accessibilityTraits.insert(.header)
```

Headings are one of the main ways of navigating through the <doc:13-Rotor-en>. The user switches the rotor to "Headings" mode and with vertical swipes moves from heading to heading, quickly examining the screen's structure.

Section headers in `UITableView` are supported automatically — VoiceOver already knows that they are headings. But if you're building a custom header, don't forget to add the `.header` trait manually.

Unlike HTML, iOS doesn't have heading levels (h1, h2, h3). There's only one `.header` trait, and the rotor jumps over all headings equally. That's why there shouldn't be too many headings — otherwise navigating through them loses meaning.

## Containers

@Comment {
    В отдельную главу
}

![](Containers)

A container is a logical group of elements that can have a name. VoiceOver announces the container's name when focus enters it — this helps to understand the screen's structure.

Set the container type via `accessibilityContainerType`:

```swift
stackView.accessibilityContainerType = .semanticGroup
stackView.accessibilityLabel = "Ratings and reviews"
```

Available types:

- `.semanticGroup` — a logical group of elements. VoiceOver speaks the name on entry.
- `.list` — a list. VoiceOver will say the number of elements.
- `.table` — a table. Requires implementing the `UIAccessibilityContainerDataTable` protocol.

The `.table` type is the most complex. For VoiceOver to be able to navigate the rows and columns of the table, you need to implement the `UIAccessibilityContainerDataTable` protocol:

```swift
extension DataTableView: UIAccessibilityContainerDataTable {

    func accessibilityDataTableCellElement(
        forRow row: Int,
        column: Int
    ) -> UIAccessibilityContainerDataTableCell? {
        return cells[row][column]
    }

    func accessibilityRowCount() -> Int {
        return cells.count
    }

    func accessibilityColumnCount() -> Int {
        return cells.first?.count ?? 0
    }
}
```

Each cell must support the `UIAccessibilityContainerDataTableCell` protocol, indicating the row and column.

## A container without a view

Sometimes you need to create a logical container that doesn't correspond to any view in the hierarchy. For example, you want to group several elements that lie in different parts of the hierarchy.

Create a `UIAccessibilityElement` as an invisible container:

```swift
let container = UIAccessibilityElement(
    accessibilityContainer: parentView
)
container.accessibilityLabel = "Order information"
container.accessibilityContainerType = .semanticGroup
container.accessibilityFrameInContainerSpace = combinedFrame
container.accessibilityElements = [
    orderNumberLabel,
    statusLabel,
    dateLabel
]
```

The `accessibilityFrameInContainerSpace` property sets the container's frame in the parent view's coordinates. This is more convenient than `accessibilityFrame`, which works in screen coordinates.

The element isn't displayed visually, but VoiceOver sees it as a container and announces the name on entry.

## Edge elements

![](EdgeElements)

VoiceOver lets you quickly jump to the first or last element of the screen: a four-finger tap at the top of the screen moves focus to the first element, a four-finger tap at the bottom — to the last.

This is used often, so think about which element will be first and which one — last:

- **First element** — the "Close" or "Back" button. The user expects to find a way to leave the screen at the very beginning.
- **Last element** — the confirmation button, "Pay", "Save". The user jumps to the end to perform the target action.

Manage the order through `accessibilityElements`, so the edge elements are exactly the ones the user needs.

@Comment {
    надо ли тут про табы написать?
}
