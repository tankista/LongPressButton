# LongPressButton

## Description

A custom UI control that allows user to trigger an event when long presses the controll. When user
puts a finer on the control an internal timer is started and after minimumPressDuration is reached
control begins new timer and starts animating the progress. Also a UIControlEvent.valueChanged event
is sent. If user lifts the finger before requiredPressDuration is reached UIControlEvent.touchCancel
control event is sent. If user holds finger longer than requiredPressDuration, progress animation is
finished and UIControlEvent.primaryActionTriggered is called.

![Preview Images](https://user-images.githubusercontent.com/500145/38583612-d95beb4a-3d13-11e8-9e8e-ebf0327b9b2d.png)

## Features

- animates long press duration
- detects single touch up inside without showing progress animation
- on scales down on touch down
- set title text for control states and control events
- set title text attributes for control states
- set background colors for control states
- supports UIAppearance
