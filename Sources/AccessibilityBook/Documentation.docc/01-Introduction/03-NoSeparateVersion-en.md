# No separate version for blind users

There's no need to build a separate version of the app for blind users — you need to adapt the existing one. VoiceOver turns the graphical interface into an audio one, allowing blind people to use the phone fully.

@Metadata {
    @PageImage(purpose: card, source: "mental-model")
}

## One app for everyone

On the web you can often find a separate version for blind or low-vision users; on mobile, I haven't seen this. Apparently it doesn't occur to anyone to write a second app for the special case, but let's discuss it anyway.

Suppose we decided to write an app specifically for a blind person. The first thing to understand: how do you even write such a version?

Technically, it's adapting controls using UIAccessibility. The functionality needs to be the same in scope as the regular version, and at the same time it's unclear how the graphical interface should change. So you end up with two versions: one you can't read with VoiceOver, the other you can't draw. But in both cases, we're still working with UIKit/SwiftUI.

## A second layer of data

The cool thing about accessibility technologies is that they take a lot of data from the existing graphical interface. They sit on top of it as a kind of "second layer," giving new ways to work with the interface: perceiving it by ear, controlling by voice, or otherwise signaling, if you can't touch the screen.

Sometimes accessibility can't correctly figure out what's happening on the screen, and you need to help a little. That's a little code, often just a few additional labels that let VoiceOver work with the app the way it should: announcing the selected state of the interface, naming all the elements on screen correctly, fixing the reading order of elements.

At the same time, it's extremely rare that you need to write some special text for blind users. You just need to set up the existing controls correctly.

![VoiceOver — sequential navigation through interface elements.](ImageToText)

> Tip: Don't build separate versions for people with impairments — build it well for everyone

## Mental model

Without adapting for accessibility, we work in "animated mockup with data" mode, copying only the external attributes, telling ourselves that's how it should be. By adapting for VoiceOver, we work with the mental model of perceiving information: that's a different level of understanding the interface and its complexity.

The mental model doesn't change based on the interaction method — a good model adapts perfectly to an audio interface as well. The audio interface may have a different reading speed, different interaction gestures, but the essence stays the same. Don't build separate versions for people with impairments — build it well for everyone.

![Graphical interface, audio interface, and mental model — bound by a shared structure.](mental-model)

## App descriptions (Nutrition Labels)

Every application can mark which accessibility features it supports.

![](NutritionLabels)

This makes it easier for Apple to put together various curated lists of accessible apps.

![](AccessibilityCollection)

@Comment {
    Расскать про UI-тесты
}
