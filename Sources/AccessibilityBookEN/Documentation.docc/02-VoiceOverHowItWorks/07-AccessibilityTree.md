# Accessibility tree

How VoiceOver builds the accessibility tree from the UIView hierarchy.

@Metadata {
    @PageImage(purpose: card, source: "a11y-tree-ui")
}

## UIAccessibility

Accessibility on iOS is provided by the `UIAccessibility` protocol. It works with any objects — they don't have to be interface elements.

```objc
@interface NSObject (UIAccessibility)
```

Most often VoiceOver queries element accessibility from the `UIView` hierarchy. From this data it creates the focus and overlays it on top of the interface.

![Pizza toppings interface: three cells with names and prices.](a11y-tree-ui)

Let's break down VoiceOver's structure using pizza toppings as an example. For a sighted person, there are 4 logical elements on the screen: a heading and three cells that can be tapped.

![Without adaptation, VoiceOver sees labels and prices as separate elements.](a11y-tree-human)

## What VoiceOver sees by default

For iOS, there are 13 elements on the screen:
- the heading
- 3 container cells with different states
- 3 images
- 3 names
- 3 prices

![Without adaptation, VoiceOver sees labels and prices as separate elements.](a11y-tree-ios)

VoiceOver already has a number of built-in rules by which it tries to read the interface correctly. For example, it doesn't focus on containers for other elements, so it won't stop on the cell. Images are inaccessible by default and VoiceOver doesn't see them either.

But VoiceOver considers the labels and prices to be separate elements, and a blind person will have to swipe between them again and again to read them.

VoiceOver also doesn't say anything about the screen's structure: it doesn't know that "add to pizza" is a heading, that something is unavailable or already added, and that the cell can be tapped.

## Adapted version

The developer's job is to tell VoiceOver how to read the elements correctly, what properties they have, how to group them, and what can be done with the controls.

![Adapted version: 4 clear elements instead of scattered labels.](a11y-tree-human)

The adapted version consists of four elements, with the following descriptions:

- **Add to pizza**, heading
- **Cheese crust**, 169 rubles, unavailable, button
- **Mushrooms**, 29 rubles, button
- **Selected**, Mozzarella, 49 rubles, button

After adding an ingredient, VoiceOver will also say the new price of the whole pizza.

It's all brief and clear at the same time. Blind users listen to VoiceOver at very high speed, so the text is more like audio beacons than a polished announcer's speech.

> Important: In essence, you need to go back to the first mental model — to tell VoiceOver what a sighted person sees on the screen anyway.

## One description — different technologies

Accessibility can be divided into two large groups
- Visual settings that help to read information more easily.
- Non-visual settings that change the way you control the phone.

All non-visual technologies work through a single accessibility tree, so adapting for one technology helps the other one work. What's more, different technologies in the form of UI-Automation or AI will also work through this same accessibility tree!

![](AccessibilityTechnologies)

> Tip: AI in mobile applications will also work through the accessibility tree
