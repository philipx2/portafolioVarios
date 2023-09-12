import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/home_tab_bloc.dart';
import 'package:ziyu_seg/src/components/error_default.dart';
import 'package:ziyu_seg/src/components/image_element.dart';
import 'package:ziyu_seg/src/components/modals/error_modal.dart';
import 'package:ziyu_seg/src/components/modals/loading_screen.dart';
import 'package:ziyu_seg/src/components/modals/modal_pod.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/models/lecture/lecture.dart';
import 'package:ziyu_seg/src/models/navegation/service_cancel.dart';
import 'package:ziyu_seg/src/models/navegation/service_order.dart';
import 'package:ziyu_seg/src/models/navegation/trip.dart';
import 'package:ziyu_seg/src/models/navegation/trip_data.dart';
import 'package:ziyu_seg/src/screens/lecture/lecture_credential_screen.dart';
import 'package:ziyu_seg/src/screens/lecture/lecture_screen.dart';
import 'package:ziyu_seg/src/screens/navegation/detail_so/detail_documents.dart';
import 'package:ziyu_seg/src/services/tracking_service.dart';
import 'package:ziyu_seg/src/services/upload_data_service.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'package:ziyu_seg/src/utils/permissions_utils.dart';
import 'package:ziyu_seg/src/utils/string_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ziyu_seg/src/models/navegation/trip_sections.dart';
import 'package:ziyu_seg/src/blocs/navegation/detail_so_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/so_list_tab_bloc.dart';
import 'package:ziyu_seg/src/repositories/navegation/route_repository.dart';
import 'package:ziyu_seg/src/components/modals/success_modal.dart';

import 'package:geolocator/geolocator.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geocoder/geocoder.dart';

import 'package:flushbar/flushbar.dart';

import 'fuel_charger_content.dart';
import 'fuel_modal_confirm_trip.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:ziyu_seg/src/repositories/navegation/trip_data_repository.dart';
import 'package:ziyu_seg/src/services/speech_service.dart';
import 'package:ziyu_seg/src/models/push_notification.dart';
import 'package:ziyu_seg/src/models/navegation/trip_alert.dart';
import 'package:ziyu_seg/src/repositories/navegation/trip_alert_repository.dart';
import 'package:ziyu_seg/src/repositories/device_repository.dart';
import 'package:ziyu_seg/src/repositories/navegation/trip_repository.dart';
import 'package:ziyu_seg/src/services/shared_preferences.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ziyu_seg/src/repositories/lecture/lecture_repository.dart';
import 'package:ziyu_seg/src/utils/file_utils.dart';

int tripPage = 0;
int tripSectionOrderId = 0;
// CameraPosition cameraInit;
String originTrip;
String finalTrip;
bool dropdownItem1 = true;
bool dropdownItem2 = true;
bool backAndroidButton2;
bool boolSoListBloc = false;
int indexTrip = 0;
int tripToRealize = 0;
bool boolNavigation = true;
bool boolAssignedRoute = false;
List<dynamic> listPoints;
Map geometry;
dynamic auxOrigin;
double distanciaToOrigin;
Timer timer;
Timer timerFinishFromNavigation;
int countGPS = 0;
double accuracyGPS = 0.0;
double velocity;
bool pressedCarga;
bool firstTimeNavigation;
bool onceOffRoute = false;
MapBoxOptions _navigationOption;
ServiceOrder activeSO;

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections()),
                ),
              ),
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw ErrorDefault("error");
      }
    });
  }
}

class HomeTabScreen extends StatefulWidget {
  final TabController tabController;
  final Key key;
  final Widget appBar;
  final Widget buttonBar;
  final VoidCallback showShadowAppBar;
  final VoidCallback hideShadowAppBar;

