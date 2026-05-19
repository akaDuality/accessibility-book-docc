# Vertical swipes

Horizontal swipes switch focus between elements, while vertical swipes change the value inside an element.

## Overview

In the previous chapters we labeled elements and reduced their number, which made using the app possible and even convenient. The screen can now be traversed with horizontal swipes and all elements will be read.

In this chapter we'll discuss vertical swipes. With them you can perform actions on the focused element, for example:
- change the value inside the element (as in UISlider or UIStepper),
- switch the action from activation to something else (like cell actions that hide
behind a swipe),
- tell more about the current element.

Let's go through all the cases in detail, since they can greatly increase the convenience of
using the app.

## The .adjustable trait

![Stepper, slider, and segmented control are controlled by vertical swipes](verticalSwipes-samples)

Up until now we've only used one behavior trait for a button — `.button`. It added the text "button" to the description and called the `accessibilityActivate()` method on a double tap.

What elements are more complex than a button? For example, `UIStepper`, `UISegmentedControl`, and `UISlider`. At first glance the elements are very different, but the operation of all three can be reduced to a single rule: the control lets you choose a value. The only difference is that they give different control over the precision of changes:
- `UIStepper` changes the value to the nearest one;
- `UISlider` lets you pick from a wide range, but with low precision;
- `UISegmentedControl` shows all values, you can switch to any.

If we simplify the model even further, the value inside the control can be decreased or increased. This is a fairly common pattern, so VoiceOver has a special behavior modifier for it — the .adjustable trait.

To switch between elements we use horizontal swipes: to
the next and the previous. On switching, the label is read.

What if vertical swipes affected the inner state of the control? For example, we could use them to change the value stored in `.accessibilityValue`? Then a swipe "up" could increase the quantity, and a swipe "down" decrease it.

This is what the `.adjustable` trait is for. When you add it to an element, three things happen:

1. The phrase **"adjustable"** is added to the element's description.
2. VoiceOver hints at the gesture: "Swipe up or down with one finger to adjust the value".
3. On a vertical swipe, the `accessibilityIncrement()` or `accessibilityDecrement()` methods are called.

After a swipe, VoiceOver doesn't re-read the entire description of the element — **only the new value is read**. This makes switching between values fast and unobtrusive.

## UIStepper

![Examples of steppers](verticalSwipes-stepper)

A stepper can take different forms, but the essence stays the same: we have some value and we change it by a small step. Sometimes the label is next to it, sometimes inside. In any case, let's make it one element: name it, separate the changing value, and tell how to interact with it.

- **Name.** We're changing the number of elements; we can just write that: "quantity".
- **Value.** A number is enough, but it can be turned into full text: "3 events".
- **Trait.** You can set the .adjustable trait, then we'll be able to adjust the count with vertical swipes, and after our changes VoiceOver will read the new value.

```
label: Quantity,
value: 3 events,
trait: adjustable.
```

Let's turn this description into code. We need to make the whole stepper an accessible element, give it a name, and specify the `.adjustable` type.

```swift
class CustomSlider: UIView {
    var count: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isAccessibilityElement = true
        accessibilityLabel = "Quantity"
        accessibilityTraits = .adjustable
    }
    
    // The value can be made a computed property:
    override var accessibilityValue: String? {
        get { return "\(count) events" }
        set {}
    }
    
    // These functions are called on vertical swipes
    // Swipe up increases the count
    override public func accessibilityIncrement() {
        count += 1
        count.limit(by: 0...10)
    }
    
    // Swipe down decreases it
    override public func accessibilityDecrement() {
        count -= 1
        count.limit(by: 0...10)
    }
}
```

Now VoiceOver reads: "Quantity, 3 events, adjustable". A swipe up increases the value, a swipe down decreases it. After each swipe, only the new value is read: "4 events", "5 events".

If the value doesn't change after the swipe — for example, the end of the range has been reached — VoiceOver plays a characteristic sound signal. The user immediately understands that they can't go further.

> Note: It's strange that UIStepper isn't an adjustable element by default, it's very well-suited to this scenario.

### Stepper with text

![The text next to the stepper should be moved into the stepper's name](verticalSwipes-stepperWithText)

There's often explanatory text next to a stepper. Visually we perceive such a control as a single whole, so the screen reader needs the same kind of adaptation. The UILabel should be hidden from VoiceOver, and the focus frame should be enlarged so it wraps both the label and the stepper.

Along with the product quantity, the total price often changes too. Tell about the new price together with the quantity via .accessibilityValue.

```swift
override var accessibilityValue: String? {
    get {
        let totalPrice = count * price
        return "\(count), \(totalPrice) rubles"
    } set {}
}    
```

> Tip: combine controls by meaning, even if visually they're several elements

## UISlider

![Example of a speech rate slider](verticalSwipes-slider)

A slider works on the same principle as a stepper: a vertical swipe changes the value. Each swipe changes the value by about **10%** of the total range.

The good news — `UISlider` already has the `.adjustable` trait by default. You only need to set its `accessibilityLabel`:

```swift
slider.accessibilityLabel = "Speech rate"
```

VoiceOver will read: "Speech rate, 50%, adjustable".

If a 10% step is too coarse, there's an alternative gesture: **double tap and hold**. After the double tap, don't release the finger — the slider will switch to fine-tuning mode. Move your finger left or right to smoothly change the value, the way we usually do it.

> Tip: If there's already text with the name next to it, hide it from VoiceOver so it doesn't read the same thing twice aloud.

## UISegmentedControl

![A segmented control for choosing dough type: traditional or thin](verticalSwipes-segmented-simple)

VoiceOver considers `UISegmentedControl` to be a group of buttons, so it reports their count in `accessibilityValue`:
```
label Traditional,
value 1 of 2,
trait Button.
```

But VoiceOver knows nothing about the context, so for the whole group it's worth clarifying the name through `label`, and moving the current value into `value`:
```
label Dough,
value Traditional, 1 of 2,
trait Button.
```

Now on focus VoiceOver will voice: "Dough, thin, 1 of 2. Button". It's become clearer.

### Segmented control with vertical swipes

![A segmented control for choosing pizza size: small, medium, large](verticalSwipes-segmented-size)

A UISegmentedControl can be turned into an adjustable element. Instead of several buttons, the user gets one element and switches values with vertical swipes:
```
label Size,
value Medium, 2 of 3
trait Adjustable.
```

Implementation in code:

```swift
let sizes = ["Small", "Medium", "Large"]
private var selectedIndex = 1 

override func awakeFromNib() {
    super.awakeFromNib()
    
    isAccessibilityElement = true
    accessibilityLabel = "Size"
    accessibilityTraits = .adjustable
}

override var accessibilityValue: String? {
    get {
        return sizes[selectedIndex]
    } set {}
}  
    
// These functions are called on vertical swipes
// Swipe up increases the count
override public func accessibilityIncrement() {
    selectedIndex += 1
    selectedIndex.limit(by: 0...2)
}

// Swipe down decreases
override public func accessibilityDecrement() {
    selectedIndex -= 1
    selectedIndex.limit(by: 0...2)
}
```
@Comment {
    Странный код    
}

> Tip: It turns out that visually identical elements may have different VoiceOver behavior, because they have a different mental model. Wow!


### Change after a swipe

![](verticalSwipe-notification)

If with a vertical swipe you're changing the size of a drink, pizza, or clothing, then along with the size the price may also change. In such a case, you need to send a notification that will additionally announce the price change. More on this later in the chapter <doc:14-Notifications>.

```swift
UIAccessibility.post(
    notification: .announcement,
    argument: "200 rubles"
)
```


