import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/blocs/splash_bloc.dart';
import 'package:ziyu_seg/src/components/app_bar_custom.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/screens/login_screen.dart';
import 'package:ziyu_seg/src/models/user.dart';
import 'package:ziyu_seg/src/screens/navegation/home_screen.dart';
import 'package:ziyu_seg/src/screens/scheduling/home_age_screen.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/home_tab.dart';
import 'package:ziyu_seg/src/screens/sidebar_menu.dart';
import 'package:ziyu_seg/src/screens/tac/create_user.dart';
import 'package:ziyu_seg/src/screens/tac/guard_home.dart';
import 'package:ziyu_seg/src/screens/tac/home_tac_screen/home_tac_screen.dart';
import 'package:launch_review/launch_review.dart';
import 'package:ziyu_seg/src/repositories/device_repository.dart';
import 'package:ziyu_seg/src/models/versionApp.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:ziyu_seg/src/components/modals/modal_sos.dart';
import 'package:ziyu_seg/src/utils/permissions_utils.dart';
import 'package:ziyu_seg/src/components/notifications_responses.dart';
import 'package:ziyu_seg/src/utils/upload_response.dart';
import 'package:ziyu_seg/src/models/navegation/trip_alert.dart';
import 'package:ziyu_seg/src/blocs/tac/doubt_bloc.dart';

import 'nav/home_nav_screen.dart';
import 'package:ziyu_seg/src/screens/tac/doubt_screen.dart';
import 'package:ziyu_seg/src/components/modals/error_modal.dart';
import 'package:ziyu_seg/src/blocs/tac/home_tac_bloc.dart';
import 'package:ziyu_seg/src/screens/splash_screen_tac.dart';
import 'package:flushbar/flushbar.dart';

