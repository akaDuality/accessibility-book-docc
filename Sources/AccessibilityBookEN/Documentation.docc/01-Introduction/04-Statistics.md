# Statistics

I'll show the known numbers and explain how to collect the data.

## Evaluating accessibility is hard, but very important

Ugh, there are going to be a lot of charts now, but I'll walk through everything.

![](hard-to-explain)

## Demographics

If a product is used by millions, then among its users hundreds of thousands of people will have different needs: based on age, health conditions, life situation, language proficiency, and so on.
For them the service can be vitally important, but inaccessible. Apps affect a person's whole life and what they can do in it.

Without peeking ahead, answer this question: what target group is your interface designed for? If the answer is 16–40 years old, then I have bad news — that's only a third of all people in Russia. Look at the demographic pyramid: age on the vertical axis, the number of men and women on the horizontal. The chart shows what "aging population" means and where the "demographic hole" is, [more on Wikipedia](https://ru.wikipedia.org/wiki/Население_России).

![Demographic pyramid in Russia](demography-russia)

The demographic picture directly affects large businesses, because it shows where to look for additional audience for a service and what changes in the audience are coming in the next few years.

Maybe right now a huge niche for your service lies in adapting the app for "grandma phone" mode, where the interface's capabilities are limited to the main actions:
- the phone doesn't accept incoming calls from unknown numbers
- music plays only the favorite playlist
- photos shows from a shared album
- the camera can only take pictures

![Grandma phone mode on the home screen, music, photos, and camera](UI-for-grandmother)

## How many people turn on at least one setting?

At the very beginning, absolutely everyone asks themselves "well, how many of these blind users do we have? 10? 20?". But that's the wrong question: it narrows everything down to a single category of user, and you need to look at the whole picture. I'd phrase it like this:

> Tip: How many people turn on at least one accessibility setting?

You can take a benchmark from the [appt.org](appt.org) website. It turns out that 45% of people turn on at least one accessibility setting, and 15% turn on two or more. The study counts dark theme as part of accessibility (which is true, but skews the picture a bit), and the next most popular setting — changing the font size — is turned on by 34% of people.

> Tip: A third of users use accessibility settings

![Screenshot from the website](enabled-settings)

## Which settings are turned on most often

When more than two accessibility settings are turned on, it becomes interesting which ones are used together. The table is hard to read, but the idea is this: vertically we show the chance that a setting will be turned on first, second, third, and so on. It turns out that most often the first setting:
- increases text size (36% chance)
- or increases font weight (17%)
- or turns on the I and O labels on the switcher (17%)

At the same time, these same settings will be the second most popular, i.e. you can consider that they go in pairs.

The third setting most often turned on is increase contrast or reduce transparency.

![Table of how often each setting is turned on](first-settings)

## Importance vs. popularity

In the chart above, you can see that the screen reader falls completely out of our settings popularity chart. So is it unimportant? No, it's *not popular*, but it is critically important! Let's split the settings into two groups:
- **Visual settings** help people who don't see well to see the interface more easily: dark theme, increasing font size, increasing weight, disabling animations, and so on. Usually without this it'll be less convenient for a person, but there are alternatives: put on glasses, hold the phone closer, or turn on the screen magnifier.
- **Assistive program support**: fundamentally lets people use your program, there's no way around it. A screen reader lets blind users use the app by ear, Switch Control helps people without hands, and Voice Control lets you control the program with your voice.

@Comment {
    Показать на графике
}

### Properly evaluating popularity for the screen reader

For the second group of assistive programs, it's important to count all the numbers correctly.
- Use of VoiceOver, Switch Control, and Voice Control should be summed. This is the critical percentage of people who need accessibility
- To that you also need to add several audio settings: Speak Screen for reading everything on screen, and Speak Selection for reading selected text.

Most likely, in the end it'll turn out that 3–3.5% of your users want the phone to read the screen contents aloud, rather than reading it themselves. That's the percentage of people for whom adapting for a screen reader helps.

Usually statistics only count visual settings, which is wrong.

> Tip: count the settings that read the screen contents.

It may also turn out that adding voice input or output to a product can greatly improve the convenience of the app. For example, people listen to audiobooks on the road, and a query to a neural network is more convenient to dictate by voice.

## How to collect statistics

A product-level problem with accessibility is that no one knows how to adequately collect numbers from their own business: the analyst doesn't understand the subject area and what can be collected, and developers also don't know and can't interpret it.

The [Capable](https://github.com/chrs1885/capable) library will help with collecting analytics: in the description you can see which settings you can actually measure, and in the code developers can learn how to collect this data.

> Warning: some countries may consider accessibility settings to be medical data. Under no circumstances tie taxi pricing tiers, for example, to these settings.

![](capable)


## Flip the approach

In the end, accessibility turns out to be much broader: it's not so much support for a narrow group of people as a look at the product through people's needs and their limitations. This way you can also look at different needs of people by age, social group, limitations of their abilities, and, in the end, overall convenience.

> Tip: The app accounts for the user's needs and adapts to them, rather than the person adapting to the app.
