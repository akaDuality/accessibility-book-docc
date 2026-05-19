# How VoiceOver works

VoiceOver turns the graphical interface into an audio one, allowing blind people to use the phone fully.

@Metadata {
    @PageImage(purpose: card, source: "voiceover-title")
}

Before we start adapting the app, we need to understand how blind people use the phone and what we need to do to make it more convenient for them.

For a blind person, the phone's screen turns into a trackpad: you can swipe across it in different directions, tap on it with one or several fingers. In response to the actions, VoiceOver speaks the current state of the interface: what element we're on, what you can do with it.

To understand this better, let's go through the whole evolution of an audio interface from scratch: we'll talk about the screen's contents, mark the elements you can interact with, and think about how to speed up navigation.

You can watch the video [how to use VoiceOver](https://www.youtube.com/watch?v=ncIER9Uvy54&themeRefresh=1) — only 8 minutes.

## The interface is listened to

The situation: you need to make a new screen for your app, you don't have a mockup, and you don't have internet either. You call the designer and they describe the picture to you over the phone. What will they tell you?

Most likely, they'll list the elements in order, name them, and tell you their specifics: the heading "Pizza", a label with the dough size, a "buy" button. From their description you'll understand the order of the elements, what they mean, what state they're in, what you can do with them. You're ready to work with this information. VoiceOver plays the role of such a friend. It takes one element, reads its description, tells you about its state (selected, disabled), says what type it is and what you can do with it. In response, you can ask to move to the next element, press a button, or close the current screen. Commands are given with different swipes on the screen.

VoiceOver does everything it can to reduce the amount of extra work. Don't build special versions for blind users; your job is just to help VoiceOver name everything correctly and handle the input. The cool thing about the technology is that there isn't that much work: speech synthesis is already built into iOS, and the multitouch screen recognizes complex gestures. Just adjust the readable text, element types, and handle a few extra functions.

![VoiceOver — sequential navigation through interface elements.](ImageToText)

## The phone screen is a trackpad

To give commands, blind users swipe across the screen with one, two, three, or even four fingers.

![VoiceOver gesture reference.](ScreenTouchpad)

## How to get started

Before adapting the app, you have to understand the details of how VoiceOver works, learn to control it, and see how it works using the standard apps as an example. Then, with an understanding of the audio interface, we move on to adapting our own app.
