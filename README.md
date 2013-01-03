PassVue
=======

This is a slightly modified version of the `Pass Preview` application written by
Marin Todorov and available at [Ray Wenderlich's site].

`Pass Preview` is a useful tool if you are tinkering with passes for Passbook
on iOS.  It allows you to view a pass either in the iOS Simulator, or on a device.
However, viewing passes requires that you add them to the app bundle and recompile.

`PassVue` improves upon the original by searching for passes in the app's Documents directory. This allows you to add new passes simply by copying them into the appropriate directory.  If you are running `PassVue` on a device, you can add new passes using iTunes file sharing.

If you add a pass while running the app, use pull-to-refresh on the table view to cause the new passes to show up.

[Ray Wenderlich's site]: http://www.raywenderlich.com/20785/beginning-passbook-in-ios-6-part-22

