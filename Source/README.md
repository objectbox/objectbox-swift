ObjectBox Swift Sources
=======================

This folder contains the Swift sources for ObjectBox. This is the API you primary touch when working with ObjectBox.

We want to provide more sources in the future.
There are still some decisions to be made on our side regarding the layers below Swift.
Currently Swift calls into a ObjectiveC wrapper, but we are considering dropping this approach (let us know what you think).
Instead, we might change this to directly call into [ObjectBox's C API](https://github.com/objectbox/objectbox-c).   

Please note, that you cannot compile these sources standalone in Xcode at the moment.
We still hope that the Swift sources have some value for you. 