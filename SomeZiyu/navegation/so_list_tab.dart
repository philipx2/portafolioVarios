import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/so_list_tab_bloc.dart';
import 'package:ziyu_seg/src/screens/navegation/detail_so/detail_so.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/home_tab.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ziyu_seg/src/models/navegation/service_order.dart';
import 'package:ziyu_seg/src/screens/navegation/detail_so/detail_documents.dart';
import 'package:ziyu_seg/src/blocs/navegation/detail_so_bloc.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ziyu_seg/src/components/error_default.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import 'package:ziyu_seg/src/components/modals/loading_screen.dart';
import 'package:intl/intl.dart';
import 'package:ziyu_seg/src/flavor_config.dart';

import 'package:connectivity/connectivity.dart';
import 'package:ziyu_seg/src/components/connectivity.dart';
import 'package:ziyu_seg/src/services/upload_data_service.dart';

bool dropdownSO;
List<List<String>> statesAllDocuments;
List<List<Color>> statesAllColorDocuments;
List<String> statesOsDocuments;
List<String> statesDocuments;
List<Color> statesColorsDocuments;
String dropFilterController;
String dropFilterPODController;
TextEditingController initFilterController = TextEditingController();
TextEditingController finishFilterController = TextEditingController();
DateTime initFilterControllerDate;
DateTime finishFilterControllerDate;

class SOListTab extends StatefulWidget {
  final VoidCallback showShadowAppBar;
  final VoidCallback hideShadowAppBar;
  final TabController tabController;

  SOListTab(
      {@required this.showShadowAppBar,
      @required this.hideShadowAppBar,
      this.tabController});

  @override
  State<StatefulWidget> createState() => SOListState();
}

class SOListState extends State<SOListTab> {
  final _detailSOBloc = DetailSOBloc();
  final _soListTabBloc = SOListTabBloc();
  Widget mainWidget;
  bool inDetail = false;
  ScrollController _scrollController = ScrollController();
  double _lastPosition = 0.0;
  StreamController<bool> _refreshScreenController;

  bool dropdownSO = false;

  @override
  void initState() {
    dropdownSO = false;
    super.initState();
    MyConnectivity _connectivity;
    StreamSubscription _connectivityListener;
    setState(() {
      _refreshScreenController = StreamController<bool>();
      AppBloc.instance.updateRefreshScreenSink(_refreshScreenController.sink);
      _soListTabBloc.getlistSO();
      AppBloc.instance.titleApp = "ZiYU";

      _refreshScreenController.stream.listen((event) {
        _soListTabBloc.getlistSO();
      });
      if (AppBloc.instance.showSOFinished &&
          AppBloc.instance.lastServiceOrderId != null) {
        mainWidget = _generateList(firstTimeAutomaticDetails: true);
        //AppBloc.instance.showSOFinished = true;
        //showDetails(AppBloc.instance.lastServiceOrderId,);
        AppBloc.instance.showSOFinished = false;
      } else {
        mainWidget = _generateList();
        AppBloc.instance.showSOFinished = false;
      }
    });
  }

  updateScreen() async {
    await _soListTabBloc.getlistSO();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // connectivityListenerFunction();
  }

