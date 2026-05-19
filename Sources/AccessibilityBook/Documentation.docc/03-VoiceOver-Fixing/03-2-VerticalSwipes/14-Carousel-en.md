# Carousel

Almost every app has a "carousel" — a horizontal scroll of elements: banners, section buttons, upsell blocks, etc. Such an element requires special adaptation for VoiceOver to be convenient to use.

A horizontal `UICollectionView` is one of the most problematic constructions for VoiceOver. By default, all carousel cells line up in a single row, and the user swipes through dozens of elements without understanding that this is a horizontal list.

The solution is to create a single accessible element with the `.adjustable` trait

## Carousel

A carousel is a fairly common interface element. As a rule, the elements inside the carousel have a single form and can be tapped. Most often people move to the next control with a swipe. For VoiceOver, carousels become a problem, since it first has to go through all the elements inside, and only then can it move to the next group. It's quite possible that the next controls will also be a carousel, and everything starts over. For example, promotions are followed by new items, and after them — product categories. You need to make several dozen swipes to get to the first pizza.

It would be much more convenient if the entire carousel were a single element, and the cells inside could be switched with a vertical swipe. Activate with a double tap: open a new screen, select an element, and so on.

The adjustable element and the .adjustable trait are well suited for this.

Apple suggests [an interesting move](https://developer.apple.com/documentation/uikit/accessibility_for_ios_and_tvos/delivering_an_exceptional_accessibility_experience): create an accessible element that will control
the carousel, place it on top of the collection, and hide the graphical carousel from
VoiceOver. Let's try.

![](CarouselExamples)

A horizontal `UICollectionView` is one of the most problematic constructions for VoiceOver. By default, all carousel cells line up in a single row, and the user swipes through dozens of elements without understanding that this is a horizontal list.

The solution is to create a single accessible element with the `.adjustable` trait:

Let's create a new UIAccessibilityElement. We can type the container and only accept collections, since that's where we'll be taking all the necessary parameters from.

```swift
init(accessibilityContainer: UICollectionView, title: String) {
    self.collectionView = accessibilityContainer
    
    super.init(accessibilityContainer: accessibilityContainer)
    
    accessibilityTraits = .adjustable
    accessibilityLabel = title
    accessibilityFrameInContainerSpace = collectionView.frame
}
```

The constructor assumes that the collection's frame is already calculated, so the code can only be called after layout, for example, in viewDidAppear(:). I call it inside a UICollectionViewController, so that everything that's in accessibilityElements is replaced with one new control.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    view.accessibilityElements = [
        AccessibilityCarousel(accessibilityContainer: collectionView,
                              title: "Promotions")
    ]
}
```

First and foremost, the carousel is a horizontal UICollectionView and scrolling on it should switch to the next element. You can scroll it with three fingers: let it show the next element, set focus on it, and read the description.

```swift
override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    if direction == .left {
        return collectionView.accessibilityScrollForward()
    } else if direction == .right {
        return collectionView.accessibilityScrollBackward()
    }
    
    return false
} 
```

After scrolling, VoiceOver will read value, for which we'll take the central cell, glue its label and value together, and output it as the description of the current element. Ideally you should also add a position description: "3 of 12".
```swift
override var accessibilityValue: String? {
    get {
        guard let сell = centerCell() else { return nil }
        
        return [сell.accessibilityLabel,
                сell.accessibilityValue]
                    .compactMap { $0 }
                    .joined(separator: ", ")
    }
    set {}
}
```

The collection has the .adjustable type, so we need to implement the methods that will be called after the swipes. On a vertical swipe, let it also scroll to an element.
```swift
override func accessibilityIncrement() {
    collectionView.accessibilityScrollForward()
}
    
override func accessibilityDecrement() {
    collectionView.accessibilityScrollBackward()
}
```

The scroll function is simple: take the central element, calculate which one is next, and scroll to it. Scrolling back looks the same.

```swift
@discardableResult
func accessibilityScrollForward() -> Bool {
    guard let cell = centerCell(),
        let path = indexPath(for: cell),
        let nextPath = nextPath(for: path)
    else { return false }
    
    scrollAndFocus(path: nextPath)
    return true
}
```

After a swipe we should scroll to the next cell and center it. In addition, we rely on the selectionFollowFocus property — this standard property allows selecting an element as soon as it lands in focus. This behavior will be useful for instantly selecting a product type, but for promotions it isn't needed.

```swift
func scrollAndFocus(path: IndexPath) {
    scrollToItem(at: path,
                 at: .centeredHorizontally,
                 animated: true)
    
    if selectionFollowsFocus {
        selectAsUser(path: path)
    }
}
```

![](CategoriesPicker)
> Tip: Immediately selecting a section after scrolling can be done with the selectionFollowsFocus property

If selectionFollowFocus isn't set, then an element can be selected with a double
tap via the accessibilityActivate() function.

```swift
override func accessibilityActivate() -> Bool {
    guard let path = сollectionView.centerPath() else { return false }
    
    сollectionView.selectAsUser(path: path)
    return true
}
```
The standard hint for .adjustable will describe the complex behavior of the control:
"swipe up or down with one finger to change the value".

Actually, an .adjustable carousel will get in the way of UI tests, but more on that in the section
on Voice Control.

The full code with helper functions can be seen [on GitHub](https://github.com/akaDuality/AccessibilityCarousel).

This is the end of the critical navigation problems within a page, and we can
look at how blind users can also move around the page.




















```swift
class AccessibilityCarousel: UIAccessibilityElement {

    weak var collectionView: UICollectionView?

    override var accessibilityTraits: UIAccessibilityTraits {
        get { return .adjustable }
        set { }
    }

    override var accessibilityValue: String? {
        get {
            guard let collectionView = collectionView,
                  let currentIndex = currentVisibleIndex else {
                return nil
            }
            let cell = collectionView.cellForItem(
                at: IndexPath(item: currentIndex, section: 0)
            )
            return cell?.accessibilityLabel
        }
        set { }
    }

    override func accessibilityIncrement() {
        scrollToNext()
    }

    override func accessibilityDecrement() {
        scrollToPrevious()
    }

    override func accessibilityScroll(
        _ direction: UIAccessibilityScrollDirection
    ) -> Bool {
        switch direction {
        case .left:
            scrollToNext()
            return true
        case .right:
            scrollToPrevious()
            return true
        default:
            return false
        }
    }
}
```

The `.adjustable` trait allows changing the value with vertical swipes: a swipe up calls `accessibilityIncrement()`, a swipe down — `accessibilityDecrement()`. With one swipe the user switches a carousel cell, and `accessibilityValue` describes the current cell.

@Comment {
   в пицце был универсальный контрол для баннеров    
}
