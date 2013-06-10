MapKit
======

MapKit is an iOS 'library' for displaying tiled maps. While `MKMapView` was introduced in iOS 3.0, it lacks support for tile providers other than Google Maps. While this is not a big issue for most, it prevents developers from building applications that utilize data from atypical sources such as Google Mars or Google Sky. Please be aware of licensing issues when building custom tile providers. There are a few tile providers, OpenStreetMap ([licensing information](http://wiki.openstreetmap.org/wiki/OpenStreetMap_License)) and MapQuest ([terms of use](http://developer.mapquest.com/web/info/terms-of-use)).

NOTE: MapKit was only tested on iOS 4.0+. Due to changes in thread-safety of UIKit, it may not function properly on earlier versions of iOS.

Usage
-----

To use MapKit in your project, simply drag the contents of the `Sources` folder into your Xcode project.

Attributions
------------

Using pin clipart from [SweetClipart.com](http://sweetclipart.com/)

License
-------

Copyright (c) 2010-2012 Matt Rajca

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
