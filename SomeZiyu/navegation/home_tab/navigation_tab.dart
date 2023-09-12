import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key key});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String _platformVersion;
  String _instruction;

  final _home = WayPoint(
      name: "Home",
      latitude: -33.404463132172765,
      longitude: -70.74289360723063);

  final _store = WayPoint(
      name: "BSF",
      latitude: -33.450772766557456,
      longitude: -70.78441820316147);

  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  MapBoxOptions _navigationOption;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _navigationOption = MapBoxNavigation.instance.getDefaultOptions();
    _navigationOption.simulateRoute = true;
    // _navigationOption.initialLatitude = 36.1175275;
    // _navigationOption.initialLongitude = -115.1839524;
    _navigationOption.enableFreeDriveMode = false;
    _navigationOption.language = 'es';
    _navigationOption.units = VoiceUnits.metric;
    _navigationOption.mode = MapBoxNavigationMode.drivingWithTraffic;
    _navigationOption.alternatives = false;
    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
    MapBoxNavigation.instance.setDefaultOptions(_navigationOption);

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MapBoxNavigation.instance.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Running on: $_platformVersion\n'),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Full Screen Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text("Start A to B"),
                          onPressed: () async {
                            print("viaja desde aqui");
                            var wayPoints = <WayPoint>[];
                            wayPoints.add(_home);
                            wayPoints.add(_store);
                            // MapBoxNavigation.instance.setDefaultOptions(MapBoxOptions())
                            await MapBoxNavigation.instance.startNavigation(wayPoints: wayPoints);
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Start Multi Stop"),
                          onPressed: () async {
                            // _isMultipleStop = true;
                            // var wayPoints = <WayPoint>[];
                            // wayPoints.add(_origin);
                            // wayPoints.add(_stop1);
                            // wayPoints.add(_stop2);
                            // wayPoints.add(_stop3);
                            // wayPoints.add(_destination);

                            // MapBoxNavigation.instance.startNavigation(
                            //     wayPoints: wayPoints,
                            //     options: MapBoxOptions(
                            //         mode: MapBoxNavigationMode.driving,
                            //         simulateRoute: true,
                            //         language: "en",
                            //         allowsUTurnAtWayPoints: true,
                            //         units: VoiceUnits.metric));
                            // //after 10 seconds add a new stop
                            // await Future.delayed(const Duration(seconds: 10));
                            // var stop = WayPoint(name: "Gas Station", latitude: 38.911176544398, longitude: -77.04014366543564);
                            // MapBoxNavigation.instance.addWayPoints(wayPoints: [stop]);
                          },
                        )
                      ],
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Embedded Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isNavigating
                              ? null
                              : () {
                            if (_routeBuilt) {
                              _controller?.clearRoute();
                            } else {
                              var wayPoints = <WayPoint>[];
                              wayPoints.add(_home);
                              wayPoints.add(_store);
                              _isMultipleStop = wayPoints.length > 2;
                              _controller?.buildRoute(
                                  wayPoints: wayPoints, options: _navigationOption);
                            }
                          },
                          child: Text(_routeBuilt && !_isNavigating
                              ? "Clear Route"
                              : "Build Route"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Start "),
                          onPressed: _routeBuilt && !_isNavigating
                              ? () {
                            _controller?.startNavigation();
                          }
                              : null,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Cancel "),
                          onPressed: _isNavigating
                              ? () {
                            _controller?.finishNavigation();
                          }
                              : null,
                        )
                      ],
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Long-Press Embedded Map to Set Destination",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: (Text(
                          _instruction == null
                              ? "Banner Instruction Here"
                              : _instruction,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, top: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Text("Duration Remaining: "),
                              Text(_durationRemaining != null
                                  ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes"
                                  : "---")
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const Text("Distance Remaining: "),
                              Text(_distanceRemaining != null
                                  ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles"
                                  : "---")
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider()
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey,
                child: MapBoxNavigationView(
                    options: _navigationOption,
                    onRouteEvent: _onEmbeddedRouteEvent,
                    onCreated:
                        (MapBoxNavigationViewController controller) async {
                      _controller = controller;
                      controller.initialize();
                    }),
              ),
            )
          ]),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        await Future.delayed(const Duration(seconds: 5));
        MapBoxNavigation.instance.finishNavigation();
        break;
      case MapBoxEvent.navigation_finished:
        MapBoxNavigation.instance.finishNavigation();
        break;
      case MapBoxEvent.navigation_cancelled:
        MapBoxNavigation.instance.finishNavigation();
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      // case MapBoxEvent.
      default:
        break;
    }
    setState(() {});
  }
}