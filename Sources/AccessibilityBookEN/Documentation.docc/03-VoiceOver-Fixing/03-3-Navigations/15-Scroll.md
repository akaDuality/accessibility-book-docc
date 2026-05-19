# Scroll
You rarely have to adapt scrolling yourself, but it's interesting to look at how it works for accessibility.


## Scroll

`UIScrollView` by default works as an accessibility container: VoiceOver traverses its child elements and scrolls the content automatically. But sometimes you need control.

For custom scrolling, implement `accessibilityScroll(_:)`:

```swift
override func accessibilityScroll(
    _ direction: UIAccessibilityScrollDirection
) -> Bool {
    switch direction {
    case .down:
        guard currentPage < totalPages - 1 else { return false }
        currentPage += 1
        scrollToPage(currentPage)

        UIAccessibility.post(
            notification: .pageScrolled,
            argument: "Page \(currentPage + 1) of \(totalPages)"
        )
        return true

    case .up:
        guard currentPage > 0 else { return false }
        currentPage -= 1
        scrollToPage(currentPage)

        UIAccessibility.post(
            notification: .pageScrolled,
            argument: "Page \(currentPage + 1) of \(totalPages)"
        )
        return true

    default:
        return false
    }
}
```

After scrolling, be sure to post a `.pageScrolled` notification with a description of the current position. VoiceOver will read this text, and the user will understand where they scrolled to. Without this notification, the scroll will be "silent", and the user will get lost in the content.

## Lists in a table

When a `UITableView` is scrolled with a three-finger gesture, VoiceOver should tell what's currently visible on the screen. For this, implement `UIScrollViewAccessibilityDelegate`:

```swift
extension ViewController: UIScrollViewAccessibilityDelegate {

    func accessibilityScrollStatus(
        for scrollView: UIScrollView
    ) -> String? {
        let visibleRows = tableView.indexPathsForVisibleRows ?? []
        guard let first = visibleRows.first,
              let last = visibleRows.last else {
            return nil
        }
        return "Showing rows \(first.row + 1) to \(last.row + 1) of \(items.count)"
    }
}
```

VoiceOver calls `accessibilityScrollStatus(for:)` after each scroll and voices the returned string. This helps the user understand where they are in the list.

For manual control of scrolling, implement `accessibilityScroll(_:)`:

```swift
override func accessibilityScroll(
    _ direction: UIAccessibilityScrollDirection
) -> Bool {
    switch direction {
    case .down:
        scrollToNextPage()
        return true
    case .up:
        scrollToPreviousPage()
        return true
    default:
        return false
    }
}
```

Return `true` if the scroll was performed, `false` — if not.

## How scrolling works inside

> Warning: This is a complex part for the most experienced, to better understand how everything works under the hood.

UIScrollView is an interesting example of a container for accessible elements:
- it reacts to focus movement and scrolls so that the element is visible;
- it can be scrolled with three fingers and it will update the focus position;
- after a scroll it will read a description of the content: which page you're on (2 of 3), where the focus is (in the center of the screen).

Usually nothing extra needs to be done for adaptation, UIScrollView works well on its own. Nevertheless, let's look at which methods need to be implemented if you want to replicate its behavior. The VoiceOver scenario is this:

1. The user swipes with three fingers in one of four directions.
2. VoiceOver looks for an element that can handle the accessibilityScroll(:) event and passes it the scroll direction.
3. You can intercept this event at some level and scroll. If you handled the event, return true — that ends the search. By default false is returned and VoiceOver continues up the UIView hierarchy until it finds someone who can handle it.
4. Inside the function you decide what to do with the scroll direction. The scroll view, tables, and collections shift by one screen.
5. Say you also decided to scroll by one screen. After scrolling you need to send a .pageScrolled notification and describe the new state of the screen. UITableView requests the description from accessibilityScrollStatus(for:), and UIScrollView reads the current position: "Page 3 of 12". Together with the notification, VoiceOver will produce a special vibration.

In the end you need to implement accessibilityScroll(:), scroll correctly, and trigger the notification. Let's look at an example. A product card can be long; there can be many additional ingredients, and they're hidden under the add-to-cart button. At the same time, the entire screen is inside a UIPageViewController, which can be swiped horizontally to change the product (it's a pity that for now there's no visual indication of this).

