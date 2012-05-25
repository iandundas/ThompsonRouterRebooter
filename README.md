ThompsonRouterRebooter
======================

An iOS app to restart the Thomson TG585 v7 router, which is distributed by o2 Broadband.

Once the button is pressed, the app connects via telnet to the default IP address that the router uses, and tells it to restart itself.

I welcome pull requests if anyone wants to add support for more routers - it shouldn't be too hard to extend, and should work with any router that supports telnet access.


### Getting Started

`git clone git@github.com:iandundas/ThompsonRouterRebooter.git && cd ThompsonRouterRebooter`

You'll also need to run the following (in order to download CocoaAsyncSocket)

`git submodule init && git submodule update`

### Known Issues
About 10% of the time, nothing happens when you press the button. TODO: investigate why..

### Tested With

Tested with Thomson TG585 v7 O2 8.2.7.7.KP using iOS 5.1.1 (4S)

### Thanks
With thanks to Robbie Hanson's https://github.com/robbiehanson/CocoaAsyncSocket 

Also thanks for inspiration from here: http://nothingbutreboots.com/2009/hacking-the-o2-wireless-box-ii