  HomeTabScreen(
    this.tabController,
    this.appBar,
    this.buttonBar, {
    this.key,
    this.hideShadowAppBar,
    this.showShadowAppBar,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeTabScreenState();
  }
}

class HomeTabScreenState extends State<HomeTabScreen>
    with WidgetsBindingObserver {
  bool firstRender = true;
  int countOptimization = 0;
  bool askedBatteryOptimizationParticular = false;
  bool disabledInitTripButton = false;
  final meterEndTextController = TextEditingController();
  HomeTabMainResponse mainData;
  List<HomeTabMainResponse> listMainData = [];
  StreamController<bool> _refreshScreenController;
  final homeTabBloc = HomeTabBloc();
  int aux;
  ValueNotifier<bool> finishFromNaviBool = ValueNotifier<bool>(false);

  GoogleMapController mapController;
  Position miposition;
  Future<Position> getCurrentLocation() async {
    if (miposition == null) {
      miposition = await Geolocator.getCurrentPosition();
    }
    return miposition;
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  // MapboxMapController controllerMap;

  int serviceIndexState;

  final _detailSOBloc = DetailSOBloc();
  final _soListTabBloc = SOListTabBloc();

  TextEditingController containerText = TextEditingController();
  TextEditingController stampText = TextEditingController();

  @override
  void initState() {
    super.initState();
    finishFromNaviBool.addListener(() async {
      if (finishFromNaviBool.value == true) {
        print("mike boton de finalizar con el cerrar");
        bool responseFinish =
            await modalConfirmStopTrip(isProgram: false, os: activeSO) ?? false;
        if (responseFinish) {
          _stopTripManual(activeSO, 0, showModalPOD: true);
          listMainData[serviceIndexState].tripSections[tripSectionOrderId - 1]
              ["date_finish"] = DateTime.now().toString();
          bool response = await _modalTripSection(
            TripSection(
              id: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["id"],
              nameSection: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["name"],
              order: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["order"],
              address: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["address"],
              longitude: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["longitude"],
              latitude: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["latitude"],
              status: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["status"],
              dateStart: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["date_start"],
              dateFinish: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["date_finish"],
              triad: listMainData[serviceIndexState]
                  .tripSections[tripSectionOrderId - 1]["triad"],
              serviceOrderId: listMainData[serviceIndexState].serviceOrder.id,
            ),
            true,
          );
        }
      }
    });
    WidgetsBinding.instance.addObserver(this);
    containerText = TextEditingController();
    stampText = TextEditingController();
    _refreshScreenController = StreamController<bool>();
    AppBloc.instance.updateRefreshScreenSink(_refreshScreenController.sink);
    homeTabBloc.initScreen();
    _soListTabBloc.getlistSO();
    _detailSOBloc.initState();
    boolNavigation = false;
    pressedCarga = true;
    firstTimeNavigation = true;
    _refreshScreenController.stream.listen((event) {
      homeTabBloc.getDriverStatus("refreshScreenController",
          updateFromServer: event == true, startTimer: false);
    });

    if (Platform.isIOS) {
      disabledInitTripButton = true;
    }
  }

  @override
  void dispose() {
    homeTabBloc.dispose();
    containerText.dispose();
    stampText.dispose();
    if (boolNavigation == false) {
      timer?.cancel();
    }
    finishFromNaviBool.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _refreshScreenController.close();
    _detailSOBloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstRender) {
      firstRender = false;
      syncroData(firstTime: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("mike map hemos vuelto resumed");
        // firstTimeNavigation = false;
        // onResumed();
        break;
      case AppLifecycleState.inactive:
        print("mike map hemos vuelto inactive");
        // onPaused();
        break;
      case AppLifecycleState.paused:
        print("mike map hemos vuelto inactive");
        // onInactive();
        break;
      case AppLifecycleState.detached:
        print("mike map hemos vuelto detached");
        // onDetached();
        break;
    }
  }

  Future<bool> askLocationAndPhonePermissions(BuildContext context,
      {showCancelButton = false, bool locationAlways = false}) async {
    try {
      final locationPermission = await permissionUtils.askAndRequestPermission(
          context: context,
          typesPermission: [
            PermissionsType.LOCATION_ALWAYS_TYPE,
            PermissionsType.PHONE_TYPE
          ],
          dismissible: showCancelButton);
      if (locationPermission) {
        return true;
      }
    } catch (e) {
      print("Error askingLocation: $e");
    }

    return false;
  }

  syncroData({bool firstTime}) async {
    UploadDataService.instance.uploadNosyncroData();
    if (Platform.isIOS) {
      return;
    }

    final permissions =
        await askLocationAndPhonePermissions(context, locationAlways: true);
    if (permissions) {
      await homeTabBloc.getDriverStatus("SYNCRO DATA HOME TAB",
          downloadedData: firstTime);
    }
  }

  Widget tripSectionScreen(HomeTabMainResponse mainData, int index) {
    final statusSo = mainData.serviceOrder?.status;
    final confirmAndInRoute = statusSo == ServiceOrder.CONFIRMED ||
        statusSo == ServiceOrder.IN_PROCESS ||
        statusSo == ServiceOrder.DELAYED;

    print("index en tripSectionScreen::::" + index.toString());
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                child: _tripSectionDraw(mainData),
                height: 125.6,
              ),
              Container(
                height: 30,
              ),
              if (mainData.addresses.length > 1)
                _tripSection(mainData, 1, index),
              if (mainData.addresses.length > 2)
                _tripSection(mainData, 2, index),
              if (mainData.addresses.length > 3)
                _tripSection(mainData, 3, index),
              Container(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    constraints:
                        BoxConstraints(minWidth: confirmAndInRoute ? 280 : 150),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.grey,
                        ),
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(25.0),
                      // ),
                      // color: Colors.grey,
                      onPressed: () async {
                        loadingScreen(context);
                        widget.showShadowAppBar();
                        AppBloc.instance.titleApp = "ZiYU";
                        await AppBloc.instance.refreshScreen("tramos");
                        setState(() {
                          print("refresca SO al volver en tramos");
                          print("tripPage:::: 11      ");
                          tripPage = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Volver",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    constraints:
                        BoxConstraints(maxWidth: confirmAndInRoute ? 0 : 150),
                    child: _buttonTrip(mainData, 0, index, backButton: false),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget navigationTrip(String initPoint, String finishPoint,
      HomeTabMainResponse mainData, int indexAddress, Widget _buttonTrip) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.bottomRight,
            // add your floating action button
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Transform.rotate(
                            angle: 90 * pi / 180,
                            child: PieChart(
                              PieChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                centerSpaceColor:
                                    Colors.blue[100].withOpacity(0.4),
                                sectionsSpace: 0,
                                centerSpaceRadius: 25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // CircleAvatar(
                  //     backgroundColor: Colors.black12,
                  //     radius: 30,
                  //     child: CircleAvatar(
                  //       backgroundColor: Colors.grey,
                  //       radius: 27,
                  //       child: CircleAvatar(
                  //         radius: 25,
                  //         backgroundColor: Colors.black12,
                  //         child: Align(
                  //             alignment: Alignment.center,
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: [
                  //                 Text(
                  //                   velocity != null
                  //                       ? velocity?.round().toString()
                  //                       : "0",
                  //                   style: TextStyle(
                  //                       fontSize: 20,
                  //                       fontWeight: FontWeight.bold,
                  //                       color: Colors.blue[200]),
                  //                 ),
                  //                 Text(
                  //                   "km/h",
                  //                   style: TextStyle(
                  //                       fontSize: 11,
                  //                       fontWeight: FontWeight.bold,
                  //                       color: Colors.blue[200]),
                  //                 ),
                  //               ],
                  //             )),
                  //       ),
                  //     )),
                  Container(
                    child: _buttonTrip,
                    width: 150,
                  )
                ],
              ),
            )),
        Align(
            alignment: Alignment.bottomLeft,
            // add your floating action button
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      FloatingActionButton(
                          heroTag: "Hero 4",
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            _modalLoadUnload(
                                "carga o descarga", indexAddress, mainData);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.truckRampBox,
                                size: 20,
                              ),
                              const FaIcon(
                                FontAwesomeIcons.truckMoving,
                                size: 20,
                              )
                            ],
                          )),
                      Container(
                        width: 10,
                      ),
                      RichText(
                        maxLines: 10,
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "CARGA/\nDESCARGA",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(height: 10),
                  Row(
                    children: [
                      FloatingActionButton(
                        heroTag: "Hero 5",
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          // await startNavegacionMapbox(mainData, );
                        },
                        child: const FaIcon(FontAwesomeIcons.locationArrow),
                      ),
                      Container(
                        width: 10,
                      ),
                      RichText(
                        maxLines: 10,
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "Navegación",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),

        /*Container(
          decoration:BoxDecoration(
            color: Color(CustomColor.white_container, ),
            border: Border.all(
              color: Color(CustomColor.grey_lower),
              width: 1.5
            ),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0)
            ),
          ),
          child: Text("hola"),
        )*/
        Column(
          children: [
            Stack(
              children: [
                if (dropdownItem1)
                  // IgnorePointer(
                  //   child: Container(
                  //     child: Opacity(
                  //       child: _tripSectionDraw(mainData, onMap: true),
                  //       opacity: 0.93,
                  //     ),
                  //     height: 125.6,
                  //   ),
                  // ),
                  if (dropdownItem1 == false)
                    IgnorePointer(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Opacity(
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            color: Colors.transparent,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                                onTap: () {},
                                splashColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(CustomColor.grey_low),
                                        width: 1.5),
                                    color: Color(CustomColor.grey_low),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Mandante: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  CustomColor.black_medium)),
                                        ),
                                        TextSpan(
                                          text: mainData.sku.principalClient,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  CustomColor.grey_medium)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          opacity: 0.93,
                        ),
                        height: 50.6,
                        width: MediaQuery.of(context).size.width * 7 / 8,
                      ),
                    )),
                Container(
                  width: (dropdownItem1)
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 7 / 8,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        // IconButton(
                        //   icon: Icon(
                        //     (dropdownItem1)
                        //         ? Icons.keyboard_arrow_right
                        //         : Icons.keyboard_arrow_down,
                        //     color: Colors.black,
                        //   ),
                        //   onPressed: () {
                        //     setState(() {
                        //       print(
                        //           "dropdownItem1::" + dropdownItem1.toString());
                        //       if (dropdownItem1) {
                        //         dropdownItem1 = false;
                        //       } else {
                        //         dropdownItem1 = true;
                        //       }
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                IgnorePointer(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: (dropdownItem2)
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width * 7 / 9,
                    constraints: BoxConstraints(minHeight: 60.5),
                    child: Opacity(
                      child: _infoOS(mainData, indexAddress, finishPoint),
                      opacity: 0.85,
                    ),
                  ),
                ),
                Container(
                  width: (dropdownItem2)
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 7 / 9,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            (dropdownItem2)
                                ? Icons.keyboard_arrow_right
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              print("prueba");
                              if (dropdownItem2) {
                                dropdownItem2 = false;
                              } else {
                                dropdownItem2 = true;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (accuracyGPS > 40)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Problemas con sus datos GPS, reconectando...",
                    style: TextStyle(color: Colors.red),
                  ),
                  CircularProgressIndicator(),
                ],
              ),
          ],
        )
      ],
    );
  }

  Future<void> startNavegacionMapbox(
      HomeTabMainResponse mainData, int indexinternalid) async {
    print("boolNavigation:::" + boolNavigation.toString());

    MapBoxNavigation.instance.setDefaultOptions(MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: false,
        enableFreeDriveMode: false,
        voiceInstructionsEnabled: false,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: false,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.metric,
        simulateRoute: false,
        language: "es"));
    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
    // MapBoxNavigation.instance.setDefaultOptions(_navigationOption);
    print("mike listmaindata::::::::: ${mainData.tripSections}");
    final data = await _getPointsRoute(mainData, indexinternalid);
    print("mike data de mainData:::::::: $data");
    var wayPoints = <WayPoint>[];
    if (data["listpoints"].length > 0) {
      wayPoints = data["listpoints"];
      onceOffRoute = true;
    } else {
      onceOffRoute = false;
      wayPoints.add(data["start"]);
      wayPoints.add(data["end"]);
    }

    print("mike listado de puntos ${wayPoints.length}");
    print("mike listado de puntos $wayPoints");
    await MapBoxNavigation.instance.startNavigation(wayPoints: wayPoints);
    MapBoxNavigation.instance.finishNavigation();
  }

  Future<bool> _modalLoadUnload(
      /*TripSection tripSection bool boolDialog,*/ String loadUnload,
      int indexAddress,
      HomeTabMainResponse mainData) async {
    AppBloc.instance.isModalPODOpen = true;
    dropdownValue = null;
    //final response = await homeTabBloc.saveSection(tripSection);
    bool allGood;
    final commentController = TextEditingController();
    if (true) {
      //response) {
      if (true) {
        //boolDialog) {
        return showDialog(
          context: context,
          builder: (context) {
            return Container(child: StatefulBuilder(
              builder: (context, StateSetter setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  title: Text("Confirmación de $loadUnload"),
                  content: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("¿Resultó todo bien?"),
                          Container(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FloatingActionButton(
                                elevation: 1,
                                backgroundColor: (allGood != null)
                                    ? (allGood)
                                        ? Color(CustomColor.green_medium)
                                        : Color(CustomColor.grey_low)
                                    : Color(CustomColor.grey_low),
                                child: Icon(
                                  FontAwesomeIcons.thumbsUp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    print("prueba");
                                    allGood = true;
                                  });
                                },
                              ),
                              Container(
                                width: 10,
                              ),
                              FloatingActionButton(
                                elevation: 1,
                                backgroundColor: (allGood != null)
                                    ? (!allGood)
                                        ? Colors.red
                                        : Color(CustomColor.grey_low)
                                    : Color(CustomColor.grey_low),
                                child: Icon(
                                  FontAwesomeIcons.thumbsDown,
                                ),
                                onPressed: () {
                                  setState(() {
                                    print("prueba");
                                    allGood = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (allGood != null)
                            if (!allGood)
                              //Continuar...
                              Container(
                                constraints: BoxConstraints(minHeight: 50),
                                child: dropDownButton(),
                              ),
                          Container(
                            height: 10,
                          ),
                          Container(
                            constraints: BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(CustomColor.grey_low),
                                  width: 1.5),
                              color: Color(CustomColor.grey_low),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: TextField(
                              maxLines: double.maxFinite.floor(),
                              style: TextStyle(fontSize: 12),
                              controller: commentController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Ingrese Comentarios "),
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Center(
                            child: Text("Confima que a las " +
                                DateTime.now().hour.toString() +
                                ":" +
                                (DateTime.now().minute < 10
                                    ? "0" + DateTime.now().minute.toString()
                                    : DateTime.now().minute.toString()) +
                                " hrs inició la $loadUnload"),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                decoration: BoxDecoration(
                                  color: Color(CustomColor.ziyu_color),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                child: DialogButton(
                                  color: Color(CustomColor.ziyu_color),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: Color(CustomColor.ziyu_color),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Confirmar",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Future.delayed(Duration(seconds: 3));
                                    await openSuccessModal(
                                        context, "Hito confirmado");
                                    Navigator.pop(context, true);
                                  },
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ));
          },
        );
      }
    }
  }

  Widget dropDownButton() {
    List<dynamic> rejectedtype = [];

    print("listMainData[0].operationaRejections::::" +
        listMainData[0].operationalRejections.toString());
    rejectedtype = listMainData[0].operationalRejections;
    print("rejectedtype::::" + rejectedtype.toString());
    //rejectedtype.addAll(listMainData[0].operationalRejections);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<dynamic>(
            isDense: true,
            value: dropdownValue,
            hint: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Selecciona el tipo de rechazo",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            style: const TextStyle(
                color: Color(CustomColor.black_low),
                fontSize: 14,
                fontWeight: FontWeight.bold),
            onChanged: (dynamic newValue) {
              setState(() {
                dropdownValue = newValue;
                print("value:::" + dropdownValue);
              });
            },
            items: rejectedtype.map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("serviceIndexState: $serviceIndexState");
    if (Platform.isIOS) {
      return ErrorDefault(
        "Servicio no disponible en el dispositivo actual",
        tryagain: false,
      );
    }

    return StreamBuilder(
      stream: homeTabBloc.userDataObserver,
      builder: (context, AsyncSnapshot<List<HomeTabMainResponse>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        listMainData = [];
        for (int i = 0; i < snapshot.data.length; i++) {
          if (snapshot.data[i].serviceOrder.statusName != "Terminada") {
            listMainData.add(snapshot.data[i]);
          }
        }
        print("tripPage $tripPage");
        print("listMainData.lenth:::::::::::::::: " +
            listMainData.length.toString());
        bool onTrip = false;
        //bool statusSo = true;
        for (int i = 0; i < listMainData.length; i++) {
          if (listMainData[i].serviceOrder.statusName != "Asignado" &&
              listMainData[i].serviceOrder.statusName != "En asignación" &&
              listMainData[i].serviceOrder.statusName != "Terminada") {
            onTrip = true;
            indexTrip = i;
            serviceIndexState = i;
          }
        }

        if (listMainData.length != 0) {
          if (listMainData[0].loading)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            if (tripPage == 1) {
              return ListView(
                children: [
                  tripSectionScreen(
                      listMainData[serviceIndexState], serviceIndexState),
                ],
              );
            }
            Widget widgetSelected;
            if (AppBloc.instance.showModalPOD) {
              AppBloc.instance.showModalPOD = false;
              widgetSelected = Transform.scale(
                  scale: 0.9,
                  child: _serviceAssignedContent(
                      listMainData[indexTrip], indexTrip,
                      boolNotShowingNumberTrips: true));
            } else {
              widgetSelected = _tripSectionDraw(
                listMainData[indexTrip],
              );
            }
            if (tripPage == 2) {
              print("boolSoListBloc::::" + boolSoListBloc.toString());
              if (boolSoListBloc) {
                boolSoListBloc = false;
                return DetailDocuments(
                  serviceOrder: listMainData[indexTrip].serviceOrder,
                  tabController: widget.tabController,
                  idSO: listMainData[indexTrip].serviceOrder.id,
                  detailSOBloc: _detailSOBloc,
                  boolHomeTab: true,
                  tripSectionOrderId: tripSectionOrderId,
                  soListTabBloc: _soListTabBloc,
                  widgetTitle: widgetSelected,
                );
              } else {
                return DetailDocuments(
                  serviceOrder: listMainData[indexTrip].serviceOrder,
                  tabController: widget.tabController,
                  idSO: listMainData[indexTrip].serviceOrder.id,
                  detailSOBloc: _detailSOBloc,
                  boolHomeTab: true,
                  tripSectionOrderId: tripSectionOrderId,
                  widgetTitle: widgetSelected,
                );
              }
            } else if (tripPage == 3) {
              print("tripSectionOrderId::::: " + tripSectionOrderId.toString());
              print("serviceIndexState::::: " + serviceIndexState.toString());
              print("listMainData::::::::" + listMainData.toString());
              print("listMainData::::::::[serviceIndexState]::::::::" +
                  listMainData[serviceIndexState].toString());
              print("listMainData::::::::[serviceIndexState][]::::::::" +
                  listMainData[serviceIndexState].serviceOrder.id.toString());
              String initTrip = "";
              print(tripSectionOrderId);
              if (tripSectionOrderId != 1)
                initTrip = listMainData[serviceIndexState]
                        .addresses[tripSectionOrderId - 2] +
                    ", " +
                    listMainData[serviceIndexState]
                        .tripSections[tripSectionOrderId - 2]["name"];

              String finishTrip = listMainData[serviceIndexState]
                      .addresses[tripSectionOrderId - 1]
                      .toString() +
                  ", " +
                  listMainData[serviceIndexState]
                      .tripSections[tripSectionOrderId - 1]["name"]
                      .toString();
              print("navigationTrip:::: serviceIndexState" +
                  tripSectionOrderId.toString());
              if (FlavorConfig.instance.values.domain.contains("plq")) {
                return navigationTrip(
                    initTrip,
                    finishTrip,
                    listMainData[serviceIndexState],
                    tripSectionOrderId - 1,
                    _buttonTrip(listMainData[serviceIndexState],
                        tripSectionOrderId - 1, serviceIndexState,
                        backButton: true));
              } else {
                return newNavigationTrip(context,
                    listMainData[serviceIndexState], tripSectionOrderId - 1);
              }
            } else {
              if (onTrip == false) {
                // print("pasa por onTrip == false");
                // print(
                //     "listMainData.length::::" + listMainData.length.toString());
                return ListView.builder(
                  itemCount: listMainData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Transform.scale(
                        scale: 1,
                        child: _getContentFromStatus(listMainData, index),
                      ),
                    );
                  },
                );
              } else {
                print("pasa por on trip== true");
                return ListView(
                  children: [
                    _getContentFromStatus(listMainData, indexTrip),
                  ],
                );
              }
            }
          }
        } else {
          // syncroData(firstTime: true);
          // return ErrorDefault(isFromServer
          //     ? "No tiene nuevos servicios"
          //     : "Revise su conexión a internet para visualizar sus servicios.");
          return _refreshPage(context);
        }
      },
    );
  }

  Widget _refreshPage(BuildContext context) {
    final bool isFromServer = homeTabBloc.responseIsFromServer();
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          maxLines: 10,
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: isFromServer
                    ? "No tiene nuevos servicios"
                    : "Revise su conexión a internet para visualizar sus servicios.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ElevatedButton(
          child: RichText(
            maxLines: 10,
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: "Actualizar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onPressed: () async {
            loadingScreen(context);
            await syncroData(firstTime: true);
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }

  Widget _getContentFromStatus(List<HomeTabMainResponse> mainData, int index) {
    Widget content = Container(
      child: Text("Hubo un error, comuniquese con el administrador."),
    );

    if (homeTabBloc.allTriad[index]["service_order"] != null &&
        homeTabBloc.allTriad[index]["service_order"].status !=
            ServiceOrder.CANCELLED &&
        homeTabBloc.allTriad[index]["service_order"].status !=
            ServiceOrder.FINISHED_NOT_VALID) {
      if (homeTabBloc?.allTriad[index]["triad"]?.fueling ?? false) {
        return FuelChargerContent(
          homeTabBloc: homeTabBloc,
          mainData: mainData[index],
          infoUser: _infoUser(mainData[index]),
          restartTripFunction: _restartTrip,
          tripButton: _tripButton(
            mainData[index],
            index,
            finishText: "Finalizar programa",
            initText: "Comenzar programa",
          ),
          fuelChargerInfo: mainData[index].fuelChargerInfo,
        );
      } else {
        content = _serviceAssignedContent(mainData[index], index);
      }
    } else
      content = _notAssignedContent(mainData[index]);
    var mainDataAux = mainData[index];
    if (index > 0 && !homeTabBloc.inTrip) {
      mainDataAux = null;
    }
    return _homeTabContent(content, mainDataAux);
  }

  Widget _homeTabContent(Widget content, HomeTabMainResponse mainData) {
    print("pasa por homeTabContent");
    if (mainData != null) {
      return RefreshIndicator(
        onRefresh: () async {
          await syncroData();

          return true;
        },
        child: Column(
          children: <Widget>[
            _infoUser(mainData),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: content,
            )
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await syncroData();

        return true;
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 0.5,
            color: Color(CustomColor.pastel_purple),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: content,
          )
        ],
      ),
    );
  }

  // Detalle CONDUCTOR
  Widget _infoUser(HomeTabMainResponse mainData) {
    int totalTrips = mainData.trips;
    // int totalStarts = 4;
    String vehicule = stringToPlate(mainData.triad?.plateVehicle ?? "");
    String trailer = stringToPlate(mainData.triad?.plateTrailer ?? "");

    return Container(
        //color: FlavorConfig.instance.color,

        padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
          color: FlavorConfig.instance.color,
        ),
        child: Transform.scale(
          scale: 1,
          child: Row(
            children: <Widget>[
              Container(width: 5.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _imageAvatar(mainData),
                ],
              ),
              Container(width: 10.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Hola, " + mainData.user?.name ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _startsUser({int starts = 4}) {
    int count = 0;
    var startsIcons = List<Widget>();
    var startSize = 17.0;
    var starFull = Icon(
      Icons.star,
      color: Colors.white,
      size: startSize,
    );
    var startEmpty = Icon(
      Icons.star,
      color: Colors.white,
      size: startSize,
    );

    while (count < 4) {
      if (count < starts) {
        startsIcons.add(starFull);
      } else {
        startsIcons.add(startEmpty);
      }

      count++;
    }

    return Row(
      children: startsIcons,
    );
  }

  Widget _imageAvatar(HomeTabMainResponse mainData) {
    String avatar = mainData.user?.avatarBase64 ?? "";
    final avatarFileExist = mainData.avatarExist ?? false;
    Widget avatarImg =
        Image.asset('assets/images/avatar_default_2.png', fit: BoxFit.contain);

    if (avatarFileExist) {
      final File avatarFile = mainData.user?.avatarFile;
      avatarImg = Image.file(avatarFile, fit: BoxFit.cover);
    } else if (avatar.isNotEmpty) {
      avatarImg = Image.memory(base64Decode(avatar), fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: () async {
        loadingScreen(context);
        final image =
            await selectImageSourceAlert(context, addingResumedObserv: false);
        final imageCompress = await compressAndSaveFile(image,
            minHeight: 720, minWidth: 960, quality: 60);
        if (image != null) {
          final imageChanged = await homeTabBloc.changeImage(imageCompress);
          print("------------------------- IMAGE CHANGED: $imageChanged");

          setState(() {
            avatarImg = Image.file(image);
          });

          await homeTabBloc.getDriverStatus("IMAGE CHANGE HOME TAB",
              updateFromServer: false);
          AppBloc.instance.activeResumedObserver();
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.0),
        width: 40.0,
        height: 40.0,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(45.0), child: avatarImg),
      ),
    );
  }

  // Orden de servicio ASIGNADA
  Widget _serviceAssignedContent(HomeTabMainResponse mainData, int index,
      {boolNotShowingNumberTrips = false}) {
    print("pasa por serviceAssignedContent");
    final statusSo = mainData.serviceOrder?.status;
    final confirm = statusSo == ServiceOrder.CONFIRMED;
    tripToRealize = 0;
    print("index==============" + index.toString());
    print("homeTabBloc.inTrip:::::" + homeTabBloc.inTrip.toString());
    for (int i = 0; i < listMainData.length; i++) {
      if (listMainData[i].serviceOrder.statusName != "Terminada") {
        tripToRealize++;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (index == 0 && boolNotShowingNumberTrips == false)
          Container(height: confirm ? 20.0 : 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if ((index == 0 || homeTabBloc.inTrip) &&
                boolNotShowingNumberTrips == false)
              RichText(
                maxLines: 10,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      // text: "Tienes " +
                      //     tripToRealize.toString() +
                      //     " viajes por realizar",
                      text: "Viajes Asignados",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Color(CustomColor.black_medium)),
                    ),
                  ],
                ),
              ),
            !confirm
                ? Container()
                : IconButton(
                    onPressed: _restartTrip,
                    icon: Icon(
                      Icons.refresh,
                      size: 40.0,
                    ))
          ],
        ),
        Container(height: confirm ? 10.0 : 20.0),
        Material(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          elevation: 5,
          child: _serviceRoute(
            SvgPicture.asset(
              'assets/icons/truck.svg',
              color: Color(CustomColor.black_low),
              height: 30.0,
            ),
            mainData,
            _tripButton(mainData, index),
            onPressed: () async {
              print("pasa por onPressed para tripPage = 1");
              widget.showShadowAppBar();
              loadingScreen(context);
              setState(() {
                AppBloc.instance.titleApp =
                    listMainData[index].serviceOrder.id.toString();
                tripPage = 1;
                serviceIndexState = index;
              });
              await _detailSOBloc.getData(mainData.serviceOrder.id);
              Navigator.pop(context);
              /*Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (context) => tripSectionScreen(
                    mainData,
                  ),
                ),
              );*/
            },
          ),
        ),
        Material(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          elevation: 5,
          child: _serviceData(
              SvgPicture.asset(
                'assets/icons/truck.svg',
                color: Color(CustomColor.black_low),
                height: 30.0,
              ),
              mainData,
              index,
              _tripButton(mainData, index),
              boolNotShowingNumberTrips),
        ),
        Container(height: 20.0),
      ],
    );
  }

  Widget _tripButton(HomeTabMainResponse mainData, int index,
      {String finishText = "Finalizar", String initText = "Comenzar"}) {
    if (mainData.serviceOrder.statusName != "Asignado" ||
        mainData.serviceOrder.statusName != "En asignación" ||
        mainData.serviceOrder.statusName != "Terminada" ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "Asignado") ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "En asignación") ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "Terminada")) {
      print("pasa por En asignacionnn");
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              homeTabBloc.inTrip
                  ? Color(CustomColor.brown_light)
                  : FlavorConfig.instance.color,
            ),
          ),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(25.0),
          // ),
          // color: homeTabBloc.inTrip
          //     ? Color(CustomColor.brown_light)
          //     : FlavorConfig.instance.color,
          onPressed: disabledInitTripButton
              ? null
              : () async {
                  if (Platform.isIOS) {
                    modalErrorDefault(
                        "No es posible iniciar un viaje en el dispositivo actual.");
                    return;
                  }

                  bool showPODModal = true;
                  print("homeTabBloc?.allTriad: ${homeTabBloc?.allTriad}");
                  bool isProgram =
                      homeTabBloc?.allTriad[index]["triad"]?.fueling ?? false;
                  // Detener viaje
                  if (homeTabBloc.inTrip && mainData.containerId != null) {
                    bool response;
                    if (isProgram) {
                      response = await _modalPOD() ?? false;
                      showPODModal = false;
                    } else {
                      response =
                          await modalConfirmStopTrip(isProgram: isProgram) ??
                              false;
                    }

                    if (response) {
                      _stopTripManual(mainData.serviceOrder, 0,
                          showModalPOD: showPODModal);
                      firstTimeNavigation = false;
                    }
                  } else if (homeTabBloc.inTrip &&
                      mainData.containerId == null) {
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 4),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message:
                          "Debe ingresar el contenedor antes de finalizar el viaje",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context);
                  } else if (homeTabBloc.inTrip != true &&
                      mainData.containerId == null) {
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 4),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message:
                          "Recuerde ingresar el contenedor antes de finalizar el viaje",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context).then((value) => _initTrip(index,
                        requestBOP: mainData.requestBatteryOptimization));
                  } else {
                    _initTrip(index,
                        requestBOP: mainData.requestBatteryOptimization);
                  }
                },

          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: homeTabBloc.inTrip ? finishText : initText,
                    style: TextStyle(fontSize: 16.0, color: Colors.white))
              ],
            ),
          ),
        ),
      );
    } else {
      print("pasa por En asignacion::: no");
      return SizedBox(
        height: 10,
      );
    }
  }

  Widget _tripButton2(
    HomeTabMainResponse mainData,
    int indexAddress, {
    String finishText = "Finalizar",
    String initText = "Comenzar",
    bool backButton = false,
  }) {
    String finalTextButton;

    if (mainData.serviceOrder.statusName != "En asignación" ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "En asignación") ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "Terminada")) {
      bool finishTripSection = homeTabBloc.inTrip;
      if (mainData.tripSections[indexAddress]["date_start"] == null) {
        finishTripSection = false;
      }
      if (finishTripSection == true) {
        finalTextButton = finishText;
      } else {
        finalTextButton = initText;
      }
      print("pasa por trip");
      if ((backButton == false &&
              homeTabBloc.inTrip == true &&
              mainData.tripSections[indexAddress]["date_start"] == null) ||
          (backButton == true &&
              mainData.tripSections[indexAddress]["date_start"] != null)) {
        return ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              finishTripSection
                  ? Color(CustomColor.brown_light)
                  : FlavorConfig.instance.color,
            ),
          ),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(25.0),
          // ),
          // color: finishTripSection
          //     ? Color(CustomColor.brown_light)
          //     : FlavorConfig.instance.color,
          onPressed: disabledInitTripButton
              ? null
              : () async {
                  if (Platform.isIOS) {
                    modalErrorDefault(
                        "No es posible iniciar un viaje en el dispositivo actual.");
                    return;
                  }

                  bool showPODModal = true;
                  bool isProgram =
                      homeTabBloc?.allTriad[0]["triad"]?.fueling ?? false;
                  bool response;
                  bool chargeON = true;
                  // Detener viaje
                  if (showPODModal) {
                    print("pasa por aca aunque crei que no");
                    print("X");
                    if (isProgram) {
                      response = await _modalPOD() ?? false;
                      showPODModal = false;
                    } else {
                      if (true)
                        // if (mainData.tripSections[indexAddress]
                        //             ["operational_date"] !=
                        //         null ||
                        //     tripPage == 1)
                        response = await modalConfirmStopSection(
                                isProgram: isProgram, text: finalTextButton) ??
                            false;
                      else {
                        response = false;
                        chargeON = false;
                        Flushbar(
                          icon: Icon(Icons.clear),
                          duration: Duration(seconds: 4),
                          onTap: (flushbar) {
                            Navigator.pop(context);
                          },
                          message:
                              "Debe ingresar carga o descarga antes de finalizar el tramo",
                          margin: EdgeInsets.all(8),
                          borderRadius: 8,
                          backgroundColor: Colors.blueGrey[500],
                        ).show(context);
                      }
                    }
                    print("response____" + response.toString());
                    if (response) {
                      if (finishTripSection == false) {
                        print("entra aca por que finishTripSection = false");
                        mainData.tripSections[indexAddress]["date_start"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);
                        response = await _modalTripSection(
                            TripSection(
                              id: mainData.tripSections[indexAddress]["id"],
                              nameSection: mainData.tripSections[indexAddress]
                                  ["name"],
                              order: mainData.tripSections[indexAddress]
                                  ["order"],
                              address: mainData.tripSections[indexAddress]
                                  ["address"],
                              longitude: mainData.tripSections[indexAddress]
                                  ["longitude"],
                              latitude: mainData.tripSections[indexAddress]
                                  ["latitude"],
                              status: mainData.tripSections[indexAddress]
                                  ["status"],
                              dateStart: mainData.tripSections[indexAddress]
                                  ["date_start"],
                              dateFinish: mainData.tripSections[indexAddress]
                                  ["date_finish"],
                              triad: mainData.tripSections[indexAddress]
                                  ["triad"],
                              serviceOrderId: mainData.serviceOrder.id,
                            ),
                            true);
                        await _detailSOBloc.getData(mainData.serviceOrder.id);
                      } else {
                        print("entra aca por que finishTripSection = true");
                        mainData.tripSections[indexAddress]["date_finish"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);
                        print("[operational_date]:::" +
                            mainData.tripSections[indexAddress]
                                    ["operational_date"]
                                .toString());
                        if (true) {
                          // if (mainData.tripSections[indexAddress]
                          //         ["operational_date"] !=
                          //     null) {
                          response = await _modalTripSection(
                              TripSection(
                                id: mainData.tripSections[indexAddress]["id"],
                                nameSection: mainData.tripSections[indexAddress]
                                    ["name"],
                                order: mainData.tripSections[indexAddress]
                                    ["order"],
                                address: mainData.tripSections[indexAddress]
                                    ["address"],
                                longitude: mainData.tripSections[indexAddress]
                                    ["longitude"],
                                latitude: mainData.tripSections[indexAddress]
                                    ["latitude"],
                                status: mainData.tripSections[indexAddress]
                                    ["status"],
                                dateStart: mainData.tripSections[indexAddress]
                                    ["date_start"],
                                dateFinish: mainData.tripSections[indexAddress]
                                    ["date_finish"],
                                triad: mainData.tripSections[indexAddress]
                                    ["triad"],
                                serviceOrderId: mainData.serviceOrder.id,
                              ),
                              true);
                          await _detailSOBloc.getData(mainData.serviceOrder.id);
                        } else {
                          response = false;
                          chargeON = true;
                          Flushbar(
                            icon: Icon(Icons.clear),
                            duration: Duration(seconds: 4),
                            onTap: (flushbar) {
                              Navigator.pop(context);
                            },
                            message:
                                "Debe ingresar carga o descarga antes de finalizar el tramo",
                            margin: EdgeInsets.all(8),
                            borderRadius: 8,
                            backgroundColor: Colors.blueGrey[500],
                          ).show(context);
                        }
                      }
                      print("tripPage::::" + tripPage.toString());
                      loadingScreen(context);
                      if (FlavorConfig.instance.values.domain
                          .contains("segmentado")) if (tripPage == 1) {
                        setState(() {
                          tripPage = 3;
                          tripSectionOrderId = indexAddress + 1;
                        });
                      } else if (tripPage == 3 && chargeON == true) {
                        setState(() {
                          tripPage = 1;
                          timer?.cancel();
                        });
                        await _detailSOBloc.getData(mainData.serviceOrder.id);
                      }
                      Navigator.pop(context);
                    }
                  } else {
                    _initTrip(0,
                        requestBOP: mainData.requestBatteryOptimization);
                  }

                  if (finishTripSection && backButton == true && response) {
                    //tripPage = 2;
                    tripSectionOrderId = indexAddress + 1;
                    boolSoListBloc = true;

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 500,
                              child: DetailDocuments(
                                serviceOrder: mainData.serviceOrder,
                                tabController: widget.tabController,
                                idSO: mainData.serviceOrder.id,
                                detailSOBloc: _detailSOBloc,
                                boolHomeTab: true,
                                tripSectionOrderId: tripSectionOrderId,
                                soListTabBloc: _soListTabBloc,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  loadingScreen(context);
                  await _detailSOBloc.getData(mainData.serviceOrder.id);
                  Navigator.pop(context);
                },
          child: FittedBox(
            child: Text(finishTripSection ? finishText : initText,
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return SizedBox(
        height: 10,
      );
    }
  }

  Future _containerServiceAlert(HomeTabMainResponse mainData) async {
    String validateContainerFormat2() {
      return "El contenedor debe incluir 7 números después de 4 letras. \n Ej: ABCD1234567";
    }

    print("mainData.serviceOrder.id:::" + mainData.serviceOrder.id.toString());
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text("Agregar contenedor"),
              content: Container(
                constraints: BoxConstraints(maxHeight: 130),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxHeight: 40),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(CustomColor.grey_low), width: 1.5),
                          color: Color(CustomColor.grey_low),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: TextField(
                          maxLines: double.maxFinite.floor(),
                          style: TextStyle(fontSize: 14),
                          controller: containerText,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Contenedor: "),
                        ),
                      ),
                      Text(
                        validateContainerFormat2(),
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      ElevatedButton(
                        child: Text("Aceptar"),
                        onPressed: () async {
                          String rejectContainer;
                          containerText.text =
                              containerText.text.trim().replaceAll(" ", "");
                          if (containerText.text.length > 4) {
                            final letters = containerText.text.substring(0, 3);
                            final numbers = containerText.text.substring(4);

                            for (final letter in letters.split("")) {
                              if (!letter.contains(RegExp(r'[a-zA-Z]'))) {
                                rejectContainer =
                                    "El contenedor debe contener 7 números despues de 4 letras.";
                              }
                            }

                            for (final number in numbers.split("")) {
                              if (int.tryParse(number) == null) {
                                rejectContainer =
                                    "El contenedor debe contener 7 números despues de 4 letras.";
                              }
                            }
                          }

                          if (rejectContainer == null &&
                              containerText.text.length == 11) {
                            loadingScreen(context);
                            print("Se debe actualizar en backend");

                            print("containerText:::" + containerText.text);
                            await homeTabBloc.saveContainer(
                                mainData.serviceOrder, containerText.text);
                            await homeTabBloc.getDriverStatus(
                                "refreshScreenController",
                                updateFromServer: true,
                                startTimer: false);
                            containerText.text = "";
                            stampText.text = "";
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            rejectContainer =
                                "El contenedor debe contener 7 números despues de 4 letras.";
                            if (containerText.text.length > 11) {
                              rejectContainer =
                                  "Tiene más de 11 caracteres alfanuméricos. Confirmar contenedor.";
                            }
                            Flushbar(
                              icon: Icon(Icons.clear),
                              duration: Duration(seconds: 4),
                              onTap: (flushbar) {
                                Navigator.pop(context);
                              },
                              message: rejectContainer,
                              margin: EdgeInsets.all(8),
                              borderRadius: 8,
                              backgroundColor: Colors.blueGrey[500],
                            ).show(context);
                          }
                        },
                      ),
                    ]),
              ));
        });
  }

  Widget infoServiceData() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color(CustomColor.pastel_purple),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/phone.svg',
              height: 15.0,
            ),
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("TELÉFONO", style: TextStyle(fontSize: 13.0)),
              Text("BODEGA", style: TextStyle(fontSize: 13.0))
            ],
          )),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color(CustomColor.pastel_purple),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/envelope.svg',
              height: 15.0,
            ),
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("CONTACTO", style: TextStyle(fontSize: 13.0)),
              Text("BODEGA", style: TextStyle(fontSize: 13.0))
            ],
          )),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color(CustomColor.pastel_purple),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/signo-interrogacion.svg',
              height: 25.0,
            ),
          ),
          Flexible(
            child: Text("AYUDA", style: TextStyle(fontSize: 13.0)),
          ),
        ],
      ),
    );
  }

  Widget _serviceElementData(String title, String subtitle, Widget icon,
      {Widget subtituleAditional, Widget otherLine, Function() onPressed}) {
    Widget aditionalsubtitule;
    if (subtituleAditional != null) {
      aditionalsubtitule = Row(
        children: <Widget>[Text(" - "), subtituleAditional],
      );
    }

    return Container(
        color: Color(CustomColor.white_container),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                onTap: onPressed,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color(CustomColor.grey_lower), width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      icon,
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(CustomColor.black_medium)),
                                    ))
                                  ],
                                ),
                                if (!emptyString(subtitle))
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          subtitle,
                                          style: TextStyle(
                                              color: Color(
                                                  CustomColor.black_medium)),
                                        ),
                                      ),
                                      aditionalsubtitule ?? SizedBox()
                                    ],
                                  ),
                                if (otherLine != null) otherLine ?? SizedBox()
                              ],
                            )),
                      )
                    ],
                  ),
                ))));
  }

  Widget _serviceRoute(
      Widget icon, HomeTabMainResponse mainData, Widget tripButton,
      {Function() onPressed}) {
    var sku = mainData.service.name.split('-');
    int countSkus = 0;
    if (mainData.serviceOrder.serviceModel != null &&
        mainData.serviceOrder.serviceModel != {}) {
      if (mainData.serviceOrder.serviceModel["sku_obj"] != null) {
        if (mainData.serviceOrder.serviceModel["sku_obj"]["skus"].length != 0) {
          countSkus =
              mainData.serviceOrder.serviceModel["sku_obj"]["skus"].length + 1;
        } else {
          countSkus = 2;
        }
      }
    }
    var addresses = sku.sublist(sku.length - countSkus);
    var skuNameList = sku.sublist(sku.length - countSkus).join(' -> ');
    var skuName = skuNameList.toString();
    if (FlavorConfig.instance.values.domain.contains("plq")) {
      List skuPlq = mainData.service.name.split(' - ');
      sku = skuPlq;
      print("skuPlq[0].split).last();:::" + sku.toString());
      addresses = sku.sublist(0);
      skuNameList = sku.sublist(0).join(', ');
      skuName = skuNameList.toString();
    }
    print("skuName:::" + skuName);
    print("addresses:::::" + addresses.toString());

    var numberTrip;
    if (mainData.addresses.length == 1) {
      numberTrip = FittedBox(
          child: Icon(
        Icons.looks_one,
        color: Color(
          CustomColor.white_container,
        ),
      ));
    } else if (mainData.addresses.length == 2) {
      numberTrip = FittedBox(
          child: Icon(Icons.looks_two,
              color: Color(
                CustomColor.white_container,
              )));
    } else {
      numberTrip = FittedBox(
          child: Icon(Icons.looks_3,
              color: Color(
                CustomColor.white_container,
              )));
    }
    return Container(
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                // onTap: onPressed,
                splashColor: (mainData.serviceOrder.statusName != "Terminada")
                    ? Color(CustomColor.ziyu_color)
                    : Color(CustomColor.black_low),
                child: Container(
                  decoration: BoxDecoration(
                    color: (mainData.serviceOrder.statusName != "Terminada" &&
                            mainData.serviceOrder.statusName !=
                                "Terminada no válida")
                        ? Color(CustomColor.ziyu_color)
                        : Color(CustomColor.grey_medium_2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    numberTrip,
                                    Container(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          skuName,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  CustomColor.white_container)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ))));
  }

  Widget _tripInfoContainer(HomeTabMainResponse mainData) {
    final statusSo = mainData.serviceOrder?.status;
    final confirm = statusSo == ServiceOrder.CONFIRMED;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (mainData.sku.principalClient != null &&
            mainData.sku.principalClient != "")
          Flexible(
            child: RichText(
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Mandante: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_medium)),
                  ),
                  TextSpan(
                    text: mainData.sku.principalClient,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.grey_medium)),
                  ),
                ],
              ),
            ),
          ),
        Flexible(
          child: RichText(
            maxLines: 15,
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "Cliente: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(CustomColor.black_medium)),
                ),
                TextSpan(
                  text: mainData.clientName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(CustomColor.grey_medium)),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: mainData.containerId != null ? 2 : 0,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: RichText(
                maxLines: 10,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text: "Contenedor: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: mainData.containerId != null
                          ? mainData.containerId.toString()
                          : "Por confirmar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_low)),
                    )
                  ],
                ),
              ),
            ),
            if (mainData.containerId == null && tripPage != 3)
              Container(
                constraints: BoxConstraints(maxWidth: 23, maxHeight: 23),
                child: FloatingActionButton.extended(
                  heroTag: "Hero 6",
                  label: Icon(Icons.edit),
                  onPressed: () {
                    print("pasa por pagina trip, cambiar nombre contenedor");
                    _containerServiceAlert(mainData);
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
        Container(
          height: 2,
        ),
        Row(
          children: [
            /*FittedBox(
            child:Text("Patente: ",
              style: TextStyle(fontWeight: FontWeight.bold,
                color: Color(CustomColor.black_medium)),
              ),
          ),
          FittedBox(
            child:Text(mainData.triad.plateVehicle.toString(),
              style: TextStyle(fontWeight: FontWeight.bold,
                color: Color(CustomColor.grey_medium)),
              ),
          ),*/
            FittedBox(
              child: Text(
                "Estado: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(CustomColor.black_medium)),
              ),
            ),
            FittedBox(
              child: Row(
                children: [
                  FittedBox(
                    child: Text(
                      mainData.serviceOrder?.statusName ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.grey_medium)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, top: 4.0),
                    height: 12.0,
                    width: 12.0,
                    decoration: BoxDecoration(
                      color: (mainData.serviceOrder?.status ==
                                  ServiceOrder.IN_PROCESS ||
                              mainData.serviceOrder?.status ==
                                  ServiceOrder.DELAYED)
                          ? Color(CustomColor.green_medium)
                          : Colors.yellow[600],
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  //WIDGET MALO, A CORREGIR
  /*Widget dropdownWidget(Widget dropdownItem, double opacity){
    int indexaux;
    String dropValue; 
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
      isDense: true,
      value: dropValue,
      hint: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Select Data",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      style: const TextStyle(
          color: Color(CustomColor.black_low), 
          fontSize: 16,
          fontWeight: FontWeight.bold),
      onChanged: (String newValue) {
        setState(() {
          dropValue = newValue;
        });
      },
      items: list.map<DropdownMenuItem<String>>((dynamic value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Stack(
                children: [
                  IgnorePointer(
                    child: Container(
                      child: Opacity(child: dropdownItem,  opacity: opacity,),
                      height: 125.6,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white,), 
                          onPressed: () {
                            print("prueba");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        );
      }).toList(),
    ),
    );
  }*/

  Widget _tripSectionDraw(HomeTabMainResponse mainData, {onMap = false}) {
    int touchedIndex = -1;
    int finishTrip = 0;
    for (int i = mainData.tripSections.length - 1; i >= 0; i--) {
      if (mainData.tripSections[i]["date_finish"] != null) {
        finishTrip = i + 1;
        break;
      }
    }

    List<PieChartSectionData> showingSections1Sections() {
      return List.generate(3, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 20.0 : 7.0;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: finishTrip > 0
                  ? ColorsCustom.ziyu_color
                  : Colors
                      .transparent, //const Color(0xff0293ee) : ColorsCustom.ziyu_color,
              value: 0,
              showTitle: false,
              radius: radius,
            );
          case 1:
            return PieChartSectionData(
              color: finishTrip > 1
                  ? ColorsCustom.ziyu_color
                  : Colors
                      .transparent, //const Color(0xff0293ee) : ColorsCustom.ziyu_color,
              value: 100,
              showTitle: false,
              radius: radius,
            );
          default:
            return PieChartSectionData(
              color: finishTrip == 0
                  ? ColorsCustom.ziyu_color
                  : Colors
                      .transparent, //const Color(0xff0293ee) : ColorsCustom.ziyu_color,
              value: 0,
              showTitle: false,
              radius: radius,
            );
        }
      });
    }

    List<PieChartSectionData> showingSections3Sections() {
      return List.generate(3, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 20.0 : 7.0;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: finishTrip > 2
                  ? ColorsCustom.ziyu_color
                  : Colors
                      .transparent, //const Color(0xff0293ee) : ColorsCustom.ziyu_color,
              value: 34,
              showTitle: false,
              radius: radius,
            );
          case 1:
            return PieChartSectionData(
              color: finishTrip > 3
                  ? ColorsCustom.ziyu_color
                  : Colors.transparent, //const Color(0xfff8b250),
              value: 33,
              showTitle: false,
              radius: radius,
            );
          case 2:
            return PieChartSectionData(
              color: finishTrip > 1
                  ? ColorsCustom.ziyu_color
                  : Colors.transparent, //const Color(0xff845bef),
              value: 33,
              showTitle: false,
              radius: radius,
            );
          default:
            throw ErrorDefault("error");
        }
      });
    }

    List<PieChartSectionData> showingSections2Sections() {
      return List.generate(2, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 20.0 : 7.0;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: finishTrip > 2
                  ? ColorsCustom.ziyu_color
                  : Colors
                      .transparent, //const Color(0xff0293ee) : ColorsCustom.ziyu_color,
              value: 50,
              showTitle: false,
              radius: radius,
            );
          case 1:
            return PieChartSectionData(
              color: finishTrip > 1
                  ? ColorsCustom.ziyu_color
                  : Colors.transparent, //const Color(0xfff8b250),
              value: 50,
              showTitle: false,
              radius: radius,
            );
          default:
            throw ErrorDefault("error");
        }
      });
    }

    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                onTap: () {},
                splashColor: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color(CustomColor.grey_low), width: 1.5),
                      color: Color(CustomColor.grey_low),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _tripInfoContainer(mainData),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: IgnorePointer(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  height: 55,
                                  width: 55,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Transform.rotate(
                                          angle: 90 * pi / 180,
                                          child: PieChart(
                                            PieChartData(
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                centerSpaceColor: Colors
                                                    .blue[100]
                                                    .withOpacity(0.4),
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 25,
                                                sections: mainData
                                                            .addresses.length ==
                                                        4
                                                    ? showingSections3Sections()
                                                    : mainData.addresses
                                                                .length ==
                                                            3
                                                        ? showingSections2Sections()
                                                        : showingSections1Sections()),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: RichText(
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: ((finishTrip > 0
                                                            ? finishTrip - 1
                                                            : finishTrip) *
                                                        100 /
                                                        (mainData.addresses
                                                                .length -
                                                            1))
                                                    .round()
                                                    .toString() +
                                                "%",
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[300]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 5),
                                Flexible(
                                  //transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
                                  child: RichText(
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: "TRAMO " +
                                          (finishTrip > 0
                                                  ? finishTrip - 1
                                                  : finishTrip)
                                              .toString() +
                                          " DE " +
                                          (mainData.addresses.length - 1)
                                              .toString() +
                                          " FINALIZADO",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                          color:
                                              Color(CustomColor.black_medium)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (onMap)
                          Expanded(
                            flex: 1,
                            child: Container(),
                          )
                      ],
                    )))));
  }

  Widget _infoOS(
      HomeTabMainResponse mainData, int indexAddress, String finishPoint) {
    print("dropdownItem2:::" + dropdownItem2.toString());
    return Container(
        padding: const EdgeInsets.all(10.0),
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                onTap: () {},
                splashColor: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Color(CustomColor.ziyu_color), width: 1.5),
                      color: Color(CustomColor.ziyu_color),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        if (dropdownItem2)
                          RichText(
                            maxLines: 10,
                            text: TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                    text: "Contenedor: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: mainData.containerId != null
                                      ? mainData.containerId.toString()
                                      : "POR CONFIRMAR",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (dropdownItem2)
                          RichText(
                            maxLines: 10,
                            text: TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                    text: "Cliente: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: mainData.clientName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              ],
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: RichText(
                                maxLines: 10,
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Origen: ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: indexAddress == 0
                                          ? "Tu ubicación"
                                          : mainData.tripSections[
                                              indexAddress - 1]["name"],
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    child: RichText(
                                      maxLines: 10,
                                      text: TextSpan(
                                        // Note: Styles for TextSpans must be explicitly defined.
                                        // Child text spans will inherit styles from parent
                                        style: const TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: dropdownItem2
                                                ? "- - - - - - - - - - - - - - - - - -"
                                                : "- - - - - - - - - - - - -",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.topCenter,
                                  ),
                                  Align(
                                    child: Icon(Icons.circle,
                                        size: 14, color: Colors.white),
                                    alignment: Alignment.topCenter,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: RichText(
                                maxLines: 10,
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Destino: ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: mainData.tripSections[indexAddress]
                                          ["name"],
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            )
                          ],
                        ),
                        if (dropdownItem2)
                          Container(
                            height: 10,
                          ),
                        if (dropdownItem2)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                maxLines: 10,
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Presentación: ",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                maxLines: 10,
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: mainData.addressesTime[indexAddress]
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (dropdownItem2)
                          Container(
                            height: 5,
                          ),
                        if (dropdownItem2)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // RichText(
                              //   maxLines: 10,
                              //   text: TextSpan(
                              //     // Note: Styles for TextSpans must be explicitly defined.
                              //     // Child text spans will inherit styles from parent
                              //     style: const TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.white,
                              //     ),
                              //     children: [
                              //       TextSpan(
                              //         text: "Dirección: ",
                              //         style: TextStyle(
                              //             color: Colors.white, fontSize: 17),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // Expanded(
                              //   child: RichText(
                              //     maxLines: 10,
                              //     text: TextSpan(
                              //       // Note: Styles for TextSpans must be explicitly defined.
                              //       // Child text spans will inherit styles from parent
                              //       style: const TextStyle(
                              //         fontSize: 14.0,
                              //         color: Colors.white,
                              //       ),
                              //       children: [
                              //         TextSpan(
                              //           text: finishPoint,
                              //           style: TextStyle(
                              //               color: Colors.white, fontSize: 17),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                      ],
                    )))));
  }

  Widget _buttonTrip(HomeTabMainResponse mainData, int indexAddress, int index,
      {String finishText = "Finalizar",
      String initText = "Comenzar",
      bool backButton = false}) {
    DateTime today = DateTime.now();
    print("mainData.deliveryDate:::" + mainData.deliveryDate.toString());
    DateTime today2 = today
        .subtract(Duration(
            hours: today.hour, minutes: today.minute, seconds: today.second))
        .add(Duration(hours: 23, minutes: 59, seconds: 59));
    print("dateTime prueba: " + today2.toString());
    String auxDeliveryDate;
    if (FlavorConfig.instance.values.domain.contains("plq")) {
      auxDeliveryDate = mainData.deliveryDate;
    } else {
      auxDeliveryDate = mainData.deliveryDate
          .split("|")[0]
          .split("-")
          .reversed
          .join("-")
          .replaceAll(" ", "");
    }

    DateTime deliveryDate = DateTime.parse(auxDeliveryDate);
    print("deliveryDate::::" + deliveryDate.toString());
    if (today2.isAfter(deliveryDate)) {
      print(
          "mainData.serviceOrder.id::::" + mainData.serviceOrder.id.toString());
      if (FlavorConfig.instance.values.domain.contains("plq") ||
          FlavorConfig.instance.values.domain.contains("preprod.ziyu")) {
        return _tripButton(mainData, indexAddress);
      } else if (indexAddress == 0) {
        print("pasa por boton 1");
        if (mainData.tripSections[indexAddress]["date_finish"] == null) {
          return _buttonTripSection(mainData, indexAddress, index,
              backButton: backButton);
        } else {
          return Container();
        }
      } else if (mainData.tripSections[mainData.tripSections.length - 1]
                  ["date_start"] !=
              null &&
          indexAddress == mainData.tripSections.length - 1) {
        print("pasa por boton 2");
        return _buttonTripSection(mainData, indexAddress, index,
            backButton: backButton);
      } else if (mainData.tripSections[indexAddress - 1]["date_start"] !=
              null &&
          mainData.tripSections[indexAddress - 1]["date_finish"] != null &&
          mainData.tripSections[indexAddress]["date_finish"] == null) {
        print("pasa por boton 3");
        return _tripButton2(mainData, indexAddress, backButton: backButton);
      } else {
        print("pasa por boton 4");
        return Container();
      }
    } else {
      if (FlavorConfig.instance.values.domain.contains("plq") ||
          FlavorConfig.instance.values.domain.contains("preprod.ziyu")) {
        return IgnorePointer(
          child: Opacity(
            child: _tripButton(mainData, indexAddress),
            opacity: 0.2,
          ),
        );
      } else {
        return IgnorePointer(
          child: Opacity(
            child: _buttonTripSection(mainData, indexAddress, index,
                backButton: backButton),
            opacity: 0.2,
          ),
        );
      }
    }
  }

  Widget _buttonTripSection(
      HomeTabMainResponse mainData, int indexAddress, int index,
      {String finishText = "Finalizar",
      String initText = "Comenzar",
      bool backButton = false}) {
    if (mainData.serviceOrder.statusName != "Asignado" ||
        mainData.serviceOrder.statusName != "En asignación" ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "Asignado") ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "En asignación") ||
        (homeTabBloc.inTrip == false &&
            mainData.serviceOrder.statusName == "Terminada")) {
      print("pasa por En asignacion 2");
      if ((mainData.serviceOrder.statusName != "Terminada") &&
              ((backButton == false &&
                      homeTabBloc.inTrip == false &&
                      mainData.tripSections[indexAddress]["date_start"] ==
                          null) ||
                  (backButton == true &&
                      mainData.tripSections[indexAddress]["date_start"] !=
                          null)) ||
          (FlavorConfig.instance.values.domain.contains("plq")) ||
          FlavorConfig.instance.values.domain.contains("preprod.ziyu")) {
        return ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              homeTabBloc.inTrip
                  ? Color(CustomColor.brown_light)
                  : FlavorConfig.instance.color,
            ),
          ),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(25.0),
          // ),
          // color: homeTabBloc.inTrip
          //     ? Color(CustomColor.brown_light)
          //     : FlavorConfig.instance.color,
          onPressed: disabledInitTripButton
              ? null
              : () async {
                  if (Platform.isIOS) {
                    modalErrorDefault(
                        "No es posible iniciar un viaje en el dispositivo actual.");
                    return;
                  }

                  bool boolPermissions =
                      await _checkAllPermissions(index, requestBOP: false);
                  print("boolPermissions:::" + boolPermissions.toString());
                  loadingScreen(context);
                  if (boolPermissions) {
                    bool showPODModal = true;
                    print("index:::" + index.toString());
                    bool isProgram =
                        homeTabBloc?.allTriad[index]["triad"]?.fueling ?? false;
                    // Detener viaje
                    bool response;
                    bool chargeON = true;
                    bool notStop = true;
                    if (homeTabBloc.inTrip) {
                      print("indexAddress::::: " + indexAddress.toString());
                      print("mainData.tripSections.length::::: " +
                          mainData.tripSections.length.toString());
                      if (indexAddress < mainData.tripSections.length) {
                        print("PASA POR ACAAAAAAA");
                        //Se debe entregar las variables a backend aca
                        mainData.tripSections[indexAddress]["date_finish"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);

                        if (mainData.tripSections[mainData.tripSections.length -
                                1]["date_start"] !=
                            null) {
                          if (isProgram) {
                            response = await _modalPOD() ?? false;
                            showPODModal = false;
                          } else {
                            print("[operational_date]" +
                                mainData.tripSections[indexAddress]
                                        ["operational_date"]
                                    .toString());
                            if (true) {
                              // if (mainData.tripSections[indexAddress]
                              //             ["operational_date"] !=
                              //         null ||
                              //     tripPage == 1) {
                              if (mainData.tripSections[
                                              mainData.tripSections.length - 1]
                                          ["date_finish"] ==
                                      null &&
                                  mainData.tripSections.length - 1 ==
                                      indexAddress) {
                              } else {
                                response = await _modalTripSection(
                                  TripSection(
                                    id: mainData.tripSections[indexAddress]
                                        ["id"],
                                    nameSection: mainData
                                        .tripSections[indexAddress]["name"],
                                    order: mainData.tripSections[indexAddress]
                                        ["order"],
                                    address: mainData.tripSections[indexAddress]
                                        ["address"],
                                    longitude:
                                        mainData.tripSections[indexAddress]
                                            ["longitude"],
                                    latitude: mainData
                                        .tripSections[indexAddress]["latitude"],
                                    status: mainData.tripSections[indexAddress]
                                        ["status"],
                                    dateStart:
                                        mainData.tripSections[indexAddress]
                                            ["date_start"],
                                    dateFinish:
                                        mainData.tripSections[indexAddress]
                                            ["date_finish"],
                                    triad: mainData.tripSections[indexAddress]
                                        ["triad"],
                                    serviceOrderId: mainData.serviceOrder.id,
                                  ),
                                  notStop,
                                );
                                //await _detailSOBloc.getData(mainData.serviceOrder.id);
                              }
                              response = await modalConfirmStopTrip(
                                      isProgram: isProgram) ??
                                  false;
                            } else {
                              response = false;
                              chargeON = false;
                              Flushbar(
                                icon: Icon(Icons.clear),
                                duration: Duration(seconds: 4),
                                onTap: (flushbar) {
                                  Navigator.pop(context);
                                },
                                message:
                                    "Debe ingresar carga o descarga antes de finalizar el tramo",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                backgroundColor: Colors.blueGrey[500],
                              ).show(context);
                            }
                            if (response == false) {
                              setState(() {
                                mainData.tripSections[indexAddress]
                                    ["date_finish"] = null;
                              });
                            }
                          }

                          if (response) {
                            print("pasa por _stopTripManual");
                            notStop = false;
                            await _stopTripManual(
                              mainData.serviceOrder,
                              indexAddress,
                              showModalPOD: showPODModal,
                            );
                          }
                        }
                        if (mainData.tripSections[mainData.tripSections.length -
                                    1]["date_finish"] ==
                                null &&
                            mainData.tripSections.length - 1 == indexAddress) {
                        } else if (response) {
                          response = await _modalTripSection(
                            TripSection(
                              id: mainData.tripSections[indexAddress]["id"],
                              nameSection: mainData.tripSections[indexAddress]
                                  ["name"],
                              order: mainData.tripSections[indexAddress]
                                  ["order"],
                              address: mainData.tripSections[indexAddress]
                                  ["address"],
                              longitude: mainData.tripSections[indexAddress]
                                  ["longitude"],
                              latitude: mainData.tripSections[indexAddress]
                                  ["latitude"],
                              status: mainData.tripSections[indexAddress]
                                  ["status"],
                              dateStart: mainData.tripSections[indexAddress]
                                  ["date_start"],
                              dateFinish: mainData.tripSections[indexAddress]
                                  ["date_finish"],
                              triad: mainData.tripSections[indexAddress]
                                  ["triad"],
                              serviceOrderId: mainData.serviceOrder.id,
                            ),
                            notStop,
                          );
                          //await _detailSOBloc.getData(mainData.serviceOrder.id);
                        }
                      }
                      if (homeTabBloc.inTrip &&
                          backButton == true &&
                          response) {
                        //tripPage = 2;
                        tripSectionOrderId = indexAddress + 1;
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  height: 500,
                                  child: DetailDocuments(
                                    serviceOrder: mainData.serviceOrder,
                                    tabController: widget.tabController,
                                    idSO: mainData.serviceOrder.id,
                                    detailSOBloc: _detailSOBloc,
                                    boolHomeTab: true,
                                    tripSectionOrderId: tripSectionOrderId,
                                    soListTabBloc: _soListTabBloc,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    } else {
                      if (mainData.tripSections[indexAddress]["date_start"] ==
                          null) {
                        mainData.tripSections[indexAddress]["date_start"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);
                        await _detailSOBloc.getData(mainData.serviceOrder.id);
                        print("pasa antes del _initTrip");
                        await _initTrip(index,
                            requestBOP: mainData.requestBatteryOptimization);

                        print("entra aca por que finishTripSection = false");
                        mainData.tripSections[indexAddress + 1]["date_start"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);
                        if (indexAddress == 0) {
                          mainData.tripSections[indexAddress]["date_finish"] =
                              DateTime.now().toString();
                          //print("status: " + mainData.tripSections[indexAddress]["status"]);
                          response = await _modalTripSection(
                              TripSection(
                                id: mainData.tripSections[indexAddress]["id"],
                                nameSection: mainData.tripSections[indexAddress]
                                    ["name"],
                                order: mainData.tripSections[indexAddress]
                                    ["order"],
                                address: mainData.tripSections[indexAddress]
                                    ["address"],
                                longitude: mainData.tripSections[indexAddress]
                                    ["longitude"],
                                latitude: mainData.tripSections[indexAddress]
                                    ["latitude"],
                                status: mainData.tripSections[indexAddress]
                                    ["status"],
                                dateStart: mainData.tripSections[indexAddress]
                                    ["date_start"],
                                dateFinish: mainData.tripSections[indexAddress]
                                    ["date_finish"],
                                triad: mainData.tripSections[indexAddress]
                                    ["triad"],
                                serviceOrderId: mainData.serviceOrder.id,
                              ),
                              true);
                        } else {
                          response = await _modalTripSection(
                              TripSection(
                                id: mainData.tripSections[indexAddress]["id"],
                                nameSection: mainData.tripSections[indexAddress]
                                    ["name"],
                                order: mainData.tripSections[indexAddress]
                                    ["order"],
                                address: mainData.tripSections[indexAddress]
                                    ["address"],
                                longitude: mainData.tripSections[indexAddress]
                                    ["longitude"],
                                latitude: mainData.tripSections[indexAddress]
                                    ["latitude"],
                                status: mainData.tripSections[indexAddress]
                                    ["status"],
                                dateStart: mainData.tripSections[indexAddress]
                                    ["date_start"],
                                dateFinish: mainData.tripSections[indexAddress]
                                    ["date_finish"],
                                triad: mainData.tripSections[indexAddress]
                                    ["triad"],
                                serviceOrderId: mainData.serviceOrder.id,
                              ),
                              true);
                        }

                        await _detailSOBloc.getData(mainData.serviceOrder.id);
                        // print("pasa antes del _initTrip");
                        // print("initTrip:::5");
                        // await _initTrip(index,
                        //     requestBOP: mainData.requestBatteryOptimization);

                        print("entra aca por que finishTripSection = false");
                        mainData.tripSections[indexAddress + 1]["date_start"] =
                            DateTime.now().toString();
                        //print("status: " + mainData.tripSections[indexAddress]["status"]);
                        response = await _modalTripSection(
                            TripSection(
                              id: mainData.tripSections[indexAddress + 1]["id"],
                              nameSection: mainData
                                  .tripSections[indexAddress + 1]["name"],
                              order: mainData.tripSections[indexAddress + 1]
                                  ["order"],
                              address: mainData.tripSections[indexAddress + 1]
                                  ["address"],
                              longitude: mainData.tripSections[indexAddress + 1]
                                  ["longitude"],
                              latitude: mainData.tripSections[indexAddress + 1]
                                  ["latitude"],
                              status: mainData.tripSections[indexAddress + 1]
                                  ["status"],
                              dateStart: mainData.tripSections[indexAddress + 1]
                                  ["date_start"],
                              dateFinish:
                                  mainData.tripSections[indexAddress + 1]
                                      ["date_finish"],
                              triad: mainData.tripSections[indexAddress + 1]
                                  ["triad"],
                              serviceOrderId: mainData.serviceOrder.id,
                            ),
                            true);
                        // loadingScreen(context);
                        await _detailSOBloc.getData(mainData.serviceOrder.id);
                        // Navigator.pop(context);
                      }
                    }
                    print("indexAddress:::::;" + indexAddress.toString());
                    // loadingScreen(context);
                    if (FlavorConfig.instance.values.domain.contains(
                        "segmentado")) if (tripPage != 1 && tripPage != 3) {
                      print("segun yo entra aqui");
                      // int indexTS2 = mainData.tripSections.indexWhere((element) => element["status"] == 1);
                      print("indice distinto igual a 1 " +
                          indexAddress.toString());
                      // loadingScreen(context);
                      // setState(() {
                      //   print("TITLEAPP:::::::" + AppBloc.instance.titleApp);
                      //   tripPage = 3;
                      //   tripSectionOrderId = indexTS2 + 1;
                      // });
                      // await _detailSOBloc.getData(mainData.serviceOrder.id);
                      // Navigator.pop(context);
                      setState(() {
                        tripPage = 3;
                        tripSectionOrderId = indexAddress + 2;
                        if (indexAddress == 0)
                          serviceIndexState = tripToRealize - 1;
                      });
                    }
                    if (FlavorConfig.instance.values.domain.contains(
                        "segmentado")) if (tripPage == 1 && indexAddress != 0) {
                      setState(() {
                        tripPage = 3;
                        tripSectionOrderId = indexAddress + 1;
                        if (indexAddress == 0)
                          serviceIndexState = tripToRealize - 1;
                      });
                    } else if (tripPage == 3 &&
                        indexAddress != 0 &&
                        chargeON == true) {
                      setState(() {
                        timer?.cancel();
                        tripPage = 1;
                        tripSectionOrderId = indexAddress + 1;
                        if (indexAddress == 0)
                          serviceIndexState = tripToRealize - 1;
                      });
                    }
                    //await _detailSOBloc.getData(mainData.serviceOrder.id);
                    Navigator.pop(context);
                  } else {
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 4),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message:
                          "Verifique los permisos de solicitados por la aplicación",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context);
                  }
                },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    child: Text(homeTabBloc.inTrip ? finishText : initText,
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
                /*if (homeTabBloc.inTrip == false)
                    Container(width: 2,),
                  if (homeTabBloc.inTrip == false)
                    Transform.rotate(
                      angle: 90 * pi / 180,
                      child: Icon(
                        Icons.arrow_circle_up,
                        color: ColorsCustom.white_container,
                        size: 16,
                      ),
                    )*/
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  Widget _tripSection(
      HomeTabMainResponse mainData, int indexAddress, int index) {
    print("indexAddress: $indexAddress");

    if (indexAddress == 0) {
      originTrip = "TU UBICACIÓN";
      finalTrip = mainData.tripSections[indexAddress]["name"].toString();
      finalTrip = finalTrip.toUpperCase();
    } else {
      //originTrip = mainData.addresses[indexAddress-1];
      originTrip = mainData.tripSections[indexAddress - 1]["name"].toString();
      finalTrip = mainData.tripSections[indexAddress]["name"].toString();
      originTrip = originTrip.toUpperCase();
      finalTrip = finalTrip.toUpperCase();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "   TRAMO " + (indexAddress).toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(CustomColor.black_medium)),
        ),
        Container(
          height: 5,
        ),
        Container(
            padding: const EdgeInsets.all(5.0),
            color: Colors.transparent,
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    onTap: () {},
                    splashColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Color(CustomColor.grey_low), width: 1.5),
                        color: Color(CustomColor.grey_low),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      "Presentación:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(CustomColor.black_medium)),
                                    ),
                                  ),
                                  Container(
                                    height: 4,
                                  ),
                                  FittedBox(
                                    child: Text(
                                      mainData.addressesTime[indexAddress],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(CustomColor.grey_medium)),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Column(
                                          children: [
                                            Transform.scale(
                                              child: Icon(
                                                Icons.trip_origin,
                                                color: ColorsCustom.ziyu_color,
                                              ),
                                              scale: 0.6,
                                            ),
                                            Transform.scale(
                                              child: Transform.rotate(
                                                child: Icon(
                                                  Icons.horizontal_rule,
                                                  color:
                                                      ColorsCustom.ziyu_color,
                                                ),
                                                angle: 90 * pi / 180,
                                              ),
                                              scale: 1.7,
                                            ),
                                            Transform.scale(
                                              child: Icon(
                                                Icons
                                                    .arrow_drop_down_circle_rounded,
                                                color: ColorsCustom.ziyu_color,
                                              ),
                                              scale: 0.6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 3,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            RichText(
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Origen: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .black_medium)),
                                                  ),
                                                  TextSpan(
                                                    text: originTrip,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Color(CustomColor
                                                            .grey_medium)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 20.0,
                                            ),
                                            RichText(
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "Destino: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .black_medium)),
                                                  ),
                                                  TextSpan(
                                                    text: finalTrip,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Color(CustomColor
                                                            .grey_medium)),
                                                  ),
                                                ],
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
                          Container(
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                      ),
                                      Expanded(
                                          child: _buttonTrip(
                                              mainData, indexAddress, index)),
                                    ],
                                  ),
                                  if (listMainData[index]
                                              .tripSections[indexAddress]
                                          ["date_finish"] ==
                                      null)
                                    Container(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        iconSize: 40,
                                        icon: Icon(
                                          listMainData[index].tripSections[
                                                              indexAddress]
                                                          ["date_start"] !=
                                                      null &&
                                                  listMainData[index]
                                                                  .tripSections[
                                                              indexAddress]
                                                          ["date_finish"] ==
                                                      null
                                              ? Icons.alt_route
                                              : Icons.location_on,
                                          color: listMainData[index]
                                                                  .tripSections[
                                                              indexAddress]
                                                          ["date_start"] !=
                                                      null &&
                                                  listMainData[index]
                                                                  .tripSections[
                                                              indexAddress]
                                                          ["date_finish"] ==
                                                      null
                                              ? Colors.green
                                              : Color(CustomColor.ziyu_color),
                                        ),
                                        onPressed: () async {
                                          if (FlavorConfig
                                              .instance.values.domain
                                              .contains("segmentado")) {
                                            loadingScreen(context);

                                            setState(() {
                                              tripPage = 3;
                                              tripSectionOrderId =
                                                  indexAddress + 1;
                                            });
                                            await _detailSOBloc.getData(
                                                mainData.serviceOrder.id);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (listMainData[index].tripSections[
                                                      indexAddress]["status"] ==
                                                  0 ||
                                              listMainData[index].tripSections[
                                                      indexAddress]["status"] ==
                                                  2)
                                            Container(
                                              height: 20,
                                            ),
                                          if (listMainData[index].tripSections[
                                                      indexAddress]
                                                  ["date_finish"] !=
                                              null)
                                            FittedBox(
                                              child: TextButton(
                                                onPressed: () async {
                                                  loadingScreen(context);
                                                  await _detailSOBloc.getData(
                                                      listMainData[index]
                                                          .serviceOrder
                                                          .id,
                                                      fromInternet: true);
                                                  AppBloc.instance
                                                      .refreshScreen(
                                                          "fromNameFunction");
                                                  Navigator.pop(context);
                                                  if (listMainData[index]
                                                                  .tripSections[
                                                              indexAddress]
                                                          ["date_finish"] !=
                                                      null) {
                                                    setState(() {
                                                      //tripPage = 2;
                                                      tripSectionOrderId =
                                                          indexAddress + 1;
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        builder: (BuildContext
                                                            context) {
                                                          return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return Container(
                                                                height: 500,
                                                                child:
                                                                    DetailDocuments(
                                                                  serviceOrder:
                                                                      listMainData[
                                                                              index]
                                                                          .serviceOrder,
                                                                  tabController:
                                                                      widget
                                                                          .tabController,
                                                                  idSO: listMainData[
                                                                          index]
                                                                      .serviceOrder
                                                                      .id,
                                                                  detailSOBloc:
                                                                      _detailSOBloc,
                                                                  boolHomeTab:
                                                                      true,
                                                                  tripSectionOrderId:
                                                                      tripSectionOrderId,
                                                                  soListTabBloc:
                                                                      _soListTabBloc,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    });
                                                  } else {
                                                    Flushbar(
                                                      icon: Icon(Icons.clear),
                                                      duration:
                                                          Duration(seconds: 4),
                                                      onTap: (flushbar) {
                                                        Navigator.pop(context);
                                                      },
                                                      message:
                                                          "Debe finalizar el tramo $indexAddress para ingresar a los documentos.",
                                                      margin: EdgeInsets.all(8),
                                                      borderRadius: 8,
                                                      backgroundColor:
                                                          Colors.blueGrey[500],
                                                    ).show(context);
                                                  }
                                                },
                                                child: Text(
                                                  "Ver documentos",
                                                  style: TextStyle(
                                                    color: Color(
                                                        CustomColor.ziyu_color),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )))),
      ],
    );
  }

  Widget _generateScreen() {
    return StreamBuilder(
      stream: _detailSOBloc.observSO,
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.data != null) {
              //_serviceOrder = snapshot.data["service_order"];
              if (snapshot.data["is_program"]) {
                return _errorScreen("Esta en programa");
              }
              /*return DetailProgramContent(
                  data: snapshot.data,
                  topScreen: _topScreen(snapshot.data),
                  backButton: _backButton(),
                );*/
              else
                return DetailDocuments(
                  serviceOrder: mainData.serviceOrder,
                  tabController: widget.tabController,
                  idSO: mainData.serviceOrder.id,
                  detailSOBloc: _detailSOBloc,
                );
            }

            return _errorScreen("Error");
        }
      },
    );
  }

  Widget _errorScreen(String error) {
    return Center(
      child: InkWell(
        onTap: () async {
          loadingScreen(context);
          await _detailSOBloc.getData(mainData.serviceOrder.id);
          Navigator.pop(context);
        },
        child: Text(
          error + "\nPresione para volver a intentar",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _serviceData(Widget icon, HomeTabMainResponse mainData, int index,
      Widget tripButton, bool boolNotShowingNumberTrips,
      {Function() onPressed}) {
    return Container(
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                onTap: () async {
                  if (FlavorConfig.instance.values.domain
                      .contains("segmentado")) {
                    print("serviceorder status" +
                        mainData.serviceOrder.status.toString());
                    if (ServiceOrder.ARRAY_IN_PROCESS
                        .contains(mainData.serviceOrder.status)) {
                      int indexTS2 = mainData.tripSections
                          .indexWhere((element) => element["status"] == 1);
                      print("indice distinto igual a 1 " + indexTS2.toString());
                      loadingScreen(context);
                      setState(() {
                        print("TITLEAPP:::::::" + AppBloc.instance.titleApp);
                        tripPage = 3;
                        tripSectionOrderId = indexTS2 + 1;
                      });
                      await _detailSOBloc.getData(mainData.serviceOrder.id);
                      Navigator.pop(context);
                    }
                  }
                },
                splashColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color(CustomColor.grey_lower), width: 1.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 25.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Transform.scale(
                                  scale: 1.2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: icon,
                                        flex: 3,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: RichText(
                                          maxLines: 10,
                                          text: TextSpan(
                                            // Note: Styles for TextSpans must be explicitly defined.
                                            // Child text spans will inherit styles from parent
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "ID " +
                                                    mainData.serviceOrder.id
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(
                                                        CustomColor.black_low)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Column(children: [
                                          if (mainData.deliveryDate != null &&
                                              mainData.deliveryDate != "")
                                            RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "Presentación en destino:\n",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(CustomColor
                                                          .black_medium),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: mainData.deliveryDate,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .black_low)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          // FittedBox(
                                          //   child: Text(
                                          //     "Presentación en destino:",
                                          //     style: TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //         color: Color(CustomColor
                                          //             .black_medium)),
                                          //   ),
                                          // ),
                                          // Text(mainData.deliveryDate),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 30,
                                ),
                                if (boolNotShowingNumberTrips == false)
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Center(
                                        child: _serviceInfo(mainData, index)),
                                  ),
                                Container(
                                  height: 10,
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ))));
  }

  Widget _serviceInfo(HomeTabMainResponse mainData, int index) {
    final statusSo = mainData.serviceOrder?.status;
    final confirmAndInRoute = statusSo == ServiceOrder.CONFIRMED ||
        statusSo == ServiceOrder.IN_PROCESS ||
        statusSo == ServiceOrder.DELAYED;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mainData.sku.principalClient != null &&
            mainData.sku.principalClient != "")
          Flexible(
            fit: FlexFit.loose,
            child: RichText(
              maxLines: 10,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                      text: "Mandante: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: mainData.sku.principalClient,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_low)),
                  )
                ],
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: RichText(
                maxLines: 10,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "Estado: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_medium)),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: RichText(
                maxLines: 10,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: mainData.serviceOrder?.statusName ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_low)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5, top: 4.0),
              height: 12.0,
              width: 12.0,
              decoration: BoxDecoration(
                color: (mainData.serviceOrder?.status ==
                            ServiceOrder.IN_PROCESS ||
                        mainData.serviceOrder?.status == ServiceOrder.DELAYED)
                    ? Color(CustomColor.green_medium)
                    : Colors.yellow[600],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        Container(height: 10),
        Flexible(
          fit: FlexFit.loose,
          child: RichText(
            maxLines: 10,
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                    text: "Cliente: ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: mainData.clientName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(CustomColor.black_low)),
                )
              ],
            ),
          ),
        ),
        Container(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 9,
              child: RichText(
                maxLines: 10,
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text: "Contenedor: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: mainData.containerId != null
                          ? mainData.containerId.toString()
                          : "POR CONFIRMAR",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_low)),
                    ),
                  ],
                ),
              ),
            ),
            if (mainData.containerId == null)
              Container(
                constraints: BoxConstraints(maxWidth: 40, maxHeight: 30),
                child: FloatingActionButton.extended(
                  label: Align(
                    child: Icon(Icons.edit),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => _containerServiceAlert(mainData),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          Container(height: 10),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(CustomColor.black_medium)),
              children: <TextSpan>[
                TextSpan(
                  text: "Dirección Inicial: ",
                ),
              ],
            ),
          ),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(CustomColor.grey_medium)),
              children: <TextSpan>[
                TextSpan(
                  text: mainData.addresses[0],
                ),
              ],
            ),
          ),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          Container(height: 10),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(CustomColor.black_medium)),
              children: <TextSpan>[
                TextSpan(
                  text: "Dirección Final: ",
                ),
              ],
            ),
          ),
        if (FlavorConfig.instance.values.domain.contains("preprod.ziyu"))
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(CustomColor.grey_medium)),
              children: <TextSpan>[
                TextSpan(
                  text: mainData.addresses[mainData.addresses.length - 1],
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 14,
              child: _serviceInfoSegmented(mainData),
            ),
            Expanded(
              flex: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Container(
                  //   height: 25,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //EN ESPERA A DOCS:
                      /*Expanded(
                        child: Container(
                        height: 8.0,
                        width: 8.0,
                        decoration: BoxDecoration(
                          color: (mainData.serviceOrder?.status ==
                                      ServiceOrder.IN_PROCESS ||
                                  mainData.serviceOrder?.status == ServiceOrder.DELAYED)
                              ? Color(CustomColor.green_medium)
                              : Colors.yellow[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      ),
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          child: Text("Rechazado"),
                        ),
                      )*/
                    ],
                  ),
                  if (listMainData[index].tripSections.length != 0)
                    if (listMainData[index].tripSections.last["date_finish"] !=
                        null)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FittedBox(
                          child: TextButton(
                            onPressed: () async {
                              //DOCUMENTOS COMPLETOS
                              if (listMainData[index]
                                      .tripSections
                                      .last["date_finish"] !=
                                  null) {
                                loadingScreen(context);
                                await _detailSOBloc.getData(
                                    listMainData[index].serviceOrder.id,
                                    fromInternet: true);
                                await AppBloc.instance
                                    .refreshScreen("fromNameFunction");
                                Navigator.pop(context);
                                setState(() {
                                  //tripPage = 2;
                                  indexTrip = index;
                                  serviceIndexState = index;
                                  AppBloc.instance.isBackDeactivate = true;

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Container(
                                            height: 500,
                                            child: DetailDocuments(
                                              serviceOrder: listMainData[index]
                                                  .serviceOrder,
                                              tabController:
                                                  widget.tabController,
                                              idSO: listMainData[index]
                                                  .serviceOrder
                                                  .id,
                                              detailSOBloc: _detailSOBloc,
                                              boolHomeTab: true,
                                              soListTabBloc: _soListTabBloc,
                                              totalTrips: listMainData[index]
                                                  .addresses
                                                  .length,
                                              boolDropDown: true,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                });
                              } else {
                                Flushbar(
                                  icon: Icon(Icons.clear),
                                  duration: Duration(seconds: 4),
                                  onTap: (flushbar) {
                                    Navigator.pop(context);
                                  },
                                  message:
                                      "Debe finalizar el viaje para ver los documentos.",
                                  margin: EdgeInsets.all(8),
                                  borderRadius: 8,
                                  backgroundColor: Colors.blueGrey[500],
                                ).show(context);
                              }
                            },
                            //VER DOCUMENTOS COMPLETO
                            child: Text(
                              "Ver documentos",
                              style: TextStyle(
                                color: Color(CustomColor.ziyu_color),
                              ),
                            ),
                          ),
                        ),
                      ),
                  if ((listMainData[index].tripSections.length != 0 &&
                      !FlavorConfig.instance.values.domain.contains("plq") &&
                      !FlavorConfig.instance.values.domain
                          .contains("preprod.ziyu")))
                    if (listMainData[index].tripSections.last["date_finish"] ==
                        null)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            constraints: BoxConstraints(
                                maxWidth: confirmAndInRoute ? 0 : 150,
                                maxHeight: 30),
                            child: _buttonTrip(mainData, 0, index)),
                      ),
                  if (FlavorConfig.instance.values.domain.contains("plq") ||
                      FlavorConfig.instance.values.domain
                          .contains("preprod.ziyu"))
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                          constraints: BoxConstraints(
                              maxWidth: FlavorConfig.instance.values.domain
                                          .contains("plq") ||
                                      FlavorConfig.instance.values.domain
                                          .contains("preprod.ziyu")
                                  ? 200
                                  : confirmAndInRoute
                                      ? 0
                                      : 150,
                              maxHeight: 40),
                          child: _buttonTrip(mainData, 0, index)),
                    ),
                ],
              ),
            ),
          ],
        ),
        Container(height: 10),
      ],
    );
  }

  Widget _serviceInfoSegmented(HomeTabMainResponse mainData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 10,
        ),
        Row(
          children: [
            RichText(
              maxLines: 10,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Patente: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_medium)),
                  ),
                ],
              ),
            ),
            RichText(
              maxLines: 10,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: mainData.triad.plateVehicle.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_low)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _extraButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (homeTabBloc.lecture != null &&
            (homeTabBloc.lecture.lectureInstance?.isResponsed ?? false))
          IconButton(
            icon: Icon(
              Icons.chrome_reader_mode_rounded,
              color: Color(CustomColor.black_medium),
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pushNamed(context, LectureCredentialScreen.identifier,
                  arguments: homeTabBloc.lecture.lectureInstance.id);
            },
          ),
        !emptyString(homeTabBloc.service?.instruction)
            ? IconButton(
                icon: Icon(
                  Icons.info,
                  color: Color(CustomColor.black_medium),
                  size: 30.0,
                ),
                onPressed: () {
                  modalInstruction(homeTabBloc.service?.instruction);
                },
              )
            : SizedBox(height: 30.0),
      ],
    );
  }

  Widget _routeElementData(int skuType, String description) {
    final listWidget = List<Widget>();

    listWidget.add(Text(
      "RUTA:",
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Color(CustomColor.black_medium)),
    ));

    description = description.replaceAll('-', "  -  destino: ");

    listWidget.add(Text(
      "origen: " + description + "",
      style: TextStyle(color: Color(CustomColor.black_medium)),
    ));

    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color(CustomColor.white_container),
        border: Border.all(color: Color(CustomColor.grey_lower), width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            'assets/icons/map-o.svg',
            color: Color(CustomColor.black_medium),
            height: 30.0,
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: listWidget,
                )),
          )
        ],
      ),
    );
  }

  // Orden de servicio NO ASIGNADA
  Widget _notAssignedContent(HomeTabMainResponse mainData) {
    String nameService =
        (mainData.isFueling ?? false) ? "programa" : "servicio";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(height: 30.0),
        Text(
          "Sin $nameService asignado",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Color(CustomColor.black_medium)),
        ),
        Container(height: 20.0),
        Container(
          color: Color(CustomColor.yellow_light),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: SvgPicture.asset('assets/icons/truck.svg', height: 20.0),
              ),
              Expanded(
                child: Text(
                  "Estás a la espera de un $nameService. En cualquier momento serás contactado.",
                  maxLines: 3,
                ),
              )
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.symmetric(vertical: 20.0),
        //   child: Center(
        //     child: textButton(
        //       onTap: () {
        //         launch('tel:'+central_number);
        //       },
        //       text: "Contactar con la central"
        //     )
        //   )
        // )
      ],
    );
  }

  // ------------------- funciones botones -------------------
  _initTrip(int index, {bool requestBOP = false}) async {
    bool tripInited = false;
    bool errorNetwork = false;
    bool isProgram = homeTabBloc.allTriad[index]["triad"]?.fueling ?? false;
    final bool sendGPSLocation = !isProgram;
    AppBloc.instance.workshift =
        homeTabBloc.allTriad[index]["triad"].workshiftId;
    print("workshift:::" + AppBloc.instance.workshift.toString());
    final hasPermissions =
        await _checkAllPermissions(index, requestBOP: requestBOP);
    if (!hasPermissions) {
      return false;
    }

    if (isProgram) {
      final confirProgram = await modalConfirmInitTrip(isProgram: true);
      if (confirProgram != true) {
        return false;
      }
    }

    // EMPIEZA EL VIAJE!
    // loadingScreen(context);
    final response = await TrackingService.instance.startTrip(
        serviceOrder: homeTabBloc.allTriad[index]["service_order"],
        serviceOrderId: homeTabBloc.allTriad[index]["service_order"].id,
        sendGPSLocation: sendGPSLocation,
        isProgram: isProgram);
    print("response enum::::" + response.toString());

    if (response == InitTripResponse.success) {
      tripInited = true;

      setState(() {
        homeTabBloc.inTrip = true;
      });
      await syncroData();
    } else if (response == InitTripResponse.miss_lecture) {
      await homeTabBloc.getDriverStatus("miss lecture");
      final response = await homeTabBloc.getInstanceLecture();
      print("response::::: getInstanceLecture::: " + response.toString());
      if (!response) errorNetwork = true;
    } else {
      errorNetwork = true;
    }

    // Navigator.pop(context);

    // Modales de respuesta
    if (tripInited) {
      // print("cosaaaaaaaaaaaaaaa" + homeTabBloc.allTriad[index].toString());
      modalInitTrip();
    } else if (errorNetwork) {
      modalNeedNetwork();
    } else if (response == InitTripResponse.miss_lecture) {
      if (homeTabBloc.lecture != null &&
          !(homeTabBloc.lecture.lectureInstance?.isResponsed ?? false)) {
        final response = await modalLecture(homeTabBloc.lecture) ?? false;
        print("mainData :::" + mainData.serviceOrder.id.toString());
        print("response:::: responseLecture:::" + response.toString());
        if (response) {
          _responseLecture(index, requestBOP);
        }

        return false;
      }
    }
  }

  Future<bool> _checkAllPermissions(int index,
      {bool requestBOP = false}) async {
    if (Platform.isIOS) {
      return false;
    }

    final versionPermission = await _checkNewVersionApp2() ?? false;
    if (!versionPermission) return false;

    // Charla de seguridad
    if (homeTabBloc.lecture != null &&
        !(homeTabBloc.lecture.lectureInstance?.isResponsed ?? false)) {
      final response = await modalLecture(homeTabBloc.lecture) ?? false;
      print("response charlas de seguridad::: " + response.toString());
      if (response) {
        _responseLecture(index, requestBOP);
      }
      final versionPermission = await _checkNewVersionApp2() ?? false;
      if (!versionPermission) return false;

      return false;
    }

    // permiso de optimización
    final optimizationBatteryPermission =
        await homeTabBloc.checkBatteryOptimization();
    if (!optimizationBatteryPermission) {
      countOptimization++;
      if (countOptimization < 4) {
        return false;
      }
    }
    countOptimization = 0;

    // permiso particular de batería
    if (requestBOP) {
      final particularOptimization =
          await homeTabBloc.checkParticularBatteryOptimization();
      if (!particularOptimization && !askedBatteryOptimizationParticular) {
        askedBatteryOptimizationParticular = true;
        await modalBatteryOptimization();
        return true;
      }
    }

    final bool sendGPSLocation = !(homeTabBloc.triad?.fueling ?? false);
    if (sendGPSLocation) {
      // Permisos de geolocalización
      final locationPermissions = await askLocationAndPhonePermissions(context,
          showCancelButton: true, locationAlways: true);
      final locationEnable = await homeTabBloc.checkLocationEnable();
      if (!locationPermissions || !locationEnable) {
        if (locationPermissions && !locationEnable)
          homeTabBloc.requestLocationService();

        return false;
      }
    }

    return true;
  }

  Future<bool> _checkNewVersionApp2() async {
    loadingScreen(context);
    final latestVersionAPP = await homeTabBloc.getLatestVersionAppApi();
    Navigator.pop(context);

    if (latestVersionAPP != null) {
      final currentVersion = await homeTabBloc.getCurrentVersionApp();

      if (latestVersionAPP.version.isNotEmpty &&
          (latestVersionAPP.versionClean.compareTo(currentVersion) > 0)) {
        await _newVersionAppDialog2(currentVersion, latestVersionAPP.version,
            force: latestVersionAPP.forceUpdate);

        if ((latestVersionAPP.forceUpdate ?? false)) {
          return false;
        }
      }
    }

    return true;
  }

  _responseLecture(int index, bool requestBOP) async {
    // final response = await Navigator.pushNamed(context, LectureScreen.identifier, arguments: homeTabBloc.lecture.id) ?? false;
    print("_responseLecture, homeTabBloc.lecture.id::" +
        homeTabBloc.lecture.id.toString());
    print("_responseLecture, homeTabBloc.allTriad[index][service_order].id::" +
        homeTabBloc.allTriad[index]["service_order"].id.toString());
    final response = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LectureScreen(
                    idLecture: homeTabBloc.lecture.id,
                    serviceOrderId:
                        homeTabBloc.allTriad[index]["service_order"].id,
                  )),
        ) ??
        false;
    print("_responseLecture, response::" + response.toString());
    setState(() {
      disabledInitTripButton = true;
    });

    await homeTabBloc.getInstanceLecture();
    setState(() {
      disabledInitTripButton = false;
    });

    if (response) {
      _initTrip(index, requestBOP: requestBOP);
    }
  }

  _stopTripManual(ServiceOrder os, indexAddress,
      {bool showModalPOD = true}) async {
    boolNavigation = false;
    timer?.cancel();
    print("stoping trip");

    loadingScreen(context);
    AppBloc.instance.lastServiceOrderId = homeTabBloc.serviceOrder?.id;
    await TrackingService.instance
        .stopTrip(cancelSO: false, finishType: Trip.FINISHED_MANUAL_MOBILE);
    await syncroData();
    setState(() {
      homeTabBloc.inTrip = false;
      AppBloc.instance.showSOFinished = true;
    });
    Navigator.pop(context);

    AppBloc.instance.refreshScreen("fromDetailsDocuments");

    tripSectionOrderId = indexAddress + 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 500,
              child: DetailDocuments(
                serviceOrder: os,
                tabController: widget.tabController,
                idSO: os.id,
                detailSOBloc: _detailSOBloc,
                boolHomeTab: true,
                tripSectionOrderId: tripSectionOrderId,
                soListTabBloc: _soListTabBloc,
                comment: "back",
              ),
            );
          },
        );
      },
    );
  }

  _restartTrip() async {
    loadingScreen(context);
    await syncroData();
    Navigator.pop(context);
  }

  // ------------------- modales -------------------

  _modalTripSection(TripSection tripSection, bool boolDialog) async {
    AppBloc.instance.isModalPODOpen = true;
    final response = await homeTabBloc.saveSection(tripSection);
    return response;
  }

  _modalPOD() async {
    AppBloc.instance.isModalPODOpen = true;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (mainData.isFueling) {
          return ModalPODContent(
            tabController: widget.tabController,
            customTitle: "Ingresa POD para finalizar el programa",
            isFueling: mainData.isFueling,
            onSubmitDataFueling:
                (File podFile, String comment, double endMeter) async {
              // loadingScreen(context);
              final response = await homeTabBloc.savePODAndEndMeter(
                  podFile, comment, endMeter);
              // Navigator.pop(context);

              setState(() {});

              return response;
            },
          );
        }

        return ModalPODContent(
          tabController: widget.tabController,
          customTitle: "Ingresa POD para finalizar la orden de servicio",
          onSubmitData: (File podFile, String comment, int index) async {
            loadingScreen(context);
            for (int i = 0;
                i < homeTabBloc.serviceOrder.documents.length;
                i++) {
              if (homeTabBloc.serviceOrder.documents[i].documentId == index) {
                homeTabBloc.serviceOrder.documents[i].comment = comment;
                homeTabBloc.serviceOrder.documents[i].file = podFile.path;
                homeTabBloc.serviceOrder.documents[i].fileBackup = podFile.path;
                homeTabBloc.serviceOrder.documents[i].title = null;
              }
              print("homeTabBloc.serviceOrder.documents.documentId =======" +
                  homeTabBloc.serviceOrder.documents[i].documentId.toString());
            }
            final response =
                await homeTabBloc.savePOD(podFile, comment, index, 1, null);
            Navigator.pop(context);

            setState(() {});

            return response;
          },
        );
      },
    );
  }

  modalInitTrip() {
    String title = "Orden de servicio iniciada.";
    if (homeTabBloc.triad?.fueling ?? false) {
      title = "Programa iniciado.";
    }

    Alert(
        image: Image.asset("assets/icons/icon_success_modal.png",
            color: FlavorConfig.instance.color),
        context: context,
        title: "Buen viaje!",
        content: Text(title),
        buttons: [
          DialogButton(
            color: FlavorConfig.instance.color,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          )
        ]).show();
  }

  Future modalLecture(Lecture lecture) async {
    return await Alert(
        type: AlertType.warning,
        context: context,
        title: lecture.title ?? "Charla de seguridad",
        content: Text(
          "Para comenzar el viaje debe contestar la siguiente charla de seguridad.",
          style: TextStyle(fontSize: 15.0),
        ),
        buttons: [
          DialogButton(
            color: Color(CustomColor.grey_medium),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          DialogButton(
            color: FlavorConfig.instance.color,
            child: Text(
              "Contestar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context, true),
          )
        ]).show();
  }

  Future<int> cancelServiceModal() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Seleccione motivo de cancelación"),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text("Ayuda"),
                    onPressed: () {
                      Navigator.pop(context, ServiceCancel.HELP_TYPE);
                    },
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text("Problemas técnicos"),
                    onPressed: () {
                      Navigator.pop(context, ServiceCancel.TECHNICAL_TYPE);
                    },
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text("Motivos personales"),
                    onPressed: () {
                      Navigator.pop(context, ServiceCancel.PERSONAL_TYPE);
                    },
                  ),
                ),
                Container(height: 20.0),
                DialogButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  modalNeedNetwork() {
    Alert(
        type: AlertType.error,
        context: context,
        title: "Error de conexión",
        content: Text("Necesita conexión a internet para iniciar un viaje."),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]).show();
  }

  modalErrorDefault(String text) {
    Alert(
        type: AlertType.error,
        context: context,
        title: "Error",
        content: Text(text ?? ""),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]).show();
  }

  modalNeedGps() {
    Alert(
        type: AlertType.error,
        context: context,
        title: "Error de gps",
        content: Text("Necesita activar el gps para iniciar un viaje."),
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]).show();
  }

  modalBatteryOptimization() async {
    await Alert(
        type: AlertType.warning,
        context: context,
        title: "Optimización de bateria",
        content: Text(
          "Para funcionar correctamente debe agregar el siguiente permiso.",
          style: TextStyle(fontSize: 15.0),
        ),
        buttons: [
          DialogButton(
            color: Color(CustomColor.grey_medium),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            child: Text(
              "Agregar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              await homeTabBloc.saveAskedParticularBO();
              homeTabBloc
                  .getDriverStatus("update asked particular optimization");
              Navigator.pop(context);
              homeTabBloc.requestParticularBatteryOptimization();
            },
          )
        ]).show();
  }

  Future<bool> modalConfirmInitTrip({bool isProgram = false}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalInitTripContent(
          isProgram: isProgram,
          meterInit: mainData.program?.meterInit,
          onSubmit: (String meterInit) {
            homeTabBloc.updateProgramFuelMeterInit(meterInit);
          },
        );
      },
    );
  }

  Future<bool> modalConfirmStopTrip({bool isProgram = false, os}) async {
    final nameService = isProgram ? "el programa" : "la orden de servicio";
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Finalizar"),
          content: Container(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("¿Seguro deseas finalizar $nameService?"),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DialogButton(
                        color: Color(CustomColor.black_low),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  color: ColorsCustom.ziyu_color),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Cancelar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context, false);
                        },
                      ),
                      DialogButton(
                        color: Color(CustomColor.brown_light),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  color: ColorsCustom.ziyu_color),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Finalizar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context, true);
                          await _detailSOBloc.getData(
                              os == null ? mainData.serviceOrder.id : os.id);
                          AppBloc.instance.refreshScreen("fromNameFunction");
                          setState(() {
                            os == null
                                ? mainData.serviceOrder.statusName = "Terminada"
                                : os.statusName = "Terminada";
                          });
                        },
                      ),
                    ],
                  ))
            ],
          )),
        );
      },
    );
  }

  Future<bool> modalConfirmStopSection(
      {bool isProgram = false, String text}) async {
    final nameService = isProgram ? "el programa" : "el tramo";
    String text2 = text.toLowerCase();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Container(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("¿Seguro deseas $text2 $nameService?"),
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DialogButton(
                        color: Color(CustomColor.black_low),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "Cancelar",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.0),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context, false);
                        },
                      ),
                      DialogButton(
                        color: Color(CustomColor.brown_light),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            text,
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.0),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            Navigator.pop(context, true);
                          });
                        },
                      ),
                    ],
                  ))
            ],
          )),
        );
      },
    );
  }

  modalInstruction(String instruction) {
    Alert(
        context: context,
        title: "Instructivo",
        content: Row(
          children: [
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                instruction ?? "",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ))
          ],
        ),
        buttons: [
          DialogButton(
            color: FlavorConfig.instance.color,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]).show();
  }

  bool backAndroidButtonInterceptor2(
    bool stopDefaultButtonEvent,
    RouteInfo info,
  ) {
    if (backAndroidButton2 == false) {
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }

    return AppBloc.instance.isBackDeactivate;
  }

  Future _newVersionAppDialog2(String currentVersion, String newVersion,
      {bool force = false}) async {
    if (force) {
      backAndroidButton2 = false;
    } else {
      backAndroidButton2 = true;
    }
    return null;
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    // print("mike offroute eventooo ${e.eventType}");
    // _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    // _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        var distanciaDestino =
            await MapBoxNavigation.instance.getDistanceRemaining();
        print("mike distancia restante $distanciaDestino");
        if (distanciaDestino <= 50) {
          MapBoxNavigation.instance.finishNavigation();
        }
        if (progressEvent.currentStepInstruction != null) {
          // _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          // _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          // _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          // _isNavigating = true;
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
          // _routeBuilt = false;
          // _isNavigating = false;
        });
        break;
      case MapBoxEvent.off_route_ziyu:
        // print("mike offroute_ziyu si lanzo el eventooo ${e.eventType}");
        // print("mike offroute_ziyu si lanzo el serviceOrder $activeSO");
        final data = await repositoryTripAlert.getAllAlertsTrip(activeSO?.id);
        Trip _trip = await repositoryTrip.getFromSO(activeSO?.id);
        final offRouteAlerts =
            data.where((alert) => alert["type_alert"] == 9).toList();
        // print("mike offroute_ziyu data $data");
        // print("mike offroute_ziyu offRouteAlerts $offRouteAlerts");
        // print("mike offroute_ziyu onceOffRoute $onceOffRoute");
        if ((onceOffRoute ?? false) && offRouteAlerts.length > 0) {
          final offRouteAlert = offRouteAlerts[0];
          final valor = await repositoryTripAlert.getAlertsByTrip(
              _trip.idServer, offRouteAlert["id"]);
          onceOffRoute = false;
          if (valor >= offRouteAlerts[0]["frecuency"]) {
            break;
          }
          String imei = await sharedPref.getImei();
          Position _ubicacion = await Geolocator.getLastKnownPosition();
          TripData tripdata =
              await repositoryTripData.generateCurrentTripData(trip: _trip);
          tripdata.speed = _ubicacion.speed * 3.6;
          TripAlert tripalerta = TripAlert(
            category: 2,
            idAlert: offRouteAlert["id"],
            tripData: tripdata?.idServer,
            tripDataStart: tripdata?.idServer,
            tripDataLocal: tripdata?.id,
            tripServer: _trip?.idServer,
            tripLocal: _trip?.id,
            syncro: 0,
            deviceDate: DateTime.now(),
            serviceOrderId: _trip.serviceOrder,
            versionApp: await DeviceRepository().getCurrentVersionApp(),
          );
          tripdata.imei = imei;
          try {
            int subida = await repositoryTripAlert.saveTripAlert(tripalerta,
                tripdata: tripdata);
          } catch (e) {
            print('error en la subida o en el response');
            print(e);
          }

          PushNotification notif = PushNotification(
              title: "Alerta",
              date: DateTime.now(),
              subtitle: offRouteAlert["description"]);
          // AppBloc.instance.alertCopiloto(notif);
          SpeechService.instance.speak(notif.subtitle).then((value) {
            print("Response sound: $value");
          });
        }
        break;
      case MapBoxEvent.finish_button:
        print("mike eventooo ${e.eventType}");
        MapBoxNavigation.instance.finishNavigation();
        finishFromNaviBool.value = true;
        break;
      default:
        break;
    }
    // setState(() {});
  }

  Widget newNavigationTrip(
      context, HomeTabMainResponse mainData, int indexAddress) {
    activeSO = mainData.serviceOrder;
    finishFromNaviBool.value = false;
    print("mike data que llega:: ${mainData.tripSections}");
    Gradient gradient =
        LinearGradient(colors: [Colors.cyan, Colors.blue, Colors.indigo]);
    Gradient gradientFinalizar =
        LinearGradient(colors: [Colors.orange, Colors.red, Colors.red[900]]);
    Gradient gradientCargar =
        LinearGradient(colors: [Colors.grey, Colors.grey[900]]);
    if (firstTimeNavigation) {
      firstTimeNavigation = false;
      startNavegacionMapbox(mainData, indexAddress);
    }

    final anchoPantalla = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Stack(
                children: [
                  Container(
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(miposition.latitude, miposition.longitude),
                        zoom: 15.0,
                      ),
                    ),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: anchoPantalla,
                          child: Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(CustomColor.ziyu_color),
                                        width: 1.5),
                                    color: Color(CustomColor.ziyu_color),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Center(
                                            child: RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Estado: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .black_medium)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: mainData.serviceOrder
                                                            ?.statusName ??
                                                        "",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .black_low)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 5, top: 4.0),
                                              height: 12.0,
                                              width: 12.0,
                                              decoration: BoxDecoration(
                                                color: (mainData.serviceOrder
                                                                ?.status ==
                                                            ServiceOrder
                                                                .IN_PROCESS ||
                                                        mainData.serviceOrder
                                                                ?.status ==
                                                            ServiceOrder
                                                                .DELAYED)
                                                    ? Color(CustomColor
                                                        .green_medium)
                                                    : Colors.yellow[600],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      RichText(
                                        maxLines: 10,
                                        text: TextSpan(
                                          // Note: Styles for TextSpans must be explicitly defined.
                                          // Child text spans will inherit styles from parent
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(
                                                text: "Contenedor: ",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                              text: mainData.containerId != null
                                                  ? mainData.containerId
                                                      .toString()
                                                  : "POR CONFIRMAR",
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        maxLines: 10,
                                        text: TextSpan(
                                          // Note: Styles for TextSpans must be explicitly defined.
                                          // Child text spans will inherit styles from parent
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(
                                                text: "Cliente: ",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                              text: mainData.clientName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Origen: ",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  TextSpan(
                                                    // text: mainData.tripSections[indexAddress - 1]["name"],
                                                    text:
                                                        mainData.tripSections[0]
                                                            ["name"],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Align(
                                                  child: RichText(
                                                    maxLines: 10,
                                                    text: TextSpan(
                                                      // Note: Styles for TextSpans must be explicitly defined.
                                                      // Child text spans will inherit styles from parent
                                                      style: const TextStyle(
                                                        fontSize: 17.0,
                                                        color: Colors.white,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "- - - - - - - - - - - - - - - - - -",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.topCenter,
                                                ),
                                                Align(
                                                  child: Icon(Icons.circle,
                                                      size: 14,
                                                      color: Colors.white),
                                                  alignment:
                                                      Alignment.topCenter,
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Destino: ",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        mainData.tripSections[1]
                                                            ["name"],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            maxLines: 10,
                                            text: TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: const TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.white,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Presentación: ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            maxLines: 10,
                                            text: TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: const TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.white,
                                              ),
                                              children: [
                                                TextSpan(
                                                  // text: mainData.addressesTime[indexAddress].toString(),
                                                  text: mainData
                                                      .addressesTime[1]
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ))),
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color(CustomColor.ziyu_color),
                          ),
                        ),
                        IgnorePointer(child: Container()),
                        Container(
                          width: anchoPantalla,
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    gradient: pressedCarga
                                        ? gradientFinalizar
                                        : gradientCargar,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 0.1, spreadRadius: 0.1)
                                    ]),
                                child: pressedCarga
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(
                                              anchoPantalla / 12),
                                        ),
                                        onPressed: () async {
                                          bool responseFinish =
                                              await modalConfirmStopTrip(
                                                      isProgram: false,
                                                      os: mainData
                                                          .serviceOrder) ??
                                                  false;
                                          if (responseFinish) {
                                            _stopTripManual(
                                                mainData.serviceOrder, 0,
                                                showModalPOD: true);
                                            mainData.tripSections[indexAddress]
                                                    ["date_finish"] =
                                                DateTime.now().toString();
                                            bool response =
                                                await _modalTripSection(
                                              TripSection(
                                                id: mainData.tripSections[
                                                    indexAddress]["id"],
                                                nameSection:
                                                    mainData.tripSections[
                                                        indexAddress]["name"],
                                                order: mainData.tripSections[
                                                    indexAddress]["order"],
                                                address: mainData.tripSections[
                                                    indexAddress]["address"],
                                                longitude: mainData
                                                        .tripSections[
                                                    indexAddress]["longitude"],
                                                latitude: mainData.tripSections[
                                                    indexAddress]["latitude"],
                                                status: mainData.tripSections[
                                                    indexAddress]["status"],
                                                dateStart: mainData
                                                        .tripSections[
                                                    indexAddress]["date_start"],
                                                dateFinish:
                                                    mainData.tripSections[
                                                            indexAddress]
                                                        ["date_finish"],
                                                triad: mainData.tripSections[
                                                    indexAddress]["triad"],
                                                serviceOrderId:
                                                    mainData.serviceOrder.id,
                                              ),
                                              true,
                                            );
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                                FontAwesomeIcons.mapLocationDot,
                                                color: Colors.white,
                                                size: 33),
                                            RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                    fontSize: 26.0,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: "Finalizar",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(
                                              anchoPantalla / 12),
                                        ),
                                        onPressed: () async {
                                          bool responseModal =
                                              await _modalLoadUnload(
                                                      "carga o descarga",
                                                      1,
                                                      mainData) ??
                                                  false;
                                          if (responseModal)
                                            setState(() {
                                              pressedCarga = true;
                                            });
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                const FaIcon(
                                                  FontAwesomeIcons.truckRampBox,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                                Container(
                                                    // width: 14,
                                                    child: RichText(
                                                  maxLines: 10,
                                                  text: TextSpan(
                                                    // Note: Styles for TextSpans must be explicitly defined.
                                                    // Child text spans will inherit styles from parent
                                                    style: const TextStyle(
                                                      fontSize: 20.0,
                                                      color: Colors.white,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: " / ",
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                                const FaIcon(
                                                  FontAwesomeIcons.truckMoving,
                                                  size: 20,
                                                  color: Colors.white,
                                                )
                                              ],
                                            ),
                                            RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: "Carga",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            RichText(
                                              maxLines: 10,
                                              text: TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: "Descarga",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    gradient: gradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 0.1, spreadRadius: 0.1)
                                    ]),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      shape: CircleBorder(),
                                      padding:
                                          EdgeInsets.all(anchoPantalla / 12),
                                    ),
                                    onPressed: () {
                                      // loadingScreen(context);
                                      startNavegacionMapbox(
                                          mainData, indexAddress);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(FontAwesomeIcons.locationArrow,
                                            color: Colors.white, size: 33),
                                        RichText(
                                          maxLines: 10,
                                          text: TextSpan(
                                            // Note: Styles for TextSpans must be explicitly defined.
                                            // Child text spans will inherit styles from parent
                                            style: const TextStyle(
                                                fontSize: 27.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: "Iniciar",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          )),
                          margin: EdgeInsets.symmetric(horizontal: 25.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            // color: Color(CustomColor.ziyu_color),
                          ),
                        )
                      ])
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

Future<Map<String, dynamic>> _getPointsRoute(dynamic so, int indexTS2) async {
  List<WayPoint> finalList = [];
  WayPoint startWaipoint;
  WayPoint endWaipoint;
  // int indexTS2 = so.tripSections.indexWhere((element) => element["status"] == 1);
  print("mike index total ${so.tripSections.length}");
  print("mike index $indexTS2");

  if (so.tripSections[indexTS2]["route"] != null) {
    listPoints = await RouteBaseRepository()
        .getRoutePointsAPI(so.tripSections[indexTS2]["route"]);
    if (listPoints.length <= 25 && listPoints.length > 1) {
      // print("mike entro a menor q 25 y mayor a 1");
      // print("mike entro a menor q 25 y mayor a 1 ${listPoints.length}");
      for (var i = 0; i < listPoints.length; i++) {
        WayPoint puntoInteres = WayPoint(
            name: "CheckPoints $i",
            latitude: listPoints[i].latitude,
            longitude: listPoints[i].longitude);
        finalList.add(puntoInteres);
      }
      // print("mike entro a menor q 25 y mayor a 1 $finalList");
    } else if (listPoints.length >= 25) {
      final limitaciones = (listPoints.length / 25).round();
      // print("mike cortes q tiene $limitaciones");
      // print("mike puntos totales ${listPoints.length}");
      for (var i = 0; finalList.length < 25; i = i + limitaciones) {
        print("mike index que tiene $i");
        WayPoint puntoInteres = WayPoint(
            name: "$i",
            latitude: listPoints[i].latitude,
            longitude: listPoints[i].longitude);
        finalList.add(puntoInteres);
      }
      WayPoint puntoInteres = WayPoint(
          name: "final",
          latitude: listPoints.last.latitude,
          longitude: listPoints.last.longitude);
      finalList[24] = puntoInteres;
    } else {
      String initTrip = so.addresses[indexTS2 - 1] +
          ", " +
          so.tripSections[indexTS2 - 1]["name"];
      final addresses1 =
          await Geocoder.local.findAddressesFromQuery(initTrip + ", Chile");
      final start = addresses1.first;
      String finishTrip = so.addresses[indexTS2].toString() +
          ", " +
          so.tripSections[indexTS2]["name"];
      final addresses2 =
          await Geocoder.local.findAddressesFromQuery(finishTrip + ", Chile");
      final end = addresses2.first;

      startWaipoint = WayPoint(
          name: "Origen",
          latitude: start.coordinates.latitude,
          longitude: start.coordinates.longitude);
      endWaipoint = WayPoint(
          name: "Destino",
          latitude: end.coordinates.latitude,
          longitude: end.coordinates.longitude);
    }
  } else {
    String initTrip = so.addresses[indexTS2 - 1] +
        ", " +
        so.tripSections[indexTS2 - 1]["name"];
    final addresses1 =
        await Geocoder.local.findAddressesFromQuery(initTrip + ", Chile");
    final start = addresses1.first;
    String finishTrip = so.addresses[indexTS2].toString() +
        ", " +
        so.tripSections[indexTS2]["name"];
    final addresses2 =
        await Geocoder.local.findAddressesFromQuery(finishTrip + ", Chile");
    final end = addresses2.first;
    startWaipoint = WayPoint(
        name: "Origen",
        latitude: start.coordinates.latitude,
        longitude: start.coordinates.longitude);
    endWaipoint = WayPoint(
        name: "Destino",
        latitude: end.coordinates.latitude,
        longitude: end.coordinates.longitude);
  }

  // print("mike listado final de puntos a entregar: $finalList");
  // print("mike listado final de puntos a entregar: ${finalList.length}");

  return {'start': startWaipoint, 'end': endWaipoint, 'listpoints': finalList};
}
