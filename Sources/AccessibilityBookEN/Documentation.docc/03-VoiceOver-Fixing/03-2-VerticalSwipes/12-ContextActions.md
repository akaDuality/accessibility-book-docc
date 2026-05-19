# Custom actions

All actions inside a button can be moved into custom actions, which are selected with vertical swipes


![Cell in the cart and in the menu](verticalSwipes-contextActions)

Let's adapt a cell from the cart. Externally it's very similar to a menu cell: it also has a name, price, and description. For the menu cell we combined the name with the price, and moved the description into value. With the cart we could do the same, but it has a significant difference — a quantity control.

By changing the quantity, we also change the price. After the value changes, VoiceOver will read exactly `.value`, so the quantity and price should end up there. Everything else doesn't change and will therefore be in label. The description is:

```
label Caesar, medium 30 centimeters, traditional dough,
value 1 piece, 695 rubles.
```

Up until now we always consolidated elements in cells down to a single control, but it's important for us not to lose the size switcher — it has to be controlled somehow. There's another nuance: for sighted users an action "delete" is available, which is hidden behind a swipe. Doing such a swipe from VoiceOver is inconvenient, and the action becomes inaccessible.

![The delete action is hidden behind a horizontal swipe](verticalSwipes-cartCell)

Such cell actions behind a swipe are quite standard for iOS, so there's a special adaptation for them: when focus lands on such a cell, VoiceOver adds to the end of the description:

```
Actions available: activate (selected), delete.
To switch actions, swipe up.
```

> Tip: vertical swipes are suitable not only for controlling an adjustable element, but can also switch the action from "activation" (`accessibilityActivate`) to something else. You can choose another action with a vertical swipe, and activate it with a double tap.

Let's go back to choosing the quantity. There are two actions: decrease and increase, but you can choose one of four:
- tap on the cell (nothing may happen, or you can, for example, edit the item),
- add,
- subtract,
- delete.

The full text of the cell will be:
```
label Caesar, medium 30 centimeters, traditional dough,
value 1 piece, 695 rubles.
Actions available: activate (selected), add, subtract, delete.
```

Now we need to figure out how to add these actions. The code is straightforward: we create an action, give it a name and a function to handle it, and then add this object to customActions:

```swift
let increase = UIAccessibilityCustomAction(
    name: "Add",
    actionHandler: { [unowned self] (action) -> Bool in
        // ... Increase the quantity
        return true
    })

let decrease = UIAccessibilityCustomAction(
    name: "Subtract",
    actionHandler: { [unowned self] (action) -> Bool in
        // ... Decrease the quantity
        return true
    })

let delete = UIAccessibilityCustomAction(
    name: "Delete",
    actionHandler: { [unowned self] (action) -> Bool in
        // ... Remove from the cart
        return true
    })

accessibilityCustomActions = [increase, decrease, delete]
```

![Example of a post from a social network](verticalSwipe-socialPost)

This same approach works great for **posts in social networks**. A post can have many buttons: like, comment, share, save, menu. All these buttons become custom actions of a single cell. The user doesn't wander through dozens of buttons, but quickly switches between actions with a vertical swipe.

```
label Dodo Engineering,
value Accessibility on iOS started with "36 seconds"…
Actions available:
— open link (selected),
— like,
— comment,
— share,
— go to "Dodo Engineering",
— info (double tap to read the number of views and time of posting).
```

> Note: Actions can be very complex and even nested. An example can be seen [in Apple's video about creating folders on the home screen](https://www.youtube.com/watch?v=w2Ds-I2L6PI).

> Tip: custom actions are also used in Voice Control and Switch Control
