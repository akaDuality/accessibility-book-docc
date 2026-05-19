# Before and after

A comparison of an unadapted and an adapted interface, using a pizza ordering app as an example.

@Metadata {
    @PageImage(purpose: card, source: "before-after-adapted")
}

## Unadapted screen

To understand the difference adaptation makes, let's look at the interface the way blind people use it. Let's take a screen that the developer just laid out and did nothing for accessibility, and then compare it with how this same screen is perceived after adaptation.

I launch the app and end up on some screen. To understand what's on it, I swipe up with two fingers and VoiceOver reads all the elements on the screen. I can go through them manually, but it takes a long time, since there are more than 22 on the screen.

Read this. Do you understand what screen you're on? Which elements can be tapped?

![List of 22+ elements read by VoiceOver without adaptation.](before-after-list)

There are a lot of elements. If I drag my finger across the left half of the screen, it also turns out strange: suddenly there are very few elements.

![With explore-by-touch on the left, few elements are visible.](before-after-left)

If you drag across the right half of the screen, new elements appear. There are still many questions about the screen: what is cheesy cheddar and cheese crust? What is pizza-combo-snacks-desserts? Can I tap on them? What will happen?

![With explore-by-touch on the right, different elements are visible.](before-after-right)

## Adapted screen

Now let's compare with the adapted version of this screen.

![Adapted version: 8 clear elements instead of 22.](before-after-adapted)

There are few controls, all have a type specified, it's clear how to interact with them, the descriptions are grouped, and the intonation is different (description, value, and type are read differently).

Buttons can be pressed by double tapping the screen, adjustable elements can be changed with vertical swipes, the areas on the screen are labeled (order type, promotions, menu, tab bar).

From this text, you can understand that this is the menu screen. And we didn't do anything complicated: we just gave all the elements a type, tweaked the description a bit, and grouped the elements.

## Graphical representation

This is how the menu screen looks graphically. There are many elements and types of controls, but it's easy to understand which blocks it consists of. Compare how similar this screen is to the text version in terms of perception. The mental model is one, but the representations are different.

![This is how the menu screen looks graphically.](before-after-visual)

## Result

**The number of elements has dropped sharply from 22 to 8**, and you can move between them both with swipes and by touch — either way it will be convenient. The clarity and convenience for a blind person have grown manyfold.

![This is how the menu screen looks graphically.](dodo-fullscreen)

Remember, in the unadapted version there were 22 elements? After adaptation, 22 elements is **four and a half screens**. The information density for speech has grown fourfold.
