// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
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
  int yearValue,dayValue;
 int monthValue;

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
      // Cause the clock to rebuild when the model changes.
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

  void upDateDayValue(){

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
    final miliseconds = DateFormat('mmm').format(_dateTime);
    yearValue = int.parse(year);
    monthValue = int.parse(month);
    dayValue = int.parse(day);
    final dayName = new DateTime.utc(yearValue, monthValue, dayValue);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: colors[_Element.background], fit: BoxFit.fill)),
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, right: 10.0, left: 10.0),
                                  child: Text(
                                    hour + ":" + minute + ":" + second,
                                    key: myTextKey,
                                    style: new TextStyle(
                                        fontSize: 100.0,
                                        fontFamily: 'LuckiestGuy',
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..shader =
                                              getTextGradient(myTextRenderBox)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                      ),
                      Expanded(
                        child: FlareActor(
                          "assets/dottedsecond.flr",
                          animation: "dotanimate",
                          color: Colors.orangeAccent,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, right: 10.0, left: 10.0),
                child: Text(
                  day + "/" + month + "/" + year,
                  style: new TextStyle(
                      fontSize: 50.0,
                      fontFamily: 'LuckiestGuy',
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = getTextGradient(myTextRenderBox)),
                ),
              ),
            ],
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
        Colors.black54,
        Colors.orangeAccent,
        Colors.orangeAccent,
        Colors.black54,
        Colors.black54
      ],
    ).createShader(Rect.fromLTWH(
        renderBox.localToGlobal(Offset.zero).dx,
        renderBox.localToGlobal(Offset.zero).dy,
        renderBox.size.width,
        renderBox.size.height));
  }
}
/*
 var berlinWallFell = new DateTime.utc(1989, DateTime.november, 9);
assert(berlinWallFell.weekday == DateTime.thursday);
 */