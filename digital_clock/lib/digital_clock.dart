// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.text: Colors.black,
  _Element.shadow: Color(0xFF81B3FE),
};

final _darkTheme = {
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
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
  Color secondColor;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    _updateSecondColor();
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

  void _updateSecondColor() {
    setState(() {
      String weatherInfo = widget.model.weatherString;
      switch (weatherInfo) {
        case "cloudy":
          secondColor = Colors.grey;
          break;
        case "foggy":
          secondColor = Colors.black54;
          break;
        case "rainy":
          secondColor = Colors.green;
          break;
        case "snowy":
          secondColor = Colors.white;
          break;
        case "sunny":
          secondColor = Colors.grey;
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
    final date = new DateTime.utc(yearValue, monthValue, dayValue);
    final dayByData = DateFormat('EEEE').format(date);
    print("Current Weather : " + widget.model.weatherString);
    print("Temperature : " + widget.model.temperatureString);
    print("Current Location :" + widget.model.location);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(_setImage()), fit: BoxFit.cover)),
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.model.location,
                        style: TextStyle(fontSize: 30.0, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlipPanel.builder(
                            itemBuilder: (context, index) => Container(
                              color: secondColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                second,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 50.0,
                                    color: Colors.white),
                              ),
                            ),
                            itemsCount: second.length,
                            period: const Duration(milliseconds: 1000),
                            loop: 1,
                          ),
                          Text(
                            widget.model.temperatureString,
                            style:
                                TextStyle(fontSize: 40.0, color: Colors.white),
                          ),
                        ],
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
            Colors.black54,
            Colors.grey,
            Colors.grey,
            Colors.black54,
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
            Colors.black54,
            Colors.grey,
            Colors.grey,
            Colors.black54,
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
            Colors.green,
            Colors.pinkAccent,
            Colors.pinkAccent,
            Colors.green,
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
            Colors.black,
            Colors.white70,
            Colors.white70,
            Colors.black,
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
            Colors.green,
            Colors.orangeAccent,
            Colors.orangeAccent,
            Colors.green,
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
            Colors.black54,
            Colors.grey,
            Colors.brown,
            Colors.grey,
            Colors.black54,
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
            Colors.grey,
            Colors.grey,
            Colors.green,
            Colors.green,
            Colors.grey,
            Colors.grey,
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
        _backgroundImage = "assets/cloudy.jpeg";
        break;
      case "foggy":
        _backgroundImage = "assets/foggy.jpeg";
        break;
      case "rainy":
        _backgroundImage = "assets/rainy.jpeg";
        break;
      case "snowy":
        _backgroundImage = "assets/snowy.jpeg";
        break;
      case "sunny":
        _backgroundImage = "assets/sunny.jpeg";
        break;
      case "thunderstorm":
        _backgroundImage = "assets/thunderstorm.jpeg";
        break;
      case "windy":
        _backgroundImage = "assets/windy.jpeg";
        break;
      default:
        _backgroundImage = "assets/sunrise.jpeg";
    }
    return _backgroundImage;
  }

  String _upDateTemperature() {
    double currentTemp =
        double.parse(widget.model.temperatureString.replaceAll("°C", ""));
    double highTemp =
        double.parse(widget.model.highString.replaceAll("°C", ""));
    double lowTemp = double.parse(widget.model.lowString.replaceAll("°C", ""));
    print("Current Temperature " + currentTemp.toString());
    print("High Temperature " + highTemp.toString());
    String temperatureLogo;
    if (currentTemp > 26) {
      temperatureLogo = "assets/fire.gif";
    } else {
      temperatureLogo = "assets/sunny.jpeg";
    }
    return temperatureLogo;
  }
}