bool backAndroidButton = true;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class SplashScreen extends StatefulWidget {
  static const identifier = '/splashScreen';

  SplashScreen();

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashBloc = SplashBloc();
  final _bloc = DoubtBloc();
  double heightScreen;
  SplashMainResponse mainData;
  bool _firstTime = true;
  bool inRedirect = false;
  bool isSuperSmallScreen = false;
  final maxSmallHeight = 590.0;
  bool _isZiyuNav = false;

  @override
  void initState() {
    super.initState();
    splashBloc.init();
    _isZiyuNav = FlavorConfig.isNav();
    _checkNewVersionApp();
    BackButtonInterceptor.add(backAndroidButtonInterceptor1);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backAndroidButtonInterceptor1);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstTime) {
      _firstTime = false;
      splashBloc.getMainData();
      splashBloc.checkNotificationClicked();
      AppBloc.instance.updateGlobalKey(_scaffoldKey);
    }
  }

  Future<String> getCurrentVersionApp() async {
    return await DeviceRepository().getCurrentVersionApp();
  }

  Future<VersionApp> getLatestVersionAppApi() async {
    return await DeviceRepository().getVersionAppApi();
  }

  Future<bool> _checkNewVersionApp() async {
    print("pasa por checkNewVersionApp");
    //loadingScreen(context);
    final latestVersionAPP = await getLatestVersionAppApi();
    //Navigator.pop(context);
    // print("latestVersionApp:::" + latestVersionAPP.version.toString());
    if (latestVersionAPP != null) {
      final currentVersion = await getCurrentVersionApp();
      print("currentVersion::: " + currentVersion.toString());

      if (latestVersionAPP.version.isNotEmpty &&
          (latestVersionAPP.versionClean.compareTo(currentVersion) > 0)) {
        backAndroidButton = false;
        await _newVersionAppDialog(currentVersion, latestVersionAPP.version,
            force: latestVersionAPP.forceUpdate);

        if ((latestVersionAPP.forceUpdate ?? false)) {
          return false;
        }
      }
    }

    return true;
  }

  bool backAndroidButtonInterceptor1(
    bool stopDefaultButtonEvent,
    RouteInfo info,
  ) {
    print("backAndroidBotton:::: " + backAndroidButton.toString());
    if (backAndroidButton2 != null) {
      if (backAndroidButton2 == true) {
        backAndroidButton2 = true;
        backAndroidButton = true;
      }
    }
    print("backAndroidBotton::after backAndroidButton2:: " +
        backAndroidButton.toString());

    return backAndroidButton;
  }

  Future _newVersionAppDialog(String currentVersion, String newVersion,
      {bool force = false}) async {
    setState(() {
      backAndroidButton = true;
    });
    if (force) {
      setState(() {
        backAndroidButton = true;
      });
    }

    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Actualizar aplicación"),
            content: Text(
                "Nueva versión disponible! La versión $newVersion está disponible para descargar, actualmente tienes la $currentVersion."),
            actions: <Widget>[
              if (!force)
                TextButton(
                  child: Text("Después"),
                  onPressed: () async {
                    backAndroidButton = true;
                    Navigator.pop(context);
                  },
                ),
              TextButton(
                child: Text("Actualizar"),
                onPressed: () async {
                  Navigator.pop(context);
                  if (Platform.isAndroid) {
                    LaunchReview.launch(
                        androidAppId: "cl.ramcolog.ziyu_nav_dev");
                  } else if (Platform.isIOS) {
                    //AGREGAR IOS ID
                    LaunchReview.launch(
                        androidAppId: "cl.ramcolog.ziyu_nav_dev",
                        writeReview: false);
                  }
                  await _checkNewVersionApp();
                  setState(() {
                    backAndroidButton = true;
                  });
                },
              ),
            ],
          );
        });
  }

  _redirectNotAuthenticated() async {
    splashBloc.cleanSesion();
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.identifier, (route) => false);
  }

  _redirectZiyuNav() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeNavScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    heightScreen ??= MediaQuery.of(context).size.height;
    if (heightScreen <= maxSmallHeight) isSuperSmallScreen = true;

    return WillPopScope(
        onWillPop: () async => false,
        child: StreamBuilder(
          stream: splashBloc.mainStream.stream,
          builder: (BuildContext context,
              AsyncSnapshot<SplashMainResponse> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              return Scaffold(
                body: Center(
                  child: Text("Bienvenido"),
                ),
              );
            }

            // Usuario no Logeado
            if (!snapshot.data.isAuthenticated) {
              if (!inRedirect) {
                inRedirect = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  _redirectNotAuthenticated();
                });
              }
              return Scaffold(
                body: Center(
                  child: Text("Bienvenido"),
                ),
              );
            }

            // Usuario Ziyu Nav
            if (_isZiyuNav) {
              if (!inRedirect) {
                inRedirect = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  _redirectZiyuNav();
                });
              }

              return Scaffold(
                body: Center(
                  child: Text("Bienvenido"),
                ),
              );
            }

            mainData = snapshot.data;
            print("mainData.user::::" + mainData.user.name);
            //mainData.user.companyName = await _bloc.getMandanteListFromRut(mainData.user.rut);
            AppBloc.instance.user = mainData.user;
            return _content();
          },
        ));
  }

  Widget _content() {
    if (AppBloc.instance.backDetailSO) {
      WidgetsBinding.instance.addPostFrameCallback((timestamp) {
        Navigator.pushNamed(context, HomeScreen.identifier,
            arguments: mainData.user.userType);
      });
    }

    if (mainData.user.profileTac == User.GUARD_TAC) {
      return GuardHome();
    }

    return Scaffold(
      appBar: AppBarCustom(
        scaffoldKey: _scaffoldKey,
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: SizedBox(
      //   height: 70,
      //   width: 70,
      //   child: FloatingActionButton(
      //     isExtended: true,
      //     child: elementOption(
      //       icon: SvgPicture.asset(
      //         "assets/icons_nav/alert-triangle.svg",
      //         color: Colors.white,
      //       ),
      //       text: "AYUDA",
      //       boolIconSize: true,
      //       color: Color(0xFFca1e44),
      //     ),
      //     onPressed: () async {
      //       final locationPermissions =
      //           await permissionUtils.askAndRequestPermission(
      //         context: context,
      //         typesPermission: [PermissionsType.LOCATION_TYPE],
      //         dismissible: true,
      //       );
      //       if (locationPermissions) {
      //         final locationEnable = await checkLocationEnable();
      //         if (!locationEnable) {
      //           requestLocationService();
      //           return;
      //         }
      //         boolNavigation = false;
      //         print("pasa por AppBlocInstance.tripPage:::   2    ");
      //         // modalSendingData(context);
      //         await openErrorModal(context, "Torre de Control se Contactará",
      //             triangleicon: true);

      //         final response = await sendTripAlert(
      //               TripAlert.HELP,
      //             ) ??
      //             ERROR_UPLOAD;
      //         notificationResponse(_scaffoldKey,
      //             category: response, registerName: "Alerta");
      //       }
      //     },
      //   ),
      // ),
      key: _scaffoldKey,
      drawer: SideBarMenu(
        globalKey: _scaffoldKey,
        screenType: ScreenType.home,
      ),
      backgroundColor: FlavorConfig.instance.color,
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: FlavorConfig.instance.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60.0),
                    bottomRight: Radius.circular(60.0),
                  )),
              height: heightScreen / 4.5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: userWelcomeContainer(),
                ),
                Flexible(flex: 12, child: optionsElements()),
                // Flexible(
                //   flex: 3,
                //   child: Container(
                //     alignment: Alignment.center,
                //     child: elementOption(
                //       icon: Image.asset(
                //         "assets/icons/customer-service.png",
                //         color: FlavorConfig.instance.color,
                //       ),
                //       text: "DUDAS",
                //       onPressed: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => DoubtScreen()),
                //         );
                //       },
                //       boolIconSize: true,
                //     ),
                //   ),
                // ),
                Flexible(
                    flex: 1,
                    child: Container(
                      height: 1,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget userWelcomeContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Hola, ${mainData.user.name}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
          ]),
    );
  }

  Widget optionsElements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 31.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                elementOption(
                    icon: Image.asset(
                      "assets/icons/011-location.png",
                      color: FlavorConfig.instance.color,
                    ),
                    text: "Viajes",
                    onPressed: () {
                      print("tripPage:::: 2      ");
                      tripPage = 0;
                      _navegationActionBtn();
                    }),
                const SizedBox(height: 10.0),
                // elementOptionIsComing(
                //   icon: Image.asset(
                //     "assets/icons/013-logistic.png",
                //     color: FlavorConfig.instance.color,
                //   ),
                //   text: "Acreditación",
                // ),
                elementOption(
                    icon: Image.asset(
                      "assets/icons/013-logistic.png",
                      color: FlavorConfig.instance.color,
                    ),
                    text: "Acreditación",
                    onPressed: () {
                      // if(FlavorConfig.isProduction()){
                      //   showDialog(
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return AlertDialog(
                      //         contentPadding: EdgeInsets.zero,
                      //         title: Center(
                      //             child: Text("Proximamente . . ."),
                      //         ),
                      //         actions: [
                      //           Center(child: TextButton(onPressed:() =>  Navigator.pop(context), child: Text("Volver")),),
                      //         ],
                      //       );
                      //     }
                      //   );
                      // }
                      // else{
                      _tacBtn();
                      // }
                    }),
                const SizedBox(height: 10.0),
                elementOptionIsComing(
                  icon: Image.asset(
                    "assets/icons/013-logistic.png",
                    color: FlavorConfig.instance.color,
                  ),
                  text: "Noticias",
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                elementOptionIsComing(
                  icon: Image.asset(
                    "assets/icons/010-container.png",
                    color: FlavorConfig.instance.color,
                  ),
                  text: "Terminales",
                ),
                // elementOptionIsComing(
                //   icon: Image.asset(
                //     "assets/icons/010-container.png",
                //     color: FlavorConfig.instance.color,
                //   ),
                //   text: "Terminales",
                // ),
                const SizedBox(height: 10.0),
                elementOptionIsComing(
                  icon: Image.asset(
                    "assets/icons/delivery-schedule_1.png",
                    color: FlavorConfig.instance.color,
                  ),
                  text: "Agenda",
                ),
                const SizedBox(height: 10.0),
                elementOption(
                    icon: Image.asset(
                      "assets/icons/012-send-mail.png",
                      color: FlavorConfig.instance.color,
                    ),
                    text: "Mi ZiYU",
                    onPressed: () {
                      _profileBtn();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget elementOption(
      {Widget icon,
      String text,
      Function onPressed,
      bool boolIconSize = false,
      Color color}) {
    return Container(
      decoration: BoxDecoration(
          color: color != null ? color : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 0.5,
                color: Colors.grey[350],
                offset: Offset(0.0, 2.0))
          ]),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding:
                  boolIconSize ? EdgeInsets.all(2) : const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          constraints: BoxConstraints(
                              maxHeight: boolIconSize ? 30.0 : 40.0),
                          child: icon),
                      boolIconSize
                          ? const SizedBox(height: 5.0)
                          : const SizedBox(height: 10.0),
                      RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: text,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: boolIconSize ? 11.0 : 17.0,
                                  color: color != null
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ),
                      // Text(
                      //   text,
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w500,
                      //       fontSize: boolIconSize ? 11.0 : 17.0),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget elementOptionIsComing(
      {Widget icon, String text, bool boolIconSize = false}) {
    return Opacity(
      opacity: 0.2,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  blurRadius: 2.0,
                  spreadRadius: 0.5,
                  color: Colors.grey[350],
                  offset: Offset(0.0, 2.0))
            ]),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: Text("Proximamente . . ."),
                        ),
                        actions: [
                          Center(
                            child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Volver")),
                          ),
                        ],
                      );
                    });
              },
              child: Padding(
                padding: boolIconSize
                    ? EdgeInsets.all(2)
                    : const EdgeInsets.all(20.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            constraints: BoxConstraints(
                                maxHeight: boolIconSize ? 30.0 : 50.0),
                            child: icon),
                        boolIconSize
                            ? const SizedBox(height: 5.0)
                            : const SizedBox(height: 10.0),
                        RichText(
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: text,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: boolIconSize ? 11.0 : 17.0),
                              ),
                            ],
                          ),
                        ),
                        // Text(
                        //   text,
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: boolIconSize ? 11.0 : 17.0),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------ Acciones botones ------------------------------------

  _schedulingBtn() {
    Navigator.pushNamed(context, HomeAgendamientoScreen.identifier);
  }

  _navegationActionBtn() {
    Navigator.pushNamed(context, HomeScreen.identifier,
        arguments: mainData.user.userType);
  }

  _ziyuNavBtn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeNavScreen()),
    );
  }

  _tacBtn() async {
    final user = mainData.user;
    // final userMIlestone = user.systemTypes.contains(User.MILESTONE_TYPE);
    // print('usermilestone');
    print(user.systemTypes);
    // print('usermilestone');
    if (user.profileTac == User.GUARD_TAC) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GuardHome()),
      );
    } else {
      bool response = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreenTac(),
        ),
      );
      if (response == null) {
        response = false;
      }
      if (response) {
        Flushbar(
          duration: Duration(seconds: 4),
          message: "Usted no tiene acceso a Terminales",
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          backgroundColor: Colors.blueGrey[500],
        ).show(context);
      }
    }
  }

  _profileBtn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateUser(editMode: true)),
    );
  }
}

