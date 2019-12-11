// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/AllStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.black,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  int yearValue, dayValue;
  int monthValue;
  AllStrings allStrings = AllStrings();

  //String _weather;
  GlobalKey myTextKey = GlobalKey();
  RenderBox myTextRenderBox;
  Color secondColor;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    _updateSecondColor();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordSize());
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animationController.repeat();
  }

  void _recordSize() {
    setState(() {
      myTextRenderBox = myTextKey.currentContext.findRenderObject();
    });
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final day = DateFormat('dd').format(_dateTime);
    final month = DateFormat('MM').format(_dateTime);
    final year = DateFormat('yyyy').format(_dateTime);
    yearValue = int.parse(year);
    monthValue = int.parse(month);
    dayValue = int.parse(day);
    //final date = new DateTime.utc(yearValue, monthValue, dayValue);
    // final dayByData = DateFormat('EEEE').format(date);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: colors[_Element.background],
                  image: DecorationImage(
                      image: AssetImage(_setImage()), fit: BoxFit.cover)),
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          child: Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    hour + ":" + minute,
                                    key: myTextKey,
                                    style: new TextStyle(
                                        fontSize: 150.0,
                                        fontFamily: 'LuckiestGuy',
                                        fontWeight: FontWeight.normal,
                                        foreground: Paint()
                                          ..shader =
                                              getTextGradient(myTextRenderBox)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        AnimatedBuilder(
                                          animation: animationController,
                                          child: CircleAvatar(
                                            radius: 40.0,
                                            backgroundColor: Colors.black54,
                                            child: Text(
                                              second,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 50.0,
                                                  color: _updateSecondColor()),
                                            ),
                                          ),
                                          builder: (BuildContext context,
                                              Widget _widget) {
                                            return new Transform.translate(
                                              offset: Offset(
                                                  10.0,
                                                  animationController.value *
                                                      10),
                                              child: _widget,
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Text(
                                            "" + _setHourString(),
                                            style: TextStyle(
                                                fontSize: 50.0,
                                                fontFamily: 'LuckiestGuy',
                                                fontWeight: FontWeight.normal,
                                                foreground: Paint()
                                                  ..shader = getTextGradient(
                                                      myTextRenderBox)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: secondColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.model.location +
                                "   " +
                                widget.model.temperatureString,
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.black),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Shader getTextGradient(RenderBox renderBox) {
    if (renderBox == null) return null;
    Shader newShader;
    String _weatherInfo = widget.model.weatherString;
    switch (_weatherInfo) {
      case "cloudy":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.grey,
            Colors.grey,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "foggy":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.grey,
            Colors.grey,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "rainy":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.grey,
            Colors.grey,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "snowy":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.black54,
            Colors.black54,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "sunny":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.black54,
            Colors.black54,
            Colors.blueAccent,
            Colors.blueAccent,
            Colors.black54,
            Colors.black54,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "thunderstorm":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.black,
            Colors.brown,
            Colors.black,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
      case "windy":
        newShader = LinearGradient(
          colors: <Color>[
            Colors.black54,
            Colors.grey,
            Colors.black54,
          ],
        ).createShader(Rect.fromLTWH(
            renderBox.localToGlobal(Offset.zero).dx,
            renderBox.localToGlobal(Offset.zero).dy,
            renderBox.size.width,
            renderBox.size.height));
        break;
    }
    return newShader;
  }

  String _setImage() {
    String weatherInfo = widget.model.weatherString;
    String _backgroundImage;
    switch (weatherInfo) {
      case "cloudy":
        _backgroundImage = allStrings.cloudyImagePath;
        break;
      case "foggy":
        _backgroundImage = allStrings.foggyImagePath;
        break;
      case "rainy":
        _backgroundImage = allStrings.rainyImagePath;
        break;
      case "snowy":
        _backgroundImage = allStrings.snowyImagePath;
        break;
      case "sunny":
        _backgroundImage = allStrings.sunnyImagePath;
        break;
      case "thunderstorm":
        _backgroundImage = allStrings.thunderstormImagePath;
        break;
      case "windy":
        _backgroundImage = allStrings.windyImagePath;
        break;
      default:
        _backgroundImage = allStrings.sunnyImagePath;
    }
    return _backgroundImage;
  }

  String _setHourString() {
    final hour = int.parse(DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
        .format(_dateTime));
    String hourString;
    if (hour >= 12 && hour <= 24) {
      hourString = allStrings.AM;
    } else {
      hourString = allStrings.PM;
    }
    return hourString;
  }

  Color _updateSecondColor() {
    String weatherInfo = widget.model.weatherString;
    switch (weatherInfo) {
      case "cloudy":
        secondColor = Colors.grey[400];
        break;
      case "foggy":
        secondColor = Colors.grey[400];
        break;
      case "rainy":
        secondColor = Colors.grey;
        break;
      case "snowy":
        secondColor = Colors.white;
        break;
      case "sunny":
        secondColor = Colors.blueAccent;
        break;
      case "thunderstorm":
        secondColor = Colors.grey;
        break;
      case "windy":
        secondColor = Colors.grey;
        break;
      default:
        secondColor = Colors.grey;
    }
    return secondColor;
  }
}
