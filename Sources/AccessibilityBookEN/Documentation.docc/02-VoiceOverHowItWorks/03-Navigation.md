# Navigation

How to use the phone when you can't see anything

@Metadata {
    @PageImage(purpose: card, source: "navigation-focus")
}

## Focus

When you turn on VoiceOver, a black frame appears on the screen — that's the focus. The focus
moves through interface elements from swipes on the screen and reads the description
of the new element right after it moves.

This kind of interface has several immediate consequences:
— You can only work with one element at a time.
— All actions on the screen are sent to the focused element.
— You don't have to aim at the element. A swipe anywhere on the screen will affect the
focused element.
— If you want to hear the description again — tap the screen.

## Swipe navigation

**Swipe right** to move to the next control — elements switch in reading order. Swipe left switches focus to the previous element.

![Focus moves between elements in reading order.](navigation-focus)

If the focus reached the last element in a row, then on a right swipe it will switch to the next row by itself. Just like the way we read text.

![Focus moves between elements in reading order.](navigation-next-row)

## Mobile interface specifics

This system is logical, but on mobile there's one nuance: most often only one element fits in a row, so on a swipe right VoiceOver switches *to the next line.*

![On mobile devices, swipe right most often switches to the element below.](navigation-mobile)

It turns out that most often a swipe right switches to the next element *down*, and a swipe left to the previous element *up*. Unusual, but now you know why.

![On mobile devices, swipe right most often switches to the element below.](navigation-mobile-inverted)

## Explore by touch

You can move the focus not only with swipes, but also with "touch": drag your finger across the screen, and VoiceOver will read the element under your finger. Swipes are used much more often, but explore-by-touch is an important helper in everyday tasks.

Both methods will be mentioned further in the book, so remember their official names: **swipe navigation** and **explore by touch.**