class PreHomeTacScreen extends StatefulWidget {
  static const identifier = '/PreHomeTacScreen';
  final bool milestoneUser;

  PreHomeTacScreen({
    this.milestoneUser,
  });

  @override
  State<StatefulWidget> createState() => _PreHomeTacScreenState();
}

class _PreHomeTacScreenState extends State<PreHomeTacScreen> {
  double heightScreen;
  final maxSmallHeight = 590.0;
  bool isSuperSmallScreen = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _credentialIndex = 3;
  final _bloc = HomeTacBloc();

  @override
  void initState() {
    if (widget.milestoneUser) _credentialIndex = 4;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    heightScreen ??= MediaQuery.of(context).size.height;
    if (heightScreen <= maxSmallHeight) isSuperSmallScreen = true;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "ZiYU",
            style: TextStyle(color: Colors.white),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      // appBar: _appBar(),
      drawer: Drawer(
        child: SideBarMenu(
          globalKey: _scaffoldKey,
          screenType: ScreenType.home,
        ),
      ),
      backgroundColor: FlavorConfig.instance.color,
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: FlavorConfig.instance.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60.0),
                    bottomRight: Radius.circular(60.0),
                  )),
              height: heightScreen / 4.5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: userWelcomeContainer(),
                ),
                Flexible(flex: 6, child: optionsElements()),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: elementOption(
                      icon: Image.asset(
                        "assets/icons/customer-service.png",
                        color: FlavorConfig.instance.color,
                      ),
                      text: "DUDAS",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoubtScreen()),
                        );
                      },
                      boolIconSize: true,
                    ),
                  ),
                ),
                Container(
                  height: 5,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget userWelcomeContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¡Bienvenido!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
            const SizedBox(height: 25.0),
            Text(
              " Elija una opción:",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ]),
    );
  }

  Widget optionsElements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100.0),
                elementOption(
                    icon: Image.asset(
                      "assets/icons/013-logistic.png",
                      color: FlavorConfig.instance.color,
                    ),
                    text: "Gestión de Accesos",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeTacScreen(
                            milestoneUser: false,
                            arrowBackTab: true,
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100.0),
                elementOption(
                    icon: Image.asset(
                      "assets/icons/troncos.png",
                      color: FlavorConfig.instance.color,
                    ),
                    text: "Recepción Madera",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeTacScreen(
                            milestoneUser: true,
                            arrowBackTab: true,
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget elementOption(
      {Widget icon,
      String text,
      Function onPressed,
      bool boolIconSize = false}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 0.5,
                color: Colors.grey[350],
                offset: Offset(0.0, 2.0))
          ]),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding:
                  boolIconSize ? EdgeInsets.all(2) : const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          constraints: BoxConstraints(
                              maxHeight: isSuperSmallScreen
                                  ? 30.0
                                  : boolIconSize
                                      ? 30.0
                                      : 50.0),
                          child: icon),
                      boolIconSize
                          ? const SizedBox(height: 5.0)
                          : const SizedBox(height: 10.0),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: boolIconSize ? 11.0 : 13.0),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
