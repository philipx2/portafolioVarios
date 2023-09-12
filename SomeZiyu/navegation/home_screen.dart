import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/home_bloc.dart';
import 'package:ziyu_seg/src/components/app_bar_custom.dart';
import 'package:ziyu_seg/src/components/connectivity.dart';
import 'package:ziyu_seg/src/components/icon_notification.dart';
import 'package:ziyu_seg/src/components/modals/modal_sos.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/screens/sidebar_menu.dart';
import 'package:ziyu_seg/src/screens/navegation/earnings_tab.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/home_tab.dart';
import 'package:ziyu_seg/src/screens/navegation/profile_screen.dart';
import 'package:ziyu_seg/src/screens/navegation/so_list_tab.dart' as soList;
import 'package:ziyu_seg/src/screens/tac/home_tac_screen/home_tac_screen.dart';
import 'package:ziyu_seg/src/services/shared_preferences.dart';
import 'package:ziyu_seg/src/services/upload_data_service.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'detail_so/detail_so.dart';
import 'package:ziyu_seg/src/models/navegation/trip_alert.dart';
import 'package:ziyu_seg/src/components/notifications_responses.dart';
import 'package:ziyu_seg/src/utils/permissions_utils.dart';
import 'package:ziyu_seg/src/utils/upload_response.dart';
import 'package:ziyu_seg/src/components/modals/error_modal.dart';

class HomeScreen extends StatefulWidget {
  static const identifier = '/home';
  final int userType;
  bool setVariable = true;

  HomeScreen({this.userType, this.setVariable});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _homeBloc = HomeBloc();

  TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  MyConnectivity _connectivity;
  bool _firstRender = true;
  int _tabLength = 5;
  double _largeIndicatorTab = 70.0;
  List<Widget> _tabsContainers;
  List<Color> _tabsColors = [
    Color(CustomColor.pastel_purple),
    Color(CustomColor.ziyu_color),
    Color(0xFFca1e44),
    Color(CustomColor.pastel_purple),
    Color(CustomColor.pastel_purple),
  ];
  List<Widget> _tabsHeaders;
  int lastIndex = 1;
  double elevationTopBar = 0.0;
  final listTabKey = GlobalKey<soList.SOListState>();
  StreamSubscription _connectivityListener;
  final keyProfileTab = GlobalKey<ProfileScreenState>();
  final keyHomeTab = GlobalKey<HomeTabScreenState>();
  var title = Text(
    "ZiYU",
    style: TextStyle(color: ColorsCustom.white_container),
  );

