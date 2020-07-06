import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _weight = 220.0;
  final _ftSize = 160.0;

  fixed(n) {
    String s = n.toString();
    if (n < 10) {
      s = '0' + s;
    }
    return s;
  }

  StreamController<int> _second = StreamController();
  StreamController<int> _minute= StreamController();
  StreamController<int> _hour = StreamController();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (_) {
      _second.add(DateTime.now().second);
      _minute.add(DateTime.now().minute);
      _hour.add(DateTime.now().hour);
    });
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('周' + DateTime.now().weekday.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                    ),
                  ),
                  Text(DateTime.now().year.toString() + '年' + DateTime.now().month.toString() + '月' + DateTime.now().day.toString() + '日',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlipPanel.stream(
                    initValue: DateTime.now().hour,
                    itemStream: _hour.stream,
                    itemBuilder: (context, v) => Container(
                      alignment: Alignment.center,
                      width: _weight,
                      height: _weight,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(41, 41, 41, 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Text(
                        fixed(v),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _ftSize,
                            color: Colors.white),
                      ),
                    ),
                    spacing: 3.0,
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  FlipPanel.stream(
                    initValue: DateTime.now().minute,
                    itemStream: _minute.stream,
                    itemBuilder: (context, v) => Container(
                      alignment: Alignment.center,
                      width: _weight,
                      height: _weight,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(41, 41, 41, 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Text(
                        fixed(v),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _ftSize,
                            color: Colors.white),
                      ),
                    ),
                    spacing: 3.0,
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  FlipPanel.stream(
                    initValue: DateTime.now().second,
                    itemStream: _second.stream,
                    itemBuilder: (context, v) => Container(
                      alignment: Alignment.center,
                      width: _weight,
                      height: _weight,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(41, 41, 41, 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Text(
                        fixed(v),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _ftSize,
                            color: Colors.white),
                      ),
                    ),
                    spacing: 3.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Signature for a function that creates a widget for a given index, e.g., in a
/// list.
typedef Widget IndexedItemBuilder(BuildContext, int);

/// Signature for a function that creates a widget for a value emitted from a [Stream]
typedef Widget StreamItemBuilder<T>(BuildContext, T);

/// A widget for flip panel with built-in animation
/// Content of the panel is built from [IndexedItemBuilder] or [StreamItemBuilder]
///
/// Note: the content size should be equal

enum FlipDirection { up, down }

class FlipPanel<T> extends StatefulWidget {
  final IndexedItemBuilder indexedItemBuilder;
  final StreamItemBuilder<T> streamItemBuilder;
  final Stream<T> itemStream;
  final int itemsCount;
  final Duration period;
  final Duration duration;
  final int loop;
  final int startIndex;
  final T initValue;
  final double spacing;
  final FlipDirection direction;

  FlipPanel({
    Key key,
    this.indexedItemBuilder,
    this.streamItemBuilder,
    this.itemStream,
    this.itemsCount,
    this.period,
    this.duration,
    this.loop,
    this.startIndex,
    this.initValue,
    this.spacing,
    this.direction,
  }) : super(key: key);

  /// Create a flip panel from iterable source
  /// [itemBuilder] is called periodically in each time of [period]
  /// The animation is looped in [loop] times before finished.
  /// Setting [loop] to -1 makes flip animation run forever.
  /// The [period] should be two times greater than [duration] of flip animation,
  /// if not the animation becomes jerky/stuttery.
  FlipPanel.builder({
    Key key,
    @required IndexedItemBuilder itemBuilder,
    @required this.itemsCount,
    @required this.period,
    this.duration = const Duration(milliseconds: 500),
    this.loop = 1,
    this.startIndex = 0,
    this.spacing = 0.5,
    this.direction = FlipDirection.down,
  })  : assert(itemBuilder != null),
        assert(itemsCount != null),
        assert(startIndex < itemsCount),
        assert(period == null ||
            period.inMilliseconds >= 2 * duration.inMilliseconds),
        indexedItemBuilder = itemBuilder,
        streamItemBuilder = null,
        itemStream = null,
        initValue = null,
        super(key: key);

  /// Create a flip panel from stream source
  /// [itemBuilder] is called whenever a new value is emitted from [itemStream]
  FlipPanel.stream({
    Key key,
    @required this.itemStream,
    @required StreamItemBuilder<T> itemBuilder,
    this.initValue,
    this.duration = const Duration(milliseconds: 500),
    this.spacing = 0.5,
    this.direction = FlipDirection.down,
  })  : assert(itemStream != null),
        indexedItemBuilder = null,
        streamItemBuilder = itemBuilder,
        itemsCount = 0,
        period = null,
        loop = 0,
        startIndex = 0,
        super(key: key);

  @override
  _FlipPanelState<T> createState() => _FlipPanelState<T>();
}

class _FlipPanelState<T> extends State<FlipPanel>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  int _currentIndex;
  bool _isReversePhase;
  bool _isStreamMode;
  bool _running;
  final _perspective = 0.003;
  final _zeroAngle = 0.0001;  // There's something wrong in the perspective transform, I use a very small value instead of zero to temporarily get it around.
  int _loop;
  T _currentValue, _nextValue;
  Timer _timer;
  StreamSubscription<T> _subscription;

  Widget _child1, _child2;
  Widget _upperChild1, _upperChild2;
  Widget _lowerChild1, _lowerChild2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _isStreamMode = widget.itemStream != null;
    _isReversePhase = false;
    _running = false;
    _loop = 0;

    _controller =
    new AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isReversePhase = true;
          _controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          _currentValue = _nextValue;
          _running = false;
        }
      })
      ..addListener(() {
        setState(() {
          _running = true;
        });
      });
    _animation = Tween(begin: _zeroAngle, end: math.pi / 2).animate(_controller);

    if (widget.period != null) {
      _timer = Timer.periodic(widget.period, (_) {
        if (widget.loop < 0 || _loop < widget.loop) {
          if (_currentIndex + 1 == widget.itemsCount - 2) {
            _loop++;
          }
          _currentIndex = (_currentIndex + 1) % widget.itemsCount;
          _child1 = null;
          _isReversePhase = false;
          _controller.forward();
        } else {
          _timer.cancel();
          _currentIndex = (_currentIndex + 1) % widget.itemsCount;
          setState(() {
            _running = false;
          });
        }
      });
    }

    if (_isStreamMode) {
      _currentValue = widget.initValue;
      _subscription = widget.itemStream.distinct().listen((value) {
        if (_currentValue == null) {
          _currentValue = value;
        } else if (value != _currentValue) {
          _nextValue = value;
          _child1 = null;
          _isReversePhase = false;
          _controller.forward();
        }
      });
    } else if (widget.loop < 0 || _loop < widget.loop) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_subscription != null) _subscription.cancel();
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildChildWidgetsIfNeed(context);

    return _buildPanel();
  }

  void _buildChildWidgetsIfNeed(BuildContext context) {
    Widget makeUpperClip(Widget widget) {
      return ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 0.5,
          child: widget,
        ),
      );
    }

    Widget makeLowerClip(Widget widget) {
      return ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.5,
          child: widget,
        ),
      );
    }

    if (_running) {
      if (_child1 == null) {
        _child1 = _child2 != null
            ? _child2
            : _isStreamMode
            ? widget.streamItemBuilder(context, _currentValue)
            : widget.indexedItemBuilder(
            context, _currentIndex % widget.itemsCount);
        _child2 = null;
        _upperChild1 =
        _upperChild2 != null ? _upperChild2 : makeUpperClip(_child1);
        _lowerChild1 =
        _lowerChild2 != null ? _lowerChild2 : makeLowerClip(_child1);
      }
      if (_child2 == null) {
        _child2 = _isStreamMode
            ? widget.streamItemBuilder(context, _nextValue)
            : widget.indexedItemBuilder(
            context, (_currentIndex + 1) % widget.itemsCount);
        _upperChild2 = makeUpperClip(_child2);
        _lowerChild2 = makeLowerClip(_child2);
      }
    } else {
      _child1 = _child2 != null
          ? _child2
          : _isStreamMode
          ? widget.streamItemBuilder(context, _currentValue)
          : widget.indexedItemBuilder(
          context, _currentIndex % widget.itemsCount);
      _upperChild1 =
      _upperChild2 != null ? _upperChild2 : makeUpperClip(_child1);
      _lowerChild1 =
      _lowerChild2 != null ? _lowerChild2 : makeLowerClip(_child1);
    }
  }

  Widget _buildUpperFlipPanel() => widget.direction == FlipDirection.up
      ? Stack(
    children: [
      Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _upperChild1
      ),
      Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase ? _animation.value : math.pi / 2),
        child: _upperChild2,
      ),
    ],
  )
      : Stack(
    children: [
      Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _upperChild2
      ),
      Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase ? math.pi / 2 : _animation.value),
        child: _upperChild1,
      ),
    ],
  );

  Widget _buildLowerFlipPanel() => widget.direction == FlipDirection.up
      ? Stack(
    children: [
      Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _lowerChild2
      ),
      Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase ? math.pi / 2 : -_animation.value),
        child: _lowerChild1,
      )
    ],
  )
      : Stack(
    children: [
      Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _lowerChild1
      ),
      Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateX(_isReversePhase ? -_animation.value : math.pi / 2),
        child: _lowerChild2,
      )
    ],
  );

  Widget _buildPanel() {
    return _running
        ? Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUpperFlipPanel(),
        Padding(
          padding: EdgeInsets.only(top: widget.spacing),
        ),
        _buildLowerFlipPanel(),
      ],
    )
        : _isStreamMode && _currentValue == null
        ? Container()
        : Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _perspective)
              ..rotateX(_zeroAngle),
            child: _upperChild1
        ),
        Padding(
          padding: EdgeInsets.only(top: widget.spacing),
        ),
        Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _perspective)
              ..rotateX(_zeroAngle),
            child: _lowerChild1
        )
      ],
    );
  }
}