  @override
  void dispose() {
    _soListTabBloc.dispose();
    _refreshScreenController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if(_soListTabBloc.checkConnection())
    return FutureBuilder(
        future: _soListTabBloc.checkConnection(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true)
            return Container(child: mainWidget);

          // return ErrorDefault("Revise su conexión a internet para visualizar sus servicios.");
          return _refreshPage(context);
        });
  }

  Widget _refreshPage(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          maxLines: 10,
          textAlign: TextAlign.center,
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text:
                    "Revise su conexión a internet para visualizar sus servicios.",
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
            try {
              await _updateScreenAndRefresh();
            } catch (e) {
              print(e);
            }
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }

  // connectivityListenerFunction() async {
  //   if (_connectivity != null) {
  //     _connectivity.disposeStream();
  //   }
  //   if (_connectivityListener != null) {
  //     _connectivityListener.cancel();
  //     _connectivityListener = null;
  //   }

  //   _connectivity = MyConnectivity.instance;
  //   _connectivity.initialise();
  //   _connectivityListener = _connectivity.myStream.listen((source) {
  //     final sourceConnectivity = source.keys.toList()[0];
  //     if (sourceConnectivity == ConnectivityResult.mobile ||
  //         sourceConnectivity == ConnectivityResult.wifi) {
  //       UploadDataService.instance.uploadNosyncroData(context: context);
  //     }
  //   });
  // }

  Widget _generateList({bool firstTimeAutomaticDetails = false}) {
    return StreamBuilder(
      stream: _soListTabBloc.observSOList,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasData && snapshot.data.length > 0) {
              return StatefulBuilder(
                builder: (context, setState) {
                  // setState(() {});
                  return _createList(snapshot.data,
                      firstTimeAutomaticDetails: firstTimeAutomaticDetails);
                },
              );
            }
            if (snapshot.data == null) {
              return Center(
                child: Text('Error de conexión.'),
              );
            } else if (snapshot.data.length == 0) {
              return Center(
                child: Text('No existen servicios realizados.'),
              );
            }
            return Container();
        }
      },
    );
  }
  /*Stream<List<Map<String,dynamic>>> countStream() async* {
    yield _soListTabBloc.observSOList;
  }*/

  Widget _createList(List<Map<String, dynamic>> list,
      {bool firstTimeAutomaticDetails = false}) {
    if (firstTimeAutomaticDetails) {
      firstTimeAutomaticDetails = false;
      WidgetsBinding.instance.addPostFrameCallback((timestamp) {
        //showDetails(AppBloc.instance.lastServiceOrderId);
        //AppBloc.instance.refreshScreen("fromNameFunction");
        firstTimeAutomaticDetails = false;
        AppBloc.instance.titleApp = "ZiYU";
      });
    }
    if (AppBloc.instance.identificationService != 0) {
      updateScreen();
      AppBloc.instance.identificationService = 0;
      WidgetsBinding.instance.addPostFrameCallback((timestamp) {
        //showDetails(aux);
        //AppBloc.instance.refreshScreen("fromNameFunction");
      });
    }

    statesAllDocuments = List(list.length);
    statesAllColorDocuments = List(list.length);

    for (int index = 0; index < list.length; index++) {
      int countDocuments = 0;
      if (list[index]["service_order"].serviceModel != "") {
        if (list[index]["service_order"].serviceModel != null) {
          if (list[index]["service_order"].serviceModel["category"] == 1) {
            //IMPORTACION
            countDocuments = 2;
          } else if (list[index]["service_order"].serviceModel["category"] ==
              2) {
            //EXPORTACION
            countDocuments = 2;
          } else if (list[index]["service_order"].serviceModel["category"] ==
              3) {
            //CARGA NACIONAL
            countDocuments = 1;
          } else if (list[index]["service_order"].serviceModel["category"] !=
              null) {
            //OTRO
            countDocuments = 1;
          }

          if (countDocuments == 0) {
            if (list[index]["service_order"].serviceModel["category_service"] ==
                1) {
              //IMPORTACION
              countDocuments = 2;
            } else if (list[index]["service_order"]
                    .serviceModel["category_service"] ==
                2) {
              //EXPORTACION
              countDocuments = 2;
            } else if (list[index]["service_order"]
                    .serviceModel["category_service"] ==
                3) {
              //CARGA NACIONAL
              countDocuments = 1;
            } else {
              //OTRO
              countDocuments = 1;
            }
          }
        } else {
          return ErrorDefault(
            "Revise su conexión a internet para visualizar los servicios realizados",
            tryagain: false,
          );
        }
      }
      int countDocumentsInSections;

      statesAllDocuments[index] = [];
      statesAllColorDocuments[index] = [];
      if (list[index]["trip_sections"] != null) {
        if (list[index]["trip_sections"].length != 0) {
          for (int j = 1;
              j <= list[index]["trip_sections"][index].length;
              j++) {
            bool boolDocsWait;
            countDocumentsInSections = 0;
            statesAllDocuments[index].add(" ");
            statesAllColorDocuments[index].add(Colors.grey);
            for (int i = 0;
                i < list[index]["service_order"].documents.length;
                i++) {
              if (list[index]["trip_sections"][index][j - 1]["id"] ==
                  list[index]["service_order"].documents[i]["trip_section"]) {
                countDocumentsInSections++;
              }
            }
            print("countDocumentsInSections:::" +
                countDocumentsInSections.toString() +
                " serviceorder:::" +
                list[index]["service_order"].id.toString());
            print("countDocumentsInSections:::" +
                countDocumentsInSections.toString() +
                " trip_section:::" +
                list[index]["trip_sections"][index][j - 1].toString());
            for (int i = 0;
                i < list[index]["service_order"].documents.length;
                i++) {
              if (list[index]["service_order"].documents[i]
                      ["order_trip_section"] ==
                  j) {
                if (list[index]["service_order"].documents[i]["status"] == 4) {
                  statesAllDocuments[index][j - 1] = "Rechazado";
                  statesAllColorDocuments[index][j - 1] = Colors.red;
                  break;
                } else if (list[index]["service_order"].documents[i]
                            ["status"] ==
                        3 &&
                    countDocumentsInSections == countDocuments &&
                    boolDocsWait != true &&
                    countDocumentsInSections != 0) {
                  statesAllDocuments[index][j - 1] = "Aprobado";
                  statesAllColorDocuments[index][j - 1] = Colors.green;
                } else {
                  statesAllDocuments[index][j - 1] = "Pendiente";
                  statesAllColorDocuments[index][j - 1] = Colors.grey;
                  boolDocsWait = true;
                }
              }
            }
          }
        }
      } else if (FlavorConfig.instance.values.domain.contains("preprod.ziyu")) {
        bool boolDocsWait;
        int countDocumentsAproved = 0;
        statesAllDocuments[index].add(" ");
        statesAllColorDocuments[index].add(Colors.grey);
        print("countDocumentsInSections:::" +
            countDocumentsInSections.toString() +
            " serviceorder:::" +
            list[index]["service_order"].id.toString());
        for (int i = 0;
            i < list[index]["service_order"].documents.length;
            i++) {
          print("status docs $i::: " +
              list[index]["service_order"].documents[i]["status"].toString());
          if (list[index]["service_order"].documents[i]["status"] == 4) {
            statesAllDocuments[index][0] = "Rechazado";
            statesAllColorDocuments[index][0] = Colors.red;
            break;
          } else if (list[index]["service_order"].documents[i]["status"] == 3) {
            countDocumentsAproved++;
          } else {
            statesAllDocuments[index][0] = "Pendiente";
            statesAllColorDocuments[index][0] = Colors.grey;
            boolDocsWait = true;
          }
          if (countDocumentsAproved == countDocuments && boolDocsWait != true) {
            statesAllDocuments[index][0] = "Aprobado";
            statesAllColorDocuments[index][0] = Colors.green;
          }
        }
      }
    }
    int count2 = 0;
    print("statesAllDocuments::::" + statesAllDocuments.toString());
    statesOsDocuments = List(list.length);
    for (int i = 0; i < statesAllDocuments.length; i++) {
      if (listEquals(
              statesAllDocuments[i], ["Pendiente", "Aprobado", "Aprobado"]) ||
          listEquals(statesAllDocuments[i], [" ", "Aprobado", "Aprobado"]) ||
          listEquals(statesAllDocuments[i], [" ", "Aprobado"]) ||
          listEquals(statesAllDocuments[i], ["Aprobado"]) ||
          listEquals(statesAllDocuments[i], [
            "Pendiente",
            "Aprobado",
          ])) {
        statesOsDocuments[i] = "Aprobado";
      } else if (statesAllDocuments[i].contains("Rechazado")) {
        statesOsDocuments[i] = "Rechazado";
      } else {
        statesOsDocuments[i] = "En revisión";
      }
    }
    return RefreshIndicator(
        onRefresh: () async {
          await updateScreen();

          return true;
        },
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 50.0),
            controller: _scrollController,
            itemCount: list.length,
            itemBuilder: (context, index) {
              int count = 0;
              statesDocuments = [];
              if (list[index]["service_order"].dateClosed != null ||
                  index == 0) {
                if (initFilterControllerDate != null &&
                    finishFilterControllerDate != null) {
                  print("pasa por el primer segundo if");
                  count++;
                  print("count:::::" + count.toString());
                  return Column(
                    children: <Widget>[
                      index == 0 ? _title(list[index], index) : Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController != null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController == null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController != null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController == null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed))
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                    ],
                  );
                } else if (initFilterControllerDate == null &&
                    finishFilterControllerDate != null) {
                  print("pasa por el primer segundo if");
                  count++;
                  print("count:::::" + count.toString());
                  return Column(
                    children: <Widget>[
                      index == 0 ? _title(list[index], index) : Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController != null)
                          if (finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController == null)
                          if (finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController != null)
                          if (finishFilterControllerDate.isAfter(
                                  list[index]["service_order"].dateClosed) &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController == null)
                          if (finishFilterControllerDate
                              .isAfter(list[index]["service_order"].dateClosed))
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                    ],
                  );
                } else if (initFilterControllerDate != null &&
                    finishFilterControllerDate == null) {
                  print("pasa por el primer segundo if");
                  count++;
                  print("count:::::" + count.toString());
                  return Column(
                    children: <Widget>[
                      index == 0 ? _title(list[index], index) : Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController != null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      Container(),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController != null &&
                            dropFilterPODController == null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              list[index]["sku"].principalClient ==
                                  dropFilterController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController != null)
                          if (list[index]["service_order"]
                                  .dateClosed
                                  .isAfter(initFilterControllerDate) &&
                              statesOsDocuments[index] ==
                                  dropFilterPODController)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                      if (list[index]["service_order"].dateClosed != null)
                        if (dropFilterController == null &&
                            dropFilterPODController == null)
                          if (list[index]["service_order"]
                              .dateClosed
                              .isAfter(initFilterControllerDate))
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: containerTrip(list[index], index),
                            ),
                    ],
                  );
                } else if (initFilterControllerDate == null &&
                    finishFilterControllerDate == null) {
                  print("pasa por else if");
                  count++;
                  print("count2:::::" + count.toString());
                  return Column(
                    children: <Widget>[
                      index == 0 ? _title(list[index], index) : Container(),
                      if (dropFilterController != null &&
                          dropFilterPODController == null)
                        if (list[index]["sku"].principalClient ==
                            dropFilterController)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: containerTrip(list[index], index),
                          ),
                      if (dropFilterController == null &&
                          dropFilterPODController != null)
                        if (statesOsDocuments[index] == dropFilterPODController)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: containerTrip(list[index], index),
                          ),
                      if (dropFilterController != null &&
                          dropFilterPODController != null)
                        if (statesOsDocuments[index] ==
                                dropFilterPODController &&
                            list[index]["sku"].principalClient ==
                                dropFilterController)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: containerTrip(list[index], index),
                          ),
                      if (dropFilterController == null &&
                          dropFilterPODController == null)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          child: containerTrip(list[index], index),
                        ),
                    ],
                  );
                } else {
                  print("pasa por penultimo else");
                  count++;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: containerTrip(list[index], index),
                  );
                }
              } else {
                if (count == 0 && count2 == 0) {
                  count2++;
                  print("pasa por count =0");
                  return Column(
                    children: [
                      index == 0 ? _title(list[index], index) : Container(),
                      Container(
                        child: Center(
                          child: Text("No tiene viajes con este filtro"),
                        ),
                      )
                    ],
                  );
                } else if (count2 != 0) {
                  return Container();
                } else {
                  print("pasa por ultimo else");
                  print(list[index]["service_order"].id);
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: containerTrip(list[index], index),
                  );
                }
              }
            }));
  }

  Widget _title(Map<String, dynamic> data, int index) {
    print("se muestra title");
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (_soListTabBloc.localData == null)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.only(right: 5.0),
              child: Text(
                "Los datos pueden estar desactualizados",
                style: TextStyle(
                    color: Color(CustomColor.brown_light),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        //Container(width: 10,),

        Container(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: RichText(
            maxLines: 10,
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              children: [
                TextSpan(
                  text: _soListTabBloc.isFueling
                      ? "Programas realizados"
                      : "Viajes Realizados",
                ),
              ],
            ),
          ),
        ),
        if (_soListTabBloc.localData != null)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
                padding: EdgeInsets.only(right: 5.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    bool response = await showModalFilter(data, index);
                  },
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_rounded),
                      RichText(
                        maxLines: 10,
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          children: [
                            TextSpan(
                              text: "filtros",
                              style: TextStyle(
                                  color: Color(CustomColor.brown_light),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          )
      ],
    ));
  }

  showModalFilter(Map<String, dynamic> data, int index) {
    print("data::::" + data.toString());
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.5,
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "   Filtros",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                dropFilterController = null;
                                dropFilterPODController = null;
                                initFilterController.clear();
                                finishFilterController.clear();
                                initFilterControllerDate = null;
                                finishFilterControllerDate = null;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Container(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [_selectInitDate(), _selectFinishDate()],
                      ),
                      Container(
                        height: 20,
                      ),
                      if (data["principal_clients"] != null)
                        Align(
                          child: Text(
                            "Mandante",
                            style: TextStyle(
                                color: ColorsCustom.grey_medium_2,
                                fontWeight: FontWeight.bold),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      if (data["principal_clients"] != null)
                        Container(
                          height: 5,
                        ),
                      if (data["principal_clients"] != null)
                        Container(
                          child: dropDownButtonPrincipalClient(data, index),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2.0,
                                  color: Color(CustomColor.grey_medium))),
                        ),
                      Container(
                        height: 15,
                      ),
                      if (!FlavorConfig.instance.values.domain.contains("plq"))
                        Align(
                          child: Text(
                            "Estado POD",
                            style: TextStyle(
                                color: ColorsCustom.grey_medium_2,
                                fontWeight: FontWeight.bold),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      if (!FlavorConfig.instance.values.domain.contains("plq"))
                        Container(
                          height: 5,
                        ),
                      if (!FlavorConfig.instance.values.domain.contains("plq"))
                        Container(
                          child: dropDownButtonPOD(data, index),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2.0,
                                  color: Color(CustomColor.grey_medium))),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(25.0),
                            // ),
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              backgroundColor: FlavorConfig.instance.color,
                            ),
                            onPressed: () {
                              setState(() {
                                dropFilterController = null;
                                dropFilterPODController = null;
                                initFilterController.clear();
                                finishFilterController.clear();
                                initFilterControllerDate = null;
                                finishFilterControllerDate = null;
                              });
                            },
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Resetear",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(25.0),
                            // ),
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              backgroundColor: FlavorConfig.instance.color,
                            ),
                            onPressed: () async {
                              print("---------- Filtros -----------");
                              print(initFilterController.text);
                              print(finishFilterController.text);
                              print(dropFilterController);
                              print(dropFilterPODController);
                              print("--------------------------------");
                              loadingScreen(context);
                              await _soListTabBloc.getlistSO();
                              Navigator.pop(context);

                              setState(() {
                                initFilterControllerDate;
                                finishFilterControllerDate;

                                Navigator.pop(context, true);
                              });
                            },

                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Aplicar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  Widget dropDownButtonPrincipalClient(
      Map<String, dynamic> mainData, int index) {
    List<dynamic> principalClients = [];
    for (int i = 0; i < mainData["principal_clients"].length; i++) {
      principalClients.add(mainData["principal_clients"][i]["business_name"]);
    }
    //principalClients.addAll(listMainData[0].operationalRejections);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isDense: true,
              value: dropFilterController,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Seleccione mandante",
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
                  dropFilterController = newValue;
                });
              },
              items: principalClients
                  .map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    child: Text(value),
                    padding: const EdgeInsets.all(8.0),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget dropDownButtonPOD(Map<String, dynamic> mainData, int index) {
    List<dynamic> statePOD = ["Aprobado", "Rechazado", "En revisión"];
    //principalClients.addAll(listMainData[0].operationalRejections);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isDense: true,
              value: dropFilterPODController,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Seleccione estado POD",
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
                  dropFilterPODController = newValue;
                });
              },
              items: statePOD.map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    child: Text(value),
                    padding: const EdgeInsets.all(8.0),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _filterInit() {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: initFilterController,
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today_outlined),
            labelText: "Desde",
            border: InputBorder.none),
        readOnly: true,
        onTap: () async {
          DateTime pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), //get today's date
            firstDate: DateTime(2018), // not to allow to choose before today.
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

            setState(() {
              initFilterController.text = formattedDate;
              initFilterControllerDate = pickedDate;
            });
          }
        },
      ),
    );
  }

  _selectInitDate() {
    final now = DateTime.now();
    String formattedDated1;
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: initFilterController,
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today_outlined),
            labelText: "Desde",
            border: InputBorder.none),
        readOnly: true,
        onTap: () async {
          DatePicker.showDatePicker(context,
              maxDateTime: DateTime.now(),
              dateFormat: "d/MM/yyyy",
              locale: DateTimePickerLocale.es,
              pickerMode: DateTimePickerMode.date,
              // pickerTheme: DatePickerTheme.Default,
              onConfirm: (DateTime picked, List<int> listInt) {
            if (picked != null)
              formattedDated1 = DateFormat('dd-MM-yyyy').format(picked);
            setState(() {
              initFilterController.text = formattedDated1;
              initFilterControllerDate = picked;
            });
          });
        },
      ),
    );
  }

  _selectFinishDate() {
    final now = DateTime.now();
    String formattedDated2;
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: finishFilterController,
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today_outlined),
            labelText: "Hasta",
            border: InputBorder.none),
        readOnly: true,
        onTap: () async {
          final minDate = initFilterController.text.split('-')[2] +
              '-' +
              initFilterController.text.split('-')[1] +
              '-' +
              initFilterController.text.split('-')[0];
          DatePicker.showDatePicker(context,
              minDateTime: DateTime.parse(minDate) ?? DateTime.now(),
              maxDateTime: DateTime.now(),
              dateFormat: "d/MM/yyyy",
              locale: DateTimePickerLocale.es,
              pickerMode: DateTimePickerMode.date,
              // pickerTheme: DatePickerTheme.Default,
              onConfirm: (DateTime pickedDate2, List<int> listInt) {
            if (pickedDate2 != null)
              formattedDated2 = DateFormat('dd-MM-yyyy').format(pickedDate2);
            setState(() {
              finishFilterController.text = formattedDated2;
              finishFilterControllerDate = pickedDate2.add(Duration(days: 1));
            });
          });
        },
      ),
    );
  }

  Widget _filterFinish() {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: finishFilterController,
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today_outlined),
            labelText: "Hasta",
            border: InputBorder.none),
        readOnly: true,
        onTap: () async {
          final minDate = initFilterController.text.split('-')[2] +
              '-' +
              initFilterController.text.split('-')[1] +
              '-' +
              initFilterController.text.split('-')[0];
          DateTime pickedDate2 = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.parse(minDate) ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (pickedDate2 != null) {
            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate2);
            setState(() {
              finishFilterController.text = formattedDate;
              finishFilterControllerDate = pickedDate2.add(Duration(days: 1));
            });
          }
        },
      ),
    );
  }

  Widget containerTrip(Map<String, dynamic> data, int index) {
    List sku = data["service_order"].serviceName.split('-');
    int countSkus;
    print("sku.length:::" + sku.length.toString());
    if (data["sku"].skus.length != 0) {
      countSkus = data["sku"].skus.length;
    } else {
      countSkus = 2;
    }

    var addresses = sku.sublist(sku.length - countSkus);
    var skuNameList = sku.sublist(sku.length - countSkus).join(' -> ');
    var skuName = skuNameList.toString();
    if (FlavorConfig.instance.values.domain.contains("plq")) {
      List skuPlq = data["sku"].description.split(' - ');
      print("skuPlq[0].split).last();:::" + data["sku"].description.toString());
      skuPlq[0] = skuPlq[0].split("|").last;
      if (skuPlq.length == 2) {
        skuPlq[1] = skuPlq[1].split("|").first;
      }
      if (skuPlq.length == 3) {
        skuPlq[2] = skuPlq[2].split("|").first;
      }
      sku = skuPlq;
      print("skuPlq[0].split).last();:::" + sku.toString());
      addresses = sku.sublist(0);
      skuNameList = sku.sublist(0).join(' -> ');
      skuName = skuNameList.toString();
    }
    var numberTrip;
    numberTrip = FittedBox(
        child: Icon(
      Icons.looks_one,
      color: Color(
        CustomColor.white_container,
      ),
    ));
    if (addresses.length == 1) {
      numberTrip = FittedBox(
          child: Icon(
        Icons.looks_one,
        color: Color(
          CustomColor.white_container,
        ),
      ));
    } else if (addresses.length == 2) {
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
    dropdownSO = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              elevation: 5,
              child: Container(
                  color: Colors.transparent,
                  child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          splashColor:
                              (data["service_order"].statusName == "Asignado")
                                  ? Color(CustomColor.ziyu_color)
                                  : Color(CustomColor.black_low),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (data["service_order"].statusName ==
                                      "Asignado")
                                  ? Color(CustomColor.ziyu_color)
                                  : Color(CustomColor.ziyu_color),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(CustomColor
                                                            .white_container)),
                                                  ),
                                                ),
                                              ),
                                              // Container(
                                              //   child: Align(
                                              //     alignment: Alignment.topRight,
                                              //     child: Column(
                                              //       children: [
                                              //         IconButton(
                                              //           icon: Icon(
                                              //             (dropdownSO)
                                              //                 ? Icons
                                              //                     .keyboard_arrow_down
                                              //                 : Icons
                                              //                     .keyboard_arrow_right,
                                              //             color: Colors.white,
                                              //           ),
                                              //           onPressed: () {
                                              //             setState(() {
                                              //               if (dropdownSO) {
                                              //                 dropdownSO =
                                              //                     false;
                                              //               } else {
                                              //                 dropdownSO = true;
                                              //               }
                                              //             });
                                              //           },
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          )))),
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
                data,
                index,
                false,
                2,
                // addresses.length,
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        );
      },
    );
  }

  Widget _serviceRoute(
    Widget icon,
    Map<String, dynamic> mainData,
  ) {
    var sku = mainData["service_order"].serviceName.split('-');
    int countSkus;
    if (mainData["sku"].skus.length != 0) {
      countSkus = mainData["sku"].skus.length + 1;
    } else {
      countSkus = 2;
    }
    var addresses = sku.sublist(sku.length - countSkus);
    var skuNameList = sku.sublist(sku.length - countSkus).join(' -> ');
    var skuName = skuNameList.toString();
    var numberTrip;
    if (addresses.length == 1) {
      numberTrip = FittedBox(
          child: Icon(
        Icons.looks_one,
        color: Color(
          CustomColor.white_container,
        ),
      ));
    } else if (addresses.length == 2) {
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
    dropdownSO = false;
    return Container(
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                splashColor:
                    (mainData["service_order"].statusName == "Asignado")
                        ? Color(CustomColor.ziyu_color)
                        : Color(CustomColor.black_low),
                child: Container(
                  decoration: BoxDecoration(
                    color: (mainData["service_order"].statusName == "Asignado")
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
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  CustomColor.white_container)),
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   child: Align(
                                    //     alignment: Alignment.topRight,
                                    //     child: Column(
                                    //       children: [
                                    //         IconButton(
                                    //           icon: Icon(
                                    //             (dropdownSO)
                                    //                 ? Icons.keyboard_arrow_down
                                    //                 : Icons
                                    //                     .keyboard_arrow_right,
                                    //             color: Colors.white,
                                    //           ),
                                    //           onPressed: () {
                                    //             setState(() {
                                    //               if (dropdownSO) {
                                    //                 dropdownSO = false;
                                    //               } else {
                                    //                 dropdownSO = true;
                                    //               }
                                    //             });
                                    //           },
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ))));
  }

  Widget _serviceData(Widget icon, Map<String, dynamic> mainData, int index,
      bool boolNotShowingNumberTrips, int addresses) {
    return Container(
        constraints: BoxConstraints(minHeight: 80),
        color: Colors.transparent,
        child: Material(
            color: Color(CustomColor.grey_low),
            child: InkWell(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                splashColor: Color(CustomColor.grey_low),
                child: Container(
                  constraints: BoxConstraints(minHeight: 80),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Color(CustomColor.grey_low), width: 1.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            constraints: BoxConstraints(minHeight: 80),
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Transform.scale(
                                  scale: 1.0,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: icon,
                                        flex: 3,
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: RichText(
                                          maxLines: 10,
                                          text: TextSpan(
                                            // Note: Styles for TextSpans must be explicitly defined.
                                            // Child text spans will inherit styles from parent
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: "ID " +
                                                    mainData["service_order"]
                                                        .id
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
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Color(CustomColor.ziyu_color),
                                              ),
                                            ),
                                            // shape: RoundedRectangleBorder(
                                            //   borderRadius: BorderRadius.circular(25.0),
                                            // ),
                                            // color: Color(CustomColor.ziyu_color),
                                            onPressed: () async {
                                              int indexAddress;
                                              if (addresses > 1)
                                                indexAddress = 1;
                                              if (addresses > 2)
                                                indexAddress = 2;
                                              if (addresses > 3)
                                                indexAddress = 3;
                                              setState(() {
                                                //tripPage = 2;
                                                tripSectionOrderId =
                                                    indexAddress + 1;
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Container(
                                                          height: 500,
                                                          child:
                                                              DetailDocuments(
                                                            serviceOrder: mainData[
                                                                "service_order"],
                                                            tabController: widget
                                                                .tabController,
                                                            idSO: mainData[
                                                                    "service_order"]
                                                                .id,
                                                            detailSOBloc:
                                                                _detailSOBloc,
                                                            boolHomeTab: true,
                                                            tripSectionOrderId:
                                                                tripSectionOrderId,
                                                            soListTabBloc:
                                                                _soListTabBloc,
                                                            //totalTrips: mainData["trip_sections"][index].length,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              });
                                            },
                                            child: RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: "Documentos",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (boolNotShowingNumberTrips == false)
                                  Transform.scale(
                                      scale: 1.0,
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          setState(() {});
                                          return Center(
                                              child: _serviceInfo(
                                                  mainData, index, addresses));
                                        },
                                      )),
                                Container(
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ))));
  }

  showModalInfo(Map<String, dynamic> mainData, int index) {
    String dayfinish;
    if (mainData["service_order"].dateClosed != null)
      dayfinish = mainData["service_order"]
          .dateClosed
          .toString()
          .split("-")
          .sublist(0, 3)
          .join(" ")
          .toString()
          .split(" ")
          .sublist(0, 3)
          .reversed
          .join("/");
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
                height:
                    FlavorConfig.instance.values.domain.contains("segmentado")
                        ? 530
                        : 300,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "   Reporte de viaje",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/truck.svg',
                          color: Color(CustomColor.black_low),
                          height: 20.0,
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            " ID " + mainData["service_order"].id.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(CustomColor.black_low)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            color: Colors.green[100],
                            child: Text(
                              "COMPLETADO",
                              style: TextStyle(
                                  color: Colors.green[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Color(CustomColor.grey_medium),
                          size: 20,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dayfinish != null
                                ? dayfinish.toString() + "  |"
                                : "Indefinido",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(CustomColor.black_medium)),
                          ),
                        ),
                        Icon(
                          Icons.alt_route,
                          color: Color(CustomColor.grey_medium),
                          size: 20,
                        ),
                        if (FlavorConfig.instance.values.domain
                            .contains("segmentado"))
                          Text(" " +
                              (mainData["trip_sections"][index].length - 1)
                                  .toString() +
                              " "),
                        if (FlavorConfig.instance.values.domain
                            .contains("segmentado"))
                          Text(
                            "TRAMOS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(CustomColor.black_medium)),
                          )
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Text(
                        "-----------------------------------------------------------------------------------"),
                    Container(
                      height: 10,
                    ),
                    if (FlavorConfig.instance.values.domain
                        .contains("segmentado"))
                      Align(
                        child: Text(
                          "Recorrido programado",
                          style: TextStyle(
                              color: ColorsCustom.black_medium,
                              fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    Container(
                      height: 10,
                    ),
                    if (FlavorConfig.instance.values.domain
                        .contains("segmentado"))
                      infoTripSection(mainData, index),
                    Container(
                      height: 10,
                    ),
                    if (FlavorConfig.instance.values.domain
                        .contains("segmentado"))
                      Text(
                          "-----------------------------------------------------------------------------------"),
                    Container(
                      height: 10,
                    ),
                    if (FlavorConfig.instance.values.domain
                        .contains("segmentado"))
                      Align(
                        child: Text(
                          "Estadísticas ",
                          style: TextStyle(
                              color: ColorsCustom.black_medium,
                              fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    Container(
                      height: 20,
                    ),
                    if (FlavorConfig.instance.values.domain
                        .contains("segmentado"))
                      stadisticWidget(mainData, index),
                  ],
                ));
          },
        );
      },
    );
  }

  Widget infoTripSection(Map<String, dynamic> mainData, int indexSo) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: mainData["trip_sections"][indexSo].length > 2 ? 150 : 75),
      child: ListView.builder(
        itemCount: mainData["trip_sections"][indexSo].length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index > 0) {
            String duration;
            DateTime dateFinish, dateStart;
            if (mainData["trip_sections"][indexSo][index]["date_finish"] !=
                null) {
              dateFinish = DateTime.parse(
                  mainData["trip_sections"][indexSo][index]["date_finish"]);
            }
            if (mainData["trip_sections"][indexSo][index]["date_start"] !=
                null) {
              dateStart = DateTime.parse(
                  mainData["trip_sections"][indexSo][index]["date_start"]);
            }
            if (mainData["trip_sections"][indexSo][index]["date_finish"] !=
                    null &&
                mainData["trip_sections"][indexSo][index]["date_start"] !=
                    null) {
              dateFinish = DateTime.parse(
                  mainData["trip_sections"][indexSo][index]["date_finish"]);
              dateStart = DateTime.parse(
                  mainData["trip_sections"][indexSo][index]["date_start"]);
              duration = (dateFinish.difference(dateStart))
                      .toString()
                      .split(".")
                      .sublist(0, 1)
                      .join()
                      .split(":")
                      .sublist(0, 2)
                      .join(":")
                      .toString() +
                  " hrs";
            }
            return Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          maxLines: 10,
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                text: "TRAMO " + index.toString(),
                                style: TextStyle(
                                    color: Color(CustomColor.black_medium),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                statesOsDocuments[indexSo] == "Aprobado"
                                    ? Icons.check_circle_outline
                                    : statesOsDocuments[indexSo] == "Rechazado"
                                        ? FontAwesomeIcons.timesCircle
                                        : FontAwesomeIcons.spinner,
                                color: statesOsDocuments[indexSo] == "Aprobado"
                                    ? Colors.blue
                                    : statesOsDocuments[indexSo] == "Rechazado"
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                            Container(
                              width: 5,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Documentación",
                                style: TextStyle(
                                    color: Color(CustomColor.ziyu_color)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined),
                          Column(
                            children: [
                              Text(
                                "Duración",
                                style: TextStyle(
                                  color: Color(CustomColor.grey_medium),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(duration != null ? duration : "Indefinido"),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Inicio Tramo",
                            style: TextStyle(
                              color: Color(CustomColor.grey_medium),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(dateStart != null
                              ? dateStart
                                  .toString()
                                  .split(" ")
                                  .sublist(1)
                                  .join()
                                  .split(".")
                                  .sublist(0, 1)
                                  .join()
                                  .toString()
                              : "No registrado"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Término Tramo",
                            style: TextStyle(
                              color: Color(CustomColor.grey_medium),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(dateFinish != null
                              ? dateFinish
                                  .toString()
                                  .split(" ")
                                  .sublist(1)
                                  .join()
                                  .split(".")
                                  .sublist(0, 1)
                                  .join()
                                  .toString()
                              : "No registrado"),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 30,
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget stadisticWidget(Map<String, dynamic> mainData, int indexSo) {
    int countFinishSection = 0;

    String duration;
    DateTime dateFinish, dateStart;
    if (mainData["trip_sections"][indexSo]
            [mainData["trip_sections"][indexSo].length - 1]["date_finish"] !=
        null) {
      dateFinish = DateTime.parse(mainData["trip_sections"][indexSo]
          [mainData["trip_sections"][indexSo].length - 1]["date_finish"]);
    }
    if (mainData["trip_sections"][indexSo][1]["date_start"] != null) {
      dateStart =
          DateTime.parse(mainData["trip_sections"][indexSo][1]["date_start"]);
    }
    if (dateFinish != null && dateStart != null)
      duration = (dateFinish.difference(dateStart))
              .toString()
              .split(".")
              .sublist(0, 1)
              .join()
              .split(":")
              .sublist(0, 2)
              .join(":")
              .toString() +
          " hrs";

    for (int index = 1;
        index < mainData["trip_sections"][indexSo].length;
        index++) {
      if (mainData["trip_sections"][indexSo][index]["status"] == 2) {
        countFinishSection++;
      }
    }
    int touchedIndex = -1;
    int finishTrip = 0;
    for (int i = mainData["trip_sections"][indexSo].length - 1; i >= 0; i--) {
      if (mainData["trip_sections"][indexSo][i]["date_finish"] != null) {
        finishTrip = i + 1;
        break;
      }
    }
    List<PieChartSectionData> showingSections1Sections() {
      print("finishTrip:::" + finishTrip.toString());
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
      constraints: BoxConstraints(maxHeight: 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outlined,
                    color: Colors.green,
                  ),
                  Container(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "0" + countFinishSection.toString(),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Realizados",
                        style: TextStyle(
                            color: Color(CustomColor.grey_medium),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.my_library_books_outlined,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statesOsDocuments[indexSo] == "Aprobado"
                            ? "OK"
                            : "Revisar",
                        style: TextStyle(
                            color: statesOsDocuments[indexSo] == "Aprobado"
                                ? Colors.blue
                                : Colors.red[300],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Documentos",
                        style: TextStyle(
                            color: Color(CustomColor.grey_medium),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
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
                              sections:
                                  mainData["trip_sections"][indexSo].length == 4
                                      ? showingSections3Sections()
                                      : mainData["trip_sections"][indexSo]
                                                  .length ==
                                              3
                                          ? showingSections2Sections()
                                          : showingSections1Sections()),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        ((finishTrip > 0 ? finishTrip - 1 : finishTrip) *
                                    100 /
                                    (mainData["trip_sections"][indexSo].length -
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
                  ],
                ),
              ),
              Container(
                height: 5,
              ),
              Text(
                "Cumplimiento",
                style: TextStyle(
                    color: Color(CustomColor.grey_medium), fontSize: 10),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: 0.8,
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          FontAwesomeIcons.circle,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "0" +
                            (mainData["trip_sections"][indexSo].length -
                                    1 -
                                    countFinishSection)
                                .toString(),
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Fallidos",
                        style: TextStyle(
                            color: Color(CustomColor.grey_medium),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duration != null ? duration : "No definido",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Tiempo total",
                        style: TextStyle(
                            color: Color(CustomColor.grey_medium),
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceInfo(Map<String, dynamic> mainData, int index, int addresses) {
    statesColorsDocuments = [];
    int countDocuments = 0;
    if (mainData["service_order"].serviceModel["category"] == 1) {
      //IMPORTACION
      countDocuments = 2;
    } else if (mainData["service_order"].serviceModel["category"] == 2) {
      //EXPORTACION
      countDocuments = 2;
    } else if (mainData["service_order"].serviceModel["category"] == 3) {
      //CARGA NACIONAL
      countDocuments = 1;
    } else if (mainData["service_order"].serviceModel["category"] != null) {
      //OTRO
      countDocuments = 1;
    }

    if (countDocuments == 0) {
      if (mainData["service_order"].serviceModel["category_service"] == 1) {
        //IMPORTACION
        countDocuments = 2;
      } else if (mainData["service_order"].serviceModel["category_service"] ==
          2) {
        //EXPORTACION
        countDocuments = 2;
      } else if (mainData["service_order"].serviceModel["category_service"] ==
          3) {
        //CARGA NACIONAL
        countDocuments = 1;
      } else {
        //OTRO
        countDocuments = 1;
      }
    }
    statesDocuments = [];
    if (mainData["trip_sections"] !=
        null) if (mainData["trip_sections"].length != 0)
      for (int j = 1; j <= mainData["trip_sections"][index].length; j++) {
        statesDocuments.add("Aprobado");
        statesColorsDocuments.add(Colors.grey);
        for (int i = 0; i < mainData["service_order"].documents.length; i++) {
          if (mainData["service_order"].documents[i]["order_trip_section"] ==
              j) {
            if (mainData["service_order"].documents[i]["status"] == 4) {
              statesDocuments[j - 1] = "Rechazado";
              statesColorsDocuments[j - 1] = Colors.red;
              break;
            } else if (mainData["service_order"].documents[i]["status"] == 3 &&
                mainData["service_order"].documents.length == countDocuments) {
              statesDocuments[j - 1] = "Aprobado";
              statesColorsDocuments[j - 1] = Colors.green;
            } else {
              statesDocuments[j - 1] = "Pendiente";
              statesColorsDocuments[j - 1] = Colors.grey;
            }
          }
        }
      }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mainData["sku"].principalClient != null &&
            mainData["sku"].principalClient != "")
          Container(height: 10),
        if (mainData["sku"].principalClient != null &&
            mainData["sku"].principalClient != "")
          Flexible(
            fit: FlexFit.loose,
            child: RichText(
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
                      text: "Mandante: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: mainData["sku"].principalClient,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_low)),
                  )
                ],
              ),
            ),
          ),
        Container(height: 5),
        Flexible(
          fit: FlexFit.loose,
          child: RichText(
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
                    text: "Cliente: ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: mainData["service_order"].clientName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(CustomColor.black_low)),
                )
              ],
            ),
          ),
        ),
        Container(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: _serviceInfoSegmented(mainData, index),
            ),
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!FlavorConfig.instance.values.domain.contains("plq"))
                    Transform.scale(
                      scale: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0))),
                            backgroundColor: MaterialStateProperty.all(
                              ColorsCustom.ziyu_color,
                            ),
                          ),
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(25.0),
                          // ),
                          // color: Color(CustomColor.ziyu_color),

                          onPressed: () async {
                            showModalInfo(mainData, index);
                          },

                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: "Información",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ],
        ),
        if (addresses > 1 && dropdownSO) _tripSection(mainData, 1, index),
        if (addresses > 2 && dropdownSO) _tripSection(mainData, 2, index),
        if (addresses > 3 && dropdownSO) _tripSection(mainData, 3, index),
      ],
    );
  }

  Widget _tripSection(
      Map<String, dynamic> mainData, int indexAddress, int index) {
    print("indexAddress: $indexAddress");

    if (indexAddress == 0) {
      originTrip = "TU UBICACIÓN";
      finalTrip =
          mainData["trip_sections"][index][indexAddress]["name"].toString();
      finalTrip = finalTrip.toUpperCase();
    } else {
      //originTrip = mainData.addresses[indexAddress-1];
      originTrip =
          mainData["trip_sections"][index][indexAddress - 1]["name"].toString();
      finalTrip =
          mainData["trip_sections"][index][indexAddress]["name"].toString();
      originTrip = originTrip.toUpperCase();
      finalTrip = finalTrip.toUpperCase();
    }
    List time_start, time_finish;
    String time_start2, time_finish2;
    String dayfinish;
    if (mainData["trip_sections"][index][indexAddress]["date_start"] != null) {
      time_start = mainData["trip_sections"][index][indexAddress]["date_start"]
          .split(':');
      time_start2 = time_start.sublist(0, 2).join(":").toString();
      time_start = time_start2.split('T');
      time_start2 = time_start.sublist(1, 2).join(" ").toString() + " hrs";
    } else {
      time_start2 = "No registrado";
    }
    if (mainData["trip_sections"][index][indexAddress]["date_finish"] != null) {
      time_finish = mainData["trip_sections"][index][indexAddress]
              ["date_finish"]
          .split(':');
      time_finish2 = time_finish.sublist(0, 2).join(":").toString();
      time_finish = time_finish2.split('T');
      time_finish2 = time_finish.sublist(1, 2).join(" ").toString() + " hrs";
    } else {
      time_finish2 = "No registrado";
    }
    tripSectionOrderId = indexAddress + 1;

    print(mainData["service_order"].dateClosed);
    dayfinish = mainData["service_order"]
        .dateClosed
        .toString()
        .split("-")
        .sublist(0, 3)
        .join(" ")
        .toString()
        .split(" ")
        .sublist(0, 3)
        .reversed
        .join(" / ");

    print("statesDocuments:::." + statesDocuments.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 10,
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            children: [
              TextSpan(
                text: "TRAMO " + indexAddress.toString(),
                style: TextStyle(
                    color: Color(CustomColor.black_medium),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        RichText(
          maxLines: 10,
          text: TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            children: [
              TextSpan(
                text: "   " + dayfinish.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(CustomColor.grey_medium)),
              ),
            ],
          ),
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
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
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
                                                fontSize: 11.0,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: originTrip + " > ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(CustomColor
                                                          .grey_medium)),
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
                                                  text: "Hora inicio: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(CustomColor
                                                          .black_medium)),
                                                ),
                                                TextSpan(
                                                  text: time_start2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(CustomColor
                                                          .grey_medium)),
                                                ),
                                              ],
                                            ),
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
                                                  text: "Hora fin: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(CustomColor
                                                          .black_medium)),
                                                ),
                                                TextSpan(
                                                  text: time_finish2,
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
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    RichText(
                                      maxLines: 10,
                                      text: TextSpan(
                                        // Note: Styles for TextSpans must be explicitly defined.
                                        // Child text spans will inherit styles from parent
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: statesAllDocuments[index]
                                                [indexAddress],
                                            style: TextStyle(
                                                color: statesAllColorDocuments[
                                                    index][indexAddress],
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
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
                                        FittedBox(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                //tripPage = 2;
                                                tripSectionOrderId =
                                                    indexAddress + 1;
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Container(
                                                          height: 500,
                                                          child:
                                                              DetailDocuments(
                                                            serviceOrder: mainData[
                                                                "service_order"],
                                                            tabController: widget
                                                                .tabController,
                                                            idSO: mainData[
                                                                    "service_order"]
                                                                .id,
                                                            detailSOBloc:
                                                                _detailSOBloc,
                                                            boolHomeTab: true,
                                                            tripSectionOrderId:
                                                                tripSectionOrderId,
                                                            soListTabBloc:
                                                                _soListTabBloc,
                                                            //totalTrips: mainData["trip_sections"][index].length,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              });
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
                        ],
                      ),
                    )))),
      ],
    );
  }

  Widget _serviceInfoSegmented(Map<String, dynamic> mainData, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  text: "Contenedor: ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: _soListTabBloc.containerList.length != 0
                    ? _soListTabBloc.containerList[index]
                    : "",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(CustomColor.black_low)),
              )
            ],
          ),
        ),
        Container(
          height: 5,
        ),
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
                  text: "OTIF: ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: mainData["otif_per_os"] == null
                    ? "Sin información"
                    : mainData["otif_per_os"][index]["otif_driver"] == 100.0
                        ? "En tiempo | Terminado"
                        : "Retrasado | Terminado",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(CustomColor.black_low)),
              )
            ],
          ),
        ),
        Container(
          height: 10,
        ),
      ],
    );
  }

  Widget _iconList(bool podUrlCheck) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              podUrlCheck ? Color(CustomColor.green_low) : Colors.red.shade300),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: 25.0,
      ),
    );
  }

  showDetails(int idSO) {
    inDetail = true;
    if (_scrollController.hasClients) _lastPosition = _scrollController.offset;
    int index;
    widget.hideShadowAppBar();
    for (int i = 0; i < _soListTabBloc.servicesOrderList.length; i++) {
      if (_soListTabBloc.servicesOrderList[i].id == idSO) {
        index = i;
      }
    }

    setState(() {
      AppBloc.instance.titleApp =
          _soListTabBloc.servicesOrderList[index].id.toString();
      //AppBloc.instance.changeHomeTab(2);
      //widget.tabController.index = 1;
      mainWidget = DetailSO(
        idSO: idSO,
        backFunction: goListSo,
        tabController: widget.tabController,
        serviceOrder:
            index == null ? null : _soListTabBloc.servicesOrderList[index],
        container: index == null ? null : _soListTabBloc.containerList[index],
        indexSoListTabBloc: index,
      );
    });
  }

  goListSo() {
    //widget.tabController.index = 1;
    widget.showShadowAppBar();
    if (_soListTabBloc.listResponse.length < 0 ||
        _soListTabBloc.reloadFinished) {
      setState(() {
        AppBloc.instance.changeHomeTab(0);
        mainWidget = _generateList();
        inDetail = false;
        _soListTabBloc.reloadFinished = false;
      });
    } else {
      setState(() {
        AppBloc.instance.changeHomeTab(1);
        mainWidget = _createList(_soListTabBloc.listResponse);
        inDetail = false;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(_lastPosition);
    });

    if (_soListTabBloc.listResponse?.isEmpty ?? true)
      _updateScreenAndRefresh();
    else
      updateScreen();
  }

  _updateScreenAndRefresh() async {
    await updateScreen();
    setState(() {
      AppBloc.instance.changeHomeTab(1);
      mainWidget = _createList(_soListTabBloc.listResponse);
      inDetail = false;
    });
  }
}