  int _backIndex = 0;
  int _helpIndex = 2;
  int _homeIndex = 1;
  int _tripsIndex = 3;
  int _alertIndex = 4;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (AppBloc.instance.resumedObserverActivated) {
      if (state == AppLifecycleState.resumed) {
        _getAndshowModal();
        _refreshApp();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(backAndroidButtonInterceptor3);
    AppBloc.instance.addResumedObserver(this);
    AppBloc.instance.updateGlobalKey(_scaffoldKey);
    _tabsInit();
    if (AppBloc.instance.backDetailSO) {
      _tabController.index = 3;
    }

    AppBloc.instance.backDetailSO = false;
    AppBloc.instance.identificationService = 0;
    numberPageOS = 1;
    AppBloc.instance.showSOFinished = false;
    AppBloc.instance.showDocuments = false;
    boolNavigation = false;
    AppBloc.instance.titleApp = "ZiYU";
  }

  _getAndshowModal() async {
    var showModal = await sharedPref.getRedirectStartMilestone();
    if (showModal) {
      print('_getAndshowModal');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeTacScreen(
                  index: 1,
                )),
      );
    }
  }

  _connectivityListenerFunction() async {
    if (_connectivity != null) {
      _connectivity.disposeStream();
    }
    if (_connectivityListener != null) {
      _connectivityListener.cancel();
      _connectivityListener = null;
    }

    _connectivity = MyConnectivity.instance;
    _connectivity.initialise();
    _connectivityListener = _connectivity.myStream.listen((source) {
      final sourceConnectivity = source.keys.toList()[0];
      if (sourceConnectivity == ConnectivityResult.mobile ||
          sourceConnectivity == ConnectivityResult.wifi) {
        UploadDataService.instance.uploadNosyncroData(context: context);
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backAndroidButtonInterceptor3);
    AppBloc.instance.removeObserver();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_firstRender) {
      _firstRender = false;
      _checkNewVersionApp3();
      AppBloc.instance.getNewNotification();
      _connectivityListenerFunction();
    }
  }

  _refreshApp() async {
    if (_tabController != null) {
      if (_tabController.index == 1) {
        try {
          keyProfileTab.currentState.updateScreen();
        } catch (e) {
          print("Error updating profile tab scren: $e");
        }
      } else if (_tabController.index == 2) {
        try {
          keyHomeTab.currentState.syncroData();
        } catch (e) {
          print("Error updating home tab scren: $e");
        }
      } else if (_tabController.index == 3) {
        try {
          listTabKey.currentState.updateScreen();
        } catch (e) {
          print("Error updating list_os tab scren: $e");
        }
      }
    }
    UploadDataService.instance.uploadNosyncroData(context: context);
  }

  _checkNewVersionApp3() async {
    _homeBloc.getLatestVersionAppApi().then((latestVersionAPP) async {
      if (latestVersionAPP != null) {
        final currentVersion = await _homeBloc.getCurrentVersionApp();

        if (latestVersionAPP.version.isNotEmpty &&
            latestVersionAPP.versionClean.compareTo(currentVersion) > 0) {
          _newVersionAppDialog3(currentVersion, latestVersionAPP.version,
              force: latestVersionAPP.forceUpdate ?? false);
        }
      }
    });
  }

  bool backAndroidButtonInterceptor3(
    bool stopDefaultButtonEvent,
    RouteInfo info,
  ) {
    if (backAndroidButton2 == false) {
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("AppBloc.instance.titleApp::::::" + AppBloc.instance.titleApp);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          drawer: SideBarMenu(
            globalKey: _scaffoldKey,
            screenType: ScreenType.navegation,
          ),
          appBar: AppBarCustom(
            scaffoldKey: _scaffoldKey,
          ),
          body: _contentScreen(),
          bottomNavigationBar: _bottomBar(_tabsHeaders, _tabController),
        ));
  }

  Widget _contentScreen() {
    return Column(
      children: <Widget>[
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: _tabsContainers,
          ),
        )
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: elevationTopBar,
      brightness: Brightness.dark,
      leading: IconButton(
        key: const Key("sidebar_button"),
        icon: SvgPicture.asset("assets/icons/bars.svg",
            color: Colors.white, height: 25.0),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
      title: Center(
        child: Text(
          AppBloc.instance.titleApp,
          style: TextStyle(color: ColorsCustom.white_container),
        ),
      ),
      backgroundColor: FlavorConfig.instance.color,
      actions: <Widget>[
        IconNotification(),
      ],
    );
  }

  Widget _bottomBar(
    List<Widget> tabsHeaders,
    TabController tabController,
  ) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(CustomColor.grey_lower), width: 2.0),
          ),
        ),
        child: TabBar(
          onTap: (index) async {
            bool openModal = index == _alertIndex;
            bool openModal2 = index == _helpIndex;
            if (index != 2 && index != 4) {
              AppBloc.instance.backDetailSO = false;
              AppBloc.instance.identificationService = 0;
              print("tripPage:::: 3      ");
              tripPage = 0;
              numberPageOS = 1;
              AppBloc.instance.showSOFinished = false;
              AppBloc.instance.showDocuments = false;

              boolNavigation = false;
              AppBloc.instance.titleApp = "ZiYU";
            }
            //NO SE UTILIZARA POR EL MOMENTO
            if (false) {
              //widget.userType == User.CARRIER) {
              if (index == 4) openModal = true;
              if (index == 2) openModal2 = true;
            } else if (index == 3)
              openModal = false;
            else if (index == 1) openModal2 = false;

            if (openModal || openModal2 || index == _backIndex) {
              _tabController.animateTo(lastIndex);

              if (openModal && index == 4) {
                modalSOS(_scaffoldKey);
              }
              if (openModal2 && index == 2) {
                final locationPermissions =
                    await permissionUtils.askAndRequestPermission(
                  context: context,
                  typesPermission: [PermissionsType.LOCATION_TYPE],
                  dismissible: true,
                );
                if (locationPermissions) {
                  final locationEnable = await checkLocationEnable();
                  if (!locationEnable) {
                    requestLocationService();
                    return;
                  }
                  print("pasa por AppBlocInstance.tripPage:::");
                  // modalSendingData(context);
                  await openErrorModal(
                      context, "Torre de Control se Contactará",
                      triangleicon: true);

                  final response =
                      await sendTripAlert(TripAlert.HELP) ?? ERROR_UPLOAD;
                  notificationResponse(_scaffoldKey,
                      category: response, registerName: "Alerta");
                }
              }

              if (index == _backIndex) {
                Navigator.pop(context);
              }
            } else {
              lastIndex = index;
            }
          },
          unselectedLabelColor: Color(CustomColor.pastel_purple),
          labelColor: Color(CustomColor.ziyu_color),
          indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(color: Color(CustomColor.ziyu_color), width: 4.0),
            insets: EdgeInsets.fromLTRB(
                _largeIndicatorTab, 0.0, _largeIndicatorTab, 70.0),
          ),
          labelPadding: EdgeInsets.all(0.0),
          controller: _tabController,
          tabs: _tabsHeaders,
          indicatorColor: Color(CustomColor.ziyu_color),
          labelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(CustomColor.pastel_purple),
          ),
        ));
  }

  _hideShadowAppBar() {
    try {
      setState(() {
        elevationTopBar = 0.0;
      });
    } catch (e) {
      elevationTopBar = 0.0;
    }
  }

  _showShadowAppBar() {
    try {
      setState(() {
        elevationTopBar = 4.0;
      });
    } catch (e) {
      elevationTopBar = 4.0;
    }
  }

  // ---------------------------------------------------------------
  // Tabs config
  // ---------------------------------------------------------------

  _tabsInit() {
    lastIndex = _homeIndex;

    // //NO SE UTILIZARA POR EL MOMENTO
    // if (false) {
    //   //widget.userType == User.CARRIER) {
    //   _tabLength = 6;
    //   _largeIndicatorTab = 60.0;
    //   _alertIndex = 5;
    // } else {

    // }

    _tabLength = 5;
    _largeIndicatorTab = 75.0;
    _alertIndex = 4;
    _helpIndex = 2;

    _tabController = TabController(
        length: _tabLength, vsync: this, initialIndex: _homeIndex);

    _tabButtonsBuild();
    _tabsContainsBuild();
    _tabController.animation..addListener(_changeTab);
  }

  _changeTab() async {
    final index = (_tabController.animation.value).round();
    final lengthTab = _tabsColors.length;
    setState(() {
      // Cambia sombreado inferior de barra superior
      elevationTopBar = index == _homeIndex ? 0.0 : 4.0;

      // Cambia los colores del array
      for (var i = 0; i < lengthTab; i++) {
        _tabsColors[i] = i == index
            ? Color(CustomColor.ziyu_color)
            : Color(CustomColor.pastel_purple);
      }

      // Aplica los colores nuevos a los tabs
      _tabButtonsBuild();
    });
  }

  _tabButtonsBuild() {
    _tabsHeaders = [];
    _tabsHeaders = [
      Tab(
        icon: Icon(
          Icons.arrow_back,
          size: 25.0,
        ),
        text: 'Menú',
      ),
      Tab(
        icon: SvgPicture.asset('assets/icons/home.svg',
            height: 25.0, color: _tabsColors[_homeIndex]),
        text: 'Inicio',
      ),
      Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Color(0xFFca1e44),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons_nav/alert-triangle.svg',
              height: 25.0,
              color: Colors.white,
            ),
            RichText(
              maxLines: 10,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: "AYUDA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )],
        )
      ),
      // GestureDetector(child: Text(""),onTap: null,),
      Tab(
        icon: SvgPicture.asset('assets/icons/truck.svg',
            height: 25.0, color: _tabsColors[_tripsIndex]),
        text: 'Viajes',
      ),
    ];
    //NO SE NECESITA POR EL MOMENTO EL MODULO DE FINANZAS
    /*if (widget.userType == User.CARRIER) {
      _tabsHeaders.add(Tab(
        icon: SvgPicture.asset('assets/icons/dollar.svg',
            height: 25.0, color: _tabsColors[3]),
        text: 'Finanzas',
      ));
    }*/

    _tabsHeaders.add(Tab(
      icon: Container(
        child: Image.asset('assets/icons/customer-service.png',
            height: 26.0, color: _tabsColors[_alertIndex]),
      ),
      text: 'Alerta',
    ));
  }

  _tabsContainsBuild() {
    _tabsContainers = [];
    _tabsContainers = [
      const SizedBox(),
      HomeTabScreen(
        _tabController,
        AppBarCustom(
          scaffoldKey: _scaffoldKey,
        ),
        _bottomBar(_tabsHeaders, _tabController),
        showShadowAppBar: _showShadowAppBar,
        hideShadowAppBar: _hideShadowAppBar,
      ),
      const SizedBox(),
      soList.SOListTab(
        showShadowAppBar: _showShadowAppBar,
        hideShadowAppBar: _hideShadowAppBar,
        tabController: _tabController,
      )
    ];
    //NO SE UTILIZARA POR EL MOMENTO
    if (false) {
      //widget.userType == User.CARRIER) {
      _tabsContainers.add(EarningsTab());
    }

    _tabsContainers.add(const SizedBox());
  }

  Future _newVersionAppDialog3(String currentVersion, String newVersion,
      {bool force = false}) async {
    setState(() {
      backAndroidButton2 = true;
    });

    return null;
    /*return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
                          return Future.value(false);
                        },
            child: AlertDialog(
              title: Text("Actualizar aplicación"),
              content: Text("Nueva versión disponible! La versión $newVersion está disponible para descargar, actualmente tienes la $currentVersion."),
              actions: <Widget>[
                if (!force)
                  TextButton(
                    child: Text("Después"),
                    onPressed: () async {
                      setState(() {
                        backAndroidButton2 = true;
                      });
                      Navigator.pop(context);
                    },
                  ),

                TextButton(
                  child: Text("Actualizar"),
                  onPressed: () async {
                    Navigator.pop(context);
                    if(Platform.isAndroid){
                      LaunchReview.launch(androidAppId: "cl.ramcolog.ziyu_nav_dev");
                    }
                    else if(Platform.isIOS){
                      //AGREGAR IOS ID         
                      LaunchReview.launch(androidAppId: "cl.ramcolog.ziyu_nav_dev", writeReview: false);
                    }
                    setState(() {
                      backAndroidButton2 = false;
                    });
                  },
                ),
              ],
            ),
          );
        }
      );*/
  }

  missingUploadedDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Error de conexión"),
          content: Text(
              "Faltan datos por sincronizar. Intente nuevamente cuando tenga conexión a internet."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Widget testingButtonOld() {
    return FloatingActionButton(
      onPressed: () {
        print("hola");
        _homeBloc.forceSettingBattery();
      },
      child: Text("testing"),
    );
  }
}
