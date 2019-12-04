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
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.transparent,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
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

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/wallpaper.jpeg"), fit: BoxFit.fill)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                hour + ":" + minute + ":" + second,
                style: TextStyle(
                  fontSize: 80.0,
                  color: colors[_Element.text],
                ),
                textAlign: TextAlign.justify,
              ),

              Expanded(
                child: FlareActor(
                  "assets/dottedsecond.flr",
                  animation: "dotanimate",
                  color: Colors.white,
                  fit: BoxFit.fill,
                ),
              ),
            ]),
      ),
    );
  }
}
