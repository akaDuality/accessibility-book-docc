# Rotor

The rotor lets you choose what vertical swipes will do: move between headings, buttons, text fields, and so on. Customizing the rotor can greatly simplify navigation.


### What the rotor is for

Up to this point we've been looking at moving between adjacent controls with horizontal swipes. Stepping through all controls one by one can be tiring, especially if you know the item you want is somewhere far away.

Quite often you need to jump to the next group of elements, heading, button, or link. To speed up navigation between distant elements, Apple suggests using vertical swipes. Swipe up — go to the next, down — to the previous.

Sometimes you need to navigate by buttons, sometimes by links, and sometimes by headings. The navigation mode needs to be chosen, and this can be done through the "rotor".

The rotor is a special control that's responsible for the navigation mode. You can invoke it by rotating two fingers on the screen, as if you were rotating a photo on the phone or changing the volume on a music controller.

![](RotorPhone)

By continuing to rotate, you'll change the navigation mode. The modes will change depending on the context and the user's settings, there are many options. After stopping at the desired mode (for example, headings), swipe vertically — the focus will move between elements far apart from each other.

The rotor is universal and works the same way on Apple Watch.

![](RotorAppleWatch)

Through the rotor you can not only choose the navigation mode but also change some settings, for example, the reading speed or the language.

Supporting the rotor isn't hard — it's enough to mark headings and name areas of the interface. For special cases you can also create your own rotor.

It may seem that vertical swipes are overloaded: they adjust .adjustable elements, custom actions, additional descriptions, and the current rotor setting, but in practice you don't run into such a conflict that often.

### Rotor navigation modes

In iOS 14, the rotor has [more than 40 modes](https://support.apple.com/ru-ru/HT204783): headings, containers, links, form elements, tables, images, static text, horizontal navigation, vertical navigation, and many others. The user themselves chooses which of them will be available in the VoiceOver settings.

![](RotorModes)

**Across the screen**
- headings,
- containers,
- html tags (landmarks),
- similar to current,
- vertical navigation,
- static text.

**Through text:**
- letters,
- words,
- lines.

**HTML:**
- tables,
- lists,
- buttons,
- forms (buttons and menus),
- text fields,
- search fields,
- images.

**Through links:**
- all,
- visited,
- unvisited,
- anchors on the page.

## Adding a rotor

![](CustomRotor)

Headings and containers are the basic part of fast navigation. If you have a more complex case, you can adapt it and add it to the rotor.

For example, we have a long list of products in the menu, grouped by type: pizza, combos, snacks, etc. I've gone through a few pizzas, picked the one I want, and want to move to drinks.

In the basic adaptation I'm forced to move to the category switcher, and I can only do it by touch, since a swipe back will scroll the list to the beginning. It would be wonderful if a swipe up anywhere in the list could change the category.

This kind of behavior can be added with UIAccessibilityCustomRotor. Working with it is simple:
- create a rotor, assign it to the customRotors property,
- give the rotor a name and a function that will handle the result,
- write this function. It will determine which next element should land in focus.

Now, when focus lands on a menu cell, VoiceOver will say: "Use the rotor to access the object: Product type". This way the user will learn about it and be able to configure the rotor for navigation.

`UIAccessibilityCustomRotor` lets you add your own navigation modes to the rotor. It's a powerful tool when the standard modes aren't enough.

A rotor is created with a name and a handler. The handler receives a `UIAccessibilityCustomRotorSearchPredicate` with the search direction and the current element. It must return a `UIAccessibilityCustomRotorItemResult` with the target element, or `nil` if there are no more elements.

Custom rotors appear in the list after the standard ones. The user rotates the rotor and sees your item on equal footing with "Headings" and "Containers". Give the rotors clear names.

Example: navigation between table sections.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    tableView.accessibilityCustomRotors = [tableView.sectionRotor(title: "Product type")]
}

extension UITableView {
    func sectionRotor(title: String) -> UIAccessibilityCustomRotor {
        UIAccessibilityCustomRotor(name: title,
                                   itemSearch: handleRotorResult)
    }
    
    func handleRotorResult(predicate: UIAccessibilityCustomRotorSearchPredicate) -> UIAccessibilityCustomRotorItemResult? {
        guard let newPath = nextSection(direction: predicate.searchDirection) else { return nil }
        
        scrollToRow(at: newPath, at: .middle, animated: false)
        
        guard let firstCell = cellForRow(at: newPath) else { return nil }
        
        UIAccessibility.post(notification: .layoutChanged, argument: firstCell)
        
        return UIAccessibilityCustomRotorItemResult(targetElement: firstCell, targetRange: nil)
    }
}
```

The code for the helper functions can be found [on GitHub](https://github.com/akaDuality/AccessibilityRotorSample).