You need to scroll the screen in two cases:
- if you swiped three fingers vertically to see what's below. At the same time, you mustn't break the horizontal scroll for switching products.
- if the focus went outside the screen, then it needs to be scrolled so that the focus becomes visible.

At the level of the controller that contains the UIScrollView, you need to implement the accessibilityScroll(:) method, handle only vertical swipes, and for horizontal ones return false — that way VoiceOver will go up the hierarchy of controllers to the children, to check whether they can handle the swipe. And they can: the parent UIPageController can handle the horizontal swipe and show another product.

From the swipe direction you can understand which way to scroll. The screen is simple, so you need to scroll either to the start of the screen or to the end, that's enough. After the scroll, tell VoiceOver about the update via a notification and describe the new state of the screen. I couldn't come up with anything better than "top" and "bottom".

```swift
override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    switch direction {
    case .up:
        view().contentScrollView.scrollToTop()
        UIAccessibility.post(notification: .pageScrolled, argument: "Top")
        return true
        
    case .down:
        view().contentScrollView.scrollToBottom()
        UIAccessibility.post(notification: .pageScrolled, argument: "Bottom")
        return true
                             
    default:
        return false
    }
} 
```

Now we need to scroll the screen after focus switches to a control outside the visible area. Usually UIScrollView handles this on its own, implementing the UIFocusItemScrollableContainer protocol. If the standard behavior doesn't work, we can write our own: inherit from UIScrollView and implement everything that's needed.

UIKit notifies about focus changes through .elementFocusedNotification. We'll subscribe to it at the moment the view becomes part of the hierarchy. There's no need to unsubscribe if we're writing for iOS 9+.

```swift
override func didMoveToSuperview() {
    super.didMoveToSuperview()
    observeFocusUpdate()
}
    
private func observeFocusUpdate() {
    NotificationCenter.default
        .addObserver(
            self,
            selector: #selector(focusDidChanged(_:)),
            name: UIAccessibility.elementFocusedNotification,
            object: nil)
}
```

When focus changes, we need to get the current element that is focused, scroll to it so that it becomes visible, and report that the page layout has changed. We'll leave the focus on the element itself.

```swift
@objc private func focusDidChanged(_ notification: Notification) {
    guard let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIView 
    else { return }

    scrollRectToVisible(element.bounds, animated: false)
    UIAccessibility.post(notification: .layoutChanged, argument: element)
}
```

For VoiceOver to work correctly, you need to satisfy a few more conditions:
1. You need to check that the element is a child of the view, since we receive a notification from all controls on the screen, and we only need those inside the scroll view.
2. You need to convert the element's frame into the UIScrollView's coordinates, because it can be nested in other views.
3. The notification is only needed if the scroll actually happened, otherwise VoiceOver will incorrectly place focus when you exit the UIScrollView.

```swift
@objc private func focusDidChanged(_ notification: Notification)
    {
    guard let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey]
    as? UIView else { return }
    
    guard element.isChild(of: self) else { return }
    
    let offsetChanged = scroll(to: element)
    guard offsetChanged
    else { return } // No need to set focus of items that has been focused already
    
    UIAccessibility.post(notification: .layoutChanged, argument: element)
}
```

Helper code from the previous code examples:
4. A function that converts the frames, scrolls, and checks whether the offset has changed. By
the shift we'll understand that we need to notify VoiceOver about the layout change.

```swift
extension UIScrollView {
    fileprivate func scroll(to view: UIView) -> Bool {
        let oldOffset = contentOffset
    
        scrollRectToVisible(convert(view.bounds, from: view), animated: false)
    
        let offsetChanged = oldOffset != contentOffset
        return offsetChanged
    }
}
```

5. A recursive function checks whether the element is a child, so that UIScrollView handles only its own elements.

```swift
extension UIView {
    fileprivate func isChild(of parentView: UIView) -> Bool {
        for subview in parentView.subviews {
            if subview === self {
                return true
            }
            
            if isChild(of: subview) {
                return true
            }
        }
        
        return false
    }
}
```

Now when focus changes, UIScrollView will scroll so that the focused element is visible on the screen. Usually it works on its own, but if something goes wrong, you know how to fix it.

@Comment {
    Рассказать про кастомные заголовки
}  
