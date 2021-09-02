import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isCounting = false;
  Duration _pickerTime;
  int _displayTime = 0;
  StreamSubscription<CountdownTimer> _currentTimerStream;

  StreamSubscription<CountdownTimer> _createTimerStream(int sec) {
    final timer = CountdownTimer(Duration(seconds: sec), Duration(seconds: 1));
    return timer.listen(null);
  }

  void _tappedStartButton() {
    setState(() {
      _displayTime = _pickerTime.inSeconds;
      _isCounting = true;
    });
    _startTimer();
  }

  void _tappedCancelButton() {
    if (_isCounting) _cancelTimer();
  }

  void _startTimer() {
    _currentTimerStream = _createTimerStream(_pickerTime.inSeconds);
    _currentTimerStream.onData((data) {
      setState(() {
        _displayTime = _pickerTime.inSeconds - data.elapsed.inSeconds;
      });
    });

    _currentTimerStream.onDone(() {
      _currentTimerStream.cancel();
      setState(() => {_isCounting = !_isCounting});
    });
  }

  void _cancelTimer() {
    _currentTimerStream.cancel();
    setState(() => {_isCounting = !_isCounting});
  }

  String get _parseDisplayTime {
    final mm = (_displayTime / 60).floor().toString().padLeft(2, '0');
    final ss = (_displayTime % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _isCounting ? _buildCountDownView() : _buildPicker(),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildLeftButton(), _buildRightButton()],
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountDownView() {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CircularCountDownTimer(
            width: double.infinity,
            height: double.infinity,
            duration: _displayTime,
            fillColor: Colors.white,
            ringColor: Colors.orange,
            isTimerTextShown: false,
          ),
          Text(
            _parseDisplayTime,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker() {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.ms,
      onTimerDurationChanged: (value) => {_pickerTime = value},
    );
  }

  Widget _buildLeftButton() {
    return FractionallySizedBox(
      child: GestureDetector(
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 8,
          child: _isCounting
              ? Text('cancel', style: TextStyle(fontSize: 24))
              : Text(''),
        ),
        onTap: () => _tappedCancelButton(),
      ),
    );
  }

  Widget _buildRightButton() {
    return FractionallySizedBox(
      child: GestureDetector(
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width / 8,
          backgroundColor: Colors.black45,
          child: _isCounting
              ? Text('')
              : Text('start', style: TextStyle(fontSize: 24)),
        ),
        onTap: () {
          if (!_isCounting) _tappedStartButton();
        },
      ),
    );
  }
}
