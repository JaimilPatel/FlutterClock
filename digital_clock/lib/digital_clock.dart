// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: AssetImage("assets/sunrise.jpeg"),
  _Element.text: Colors.black,
  _Element.shadow: Colors.transparent,
};

final _darkTheme = {
  _Element.background: AssetImage("assets/sunset.jpeg"),
  _Element.text: Colors.black,
  _Element.shadow: Colors.transparent,
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

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  int yearValue, dayValue;
  int monthValue;
  String _weather;
  GlobalKey myTextKey = GlobalKey();
  RenderBox myTextRenderBox;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordSize());
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
    setState(() {

    });
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

//  void _upDateWeatherCondition() {
//    setState(() {
//      _weather = widget.model.weatherCondition.toString();
//    });
//  }

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
    final date = new DateTime.utc(yearValue, monthValue, dayValue);
    final dayByData = DateFormat('EEEE').format(date);
    print("Current Weather : " + widget.model.weatherCondition.toString());
    _weather = widget.model.weatherString;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: _weather == WeatherCondition.cloudy ? AssetImage("assets/cloudy.jpeg")
                      : AssetImage("assets/thunderstorm.jpeg")
                      , fit: BoxFit.cover)),
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  hour + ":" + minute,
                                  key: myTextKey,
                                  style: new TextStyle(
                                      fontSize: 200.0,
                                      fontFamily: 'LuckiestGuy',
                                      fontWeight: FontWeight.normal,
                                      foreground: Paint()
                                        ..shader =
                                            getTextGradient(myTextRenderBox)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          second,
                          style: TextStyle(
                              fontSize: 50.0,
                              fontFamily: 'LuckiestGuy',
                              foreground: Paint()
                                ..shader = getTextGradient(myTextRenderBox)),
                        ),
                      ),
//                      Card(
//                        color: Colors.black,
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(10.0)),
//                        child: Padding(
//                          padding: const EdgeInsets.only(
//                              top: 15.0, left: 5.0, right: 5.0),
//                          child: Text(
//                            dayByData,
//                            style: TextStyle(
//                                fontSize: 50.0,
//                                fontFamily: 'Merriweather',
//                                foreground: Paint()
//                                  ..shader = getTextGradient(myTextRenderBox)),
//                          ),
//                        ),
//                      ),
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
    return LinearGradient(
      colors: <Color>[
        Colors.black54,
        Colors.orangeAccent,
        Colors.orangeAccent,
        Colors.black54,
      ],
    ).createShader(Rect.fromLTWH(
        renderBox.localToGlobal(Offset.zero).dx,
        renderBox.localToGlobal(Offset.zero).dy,
        renderBox.size.width,
        renderBox.size.height));
  }

  String _setImage() {
    String weatherInfo = widget.model.weatherCondition.toString();
    print("BackgroundIMage : " + weatherInfo);
    String _backgroundImage;
    if (weatherInfo == WeatherCondition.cloudy) {
      _backgroundImage = "assets/cloudy.jpeg";
    } else if (weatherInfo == WeatherCondition.foggy) {
      _backgroundImage = "assets/foggy.jpeg";
    } else if (weatherInfo == WeatherCondition.rainy) {
      _backgroundImage = "assets/rainy.jpeg";
    } else if (weatherInfo == WeatherCondition.snowy) {
      _backgroundImage = "assets/snowy.jpeg";
    } else if (weatherInfo == WeatherCondition.sunny) {
      _backgroundImage = "assets/sunny.jpeg";
    } else if (weatherInfo == WeatherCondition.thunderstorm) {
      _backgroundImage = "assets/thunderstorm.jpeg";
    }
    print("BackgroundIMage : " + _backgroundImage);
    return _backgroundImage;
  }
}
