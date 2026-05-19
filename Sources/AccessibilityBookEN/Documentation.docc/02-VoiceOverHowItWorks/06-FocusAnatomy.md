# Anatomy of focus

How VoiceOver finds elements on the screen, determines their properties, and describes them to the user.

## Finding accessible elements

For VoiceOver to work, it needs a control it can focus on. How does it find one?

First, we go to the root view and ask: does it have any **accessible elements**? To answer the question, `UIView` implements the `UIAccessibilityContainer` protocol and can go through all of its child elements to ask whether they are accessible. The marker is simple:

```swift
isAccessibilityElement = true
```

If an element isn't accessible, then maybe it works as a **container** for other accessible controls? Then you have to ask each one in turn whether they have elements. The nesting can be deep, but in the end there are only two options: either the `UIView` itself is accessible, or there are no more child elements at all.

## Focus frame

Let's imagine that we found an accessible element and decided to draw a frame around it. For the frame we need the **coordinates and size of the element**, and in screen coordinates, so that when the display is touched we can try to find this element among the hierarchy.

```swift
accessibilityFrame = frameInScreenCoordinates
```

## Element description

We've found the accessible control and outlined it. Now let's describe it.

The **description** is stored in `accessibilityLabel`. If the element has some **value**, then it's stored in `accessibilityValue` — it's read after a short pause and in a slightly different voice. This creates dynamics in VoiceOver's speech.

```swift
accessibilityLabel = "Pepperoni"
accessibilityValue = "625 rubles"
```

The control has standard properties:

- **type** — for example, label or button
- **state** — normal, selected, disabled
- **trait** — frequently updated, starts playing media, etc.

Usually a property adds text to the element's description and changes VoiceOver's behavior in some way.

## Activation

You've understood what this element is, that it's a button, and you want to **press** it. You can press a button with a double tap — it will call a special method `accessibilityActivate()`.

For a button, this method emulates a touch, and it presses on the **activation point** specified in `accessibilityActivationPoint`. Usually it's the center of the button, but you can move it.

@Comment {
    Ссылку на пример где двигаем    
}

## Screen change

If a new screen opens after a tap, then it **notifies** VoiceOver of its appearance and sets focus on its first element. The cycle repeats.

The algorithm is simple, but its strength is that it can work with all app interfaces, and only in games do you need to come up with something special. Other technologies work similarly: Voice Control will take the same information, Switch Control uses the same focus.

> Tip: Your job is to enrich the interface with data, to help the algorithm work correctly and turn your graphical interface into an audio one.

## When accessibility breaks

Accessibility breaks from any action:

- Removed the text from a button? Now VoiceOver doesn't know what to call it.
- Made a horizontal carousel to reduce the number of elements on the screen? You got a bunch of elements in VoiceOver.
- Placed 3 labels in a cell? Now focus stops on each of them separately.
- Reduced the `.alpha` of a button to show that it's disabled? VoiceOver didn't get the meaning and doesn't say that the button is unavailable.

There's no way to lay out an interface that doesn't break accessibility, because accessibility is the enrichment of the graphical interface with information about its structure.

## VoiceOver adaptation algorithm

To adapt you need to take 4 steps, each with its own section:

1. Label
2. Simplify
3. Fix navigation
4. Verify the scenario
