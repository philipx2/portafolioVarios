import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/detail_so_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/home_tab_bloc.dart';
import 'package:ziyu_seg/src/blocs/navegation/so_list_tab_bloc.dart';
import 'package:ziyu_seg/src/components/modals/loading_screen.dart';
import 'package:ziyu_seg/src/components/modals/modal_pod.dart';
import 'package:ziyu_seg/src/components/text_button.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'package:ziyu_seg/src/utils/file_utils.dart';
import 'package:ziyu_seg/src/utils/string_utils.dart';
import 'package:ziyu_seg/src/models/navegation/service_order.dart';
import 'detail_documents.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/home_tab.dart';

import 'detail_program_content.dart';

List<String> listResultDocs = <String>[
  "",
  "Cargado",
  'No cargado',
  'Aprobado',
  'Rechazado',
  "No cargado"
];

int numberPageOS = 1;

class DetailSO extends StatefulWidget {
  final int idSO;
  final VoidCallback backFunction;
  final TabController tabController;
  ServiceOrder serviceOrder;
  final String container;
  final int indexSoListTabBloc;

  DetailSO(
      {@required this.idSO,
      @required this.backFunction,
      this.tabController,
      this.serviceOrder,
      this.container,
      this.indexSoListTabBloc});

  @override
  State<StatefulWidget> createState() => _DetailSoState();
}

class _DetailSoState extends State<DetailSO> {
  final _detailSOBloc = DetailSOBloc();
  final _soListTabBloc = SOListTabBloc();
  ServiceOrder _serviceOrder;

  @override
  void dispose() {
    _detailSOBloc.dispose();
    if (_soListTabBloc != null) _soListTabBloc.dispose();
    _soListTabBloc.getlistSO();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _detailSOBloc.initState();
    _detailSOBloc.getData(widget.idSO);
    _soListTabBloc.getlistSO();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (AppBloc.instance.showModalPOD) {
        AppBloc.instance.showModalPOD = false;
        setState(() {
          numberPageOS = 2;
        });
        //await _modalPOD();
      }
      _soListTabBloc.getlistSO();
      _detailSOBloc.getData(widget.idSO);
      setState(() {
        _generateScreen();
        if (AppBloc.instance.showDocuments) {
          AppBloc.instance.showDocuments = false;
          AppBloc.instance.refreshScreen("fromNameFunction");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _generateScreen());
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
              _serviceOrder = snapshot.data["service_order"];
              if (snapshot.data["is_program"])
                return DetailProgramContent(
                  data: snapshot.data,
                  topScreen: _topScreen(snapshot.data),
                  backButton: _backButton(),
                );
              else
                return _createScreen(snapshot.data);
            }

            return _errorScreen("Error");
        }
      },
    );
  }

  Widget _createScreen(Map<String, dynamic> data) {
    //print("_servicesOrderList of soListTabBLoc::::: " + _soListTabBloc.servicesOrderList[1].documents.toString());
    if (numberPageOS == 2) {
      return DetailDocuments(
        serviceOrder: _serviceOrder,
        detailSOBloc: _detailSOBloc,
        tabController: widget.tabController,
        idSO: widget.idSO,
        widgetTitle: _topScreen(data),
      );
    } else {
      return ListView(
        shrinkWrap: true,
        children: <Widget>[
          _topScreen(data),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15.0),
                  child: _routeElementData(data),
                ),
                if (data["date_start"].isNotEmpty ||
                    data["date_end"].isNotEmpty)
                  _deliveryDate(data["date_start"], data["date_end"]),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15.0),
                  child: _documentsWidget(_serviceOrder),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  width: double.maxFinite,
                  child: _backButton(),
                ),
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _topScreen(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(20.0),
      color: FlavorConfig.instance.color,
      child: Column(
        children: <Widget>[
          Text(
            data["id_formatted"],
            style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              data["service_name"] ?? "",
              style: TextStyle(color: Colors.white),
            ),
          ),
          _characteristics(data),
        ],
      ),
    );
  }

  Widget _deliveryDate(String dateStart, String dateEnd) {
    String dateStartFinal = dateStart != ""
        ? " $dateStart hrs."
        : "Requiere conexión para visualizar fecha de inicio.";
    String dateEndFinal = dateEnd != ""
        ? " $dateEnd hrs."
        : "Requiere conexión para visualizar fecha de entrega.";

    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Color(CustomColor.white_container),
        border: Border.all(color: Color(CustomColor.grey_low), width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            'assets/icons/calendar.svg',
            color: Color(CustomColor.black_medium),
            height: 30.0,
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FECHA SERVICIO:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_medium)),
                    ),
                    Container(
                      height: 5,
                    ),
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
                              text: "Inicio:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(CustomColor.black_medium))),
                          TextSpan(
                              text: dateStartFinal,
                              style: TextStyle(
                                  color: Color(CustomColor.grey_medium_2))),
                        ],
                      ),
                    ),
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
                              text: "Término:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(CustomColor.black_medium))),
                          TextSpan(
                              text: dateEndFinal,
                              style: TextStyle(
                                  color: Color(CustomColor.grey_medium_2))),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _documentsWidget(ServiceOrder serviceOrder) {
    List<dynamic> documents;
    if (serviceOrder != null) {
      if (serviceOrder.documents != null) {
        documents = serviceOrder.documents ?? serviceOrder.documents;
      }
    }
    //print("listBoolDOcuments::" + listBoolDocuments.toString());
    //documents ?? print("documentsWidget, documents::::::" + documents.toString());
    listBoolDocuments = List.filled(list.length, false, growable: true);
    if (documents != null) {
      for (int i = 0; i < documents.length; i++) {
        for (int j = 0; j < list.length; j++) {
          if (documents[i]["document_definition"] == list[j]) {
            listBoolDocuments[j] = true;
          }
        }
      }
    }

    List<String> list4 = [];
    list4.add(list[0]);
    print("serviceOrder:::::::::::::::::::::::::" + serviceOrder.toString());
    print("serviceOrder.serviceModel" + serviceOrder.serviceModel.toString());
    if (serviceOrder.serviceModel["category"] == 1) {
      //IMPORTACION
      list4.add(list[1]);
      list4.add(list[3]);
    } else if (serviceOrder.serviceModel["category"] == 2) {
      //EXPORTACION
      list4.add(list[1]);
      list4.add(list[2]);
    } else if (serviceOrder.serviceModel["category"] == 3) {
      //CARGA NACIONAL
      list4.add(list[1]);
    } else if (serviceOrder.serviceModel["category"] != null) {
      //OTRO
      list4.add(list[1]);
    }

    if (list4.length == 1) {
      if (serviceOrder.serviceModel["category_service"] == 1) {
        //IMPORTACION
        list4.add(list[1]);
        list4.add(list[3]);
      } else if (serviceOrder.serviceModel["category_service"] == 2) {
        //EXPORTACION
        list4.add(list[1]);
        list4.add(list[2]);
      } else if (serviceOrder.serviceModel["category_service"] == 3) {
        //CARGA NACIONAL
        list4.add(list[1]);
      } else {
        //OTRO
        list4.add(list[1]);
      }
    }
    print("list4:length::::" + list4.length.toString());
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(CustomColor.white_container),
        border: Border.all(color: Color(CustomColor.grey_low), width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            'assets/icons/file-text.svg',
            color: Color(CustomColor.black_medium),
            height: 30.0,
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DOCUMENTOS:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(CustomColor.black_medium)),
                    ),
                    Container(
                      height: 5,
                    ),
                    //EN CASO DE USAR TODOS LOS DOCUMENTOS:
                    ListView.builder(
                      itemCount: list4.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        print("list4:length::::" + list4.length.toString());
                        int indexDocuments;
                        print("_serviceOrder.documents" +
                            _serviceOrder.documents.toString());
                        for (int i = 0;
                            i < _serviceOrder.documents.length;
                            i++) {
                          if (_serviceOrder.documents[i]
                                  ["document_definition"] ==
                              list4[index]) {
                            if (_serviceOrder.documents[i]["status"] != 2 &&
                                _serviceOrder.documents[i]["status"] != 5) {
                              indexDocuments = i;
                            }
                          }
                        }
                        int indexStatus;

                        if (indexDocuments != null)
                          indexStatus =
                              _serviceOrder.documents[indexDocuments]["status"];

                        if (index != 0) {
                          return RichText(
                            text: TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: list4[index] + ": ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color:
                                            Color(CustomColor.black_medium))),
                                if (indexDocuments != null && indexStatus != 5)
                                  TextSpan(
                                      text: listResultDocs[indexStatus],
                                      style: indexStatus != 3
                                          ? indexStatus == 4
                                              ? TextStyle(color: Colors.red)
                                              : TextStyle(
                                                  color: Color(
                                                      CustomColor.ziyu_color))
                                          : TextStyle(color: Colors.green)),
                                if (indexDocuments == null)
                                  TextSpan(
                                      text: "No cargado",
                                      style: TextStyle(
                                          color: Color(
                                              CustomColor.grey_medium_2))),
                                if (indexStatus == 5)
                                  TextSpan(
                                      text: "No cargado",
                                      style: TextStyle(
                                          color: Color(
                                              CustomColor.grey_medium_2))),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _routeElementData(Map<String, dynamic> data) {
    return Container(
        decoration: BoxDecoration(
          color: Color(CustomColor.white_container),
          border: Border.all(color: Color(CustomColor.grey_low), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
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
                    child: _routeElementContent(
                        data["sku_type"], data['rute_name'], widget.container)),
              )
            ],
          ),
        ));
  }

  Widget _routeElementContent(
      int skuType, String ruteName, String containerId) {
    final listWidget = List<Widget>();

    listWidget.add(Text(
      "DATOS SERVICIO:",
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Color(CustomColor.black_medium)),
    ));
    listWidget.add(Container(
      height: 5,
    ));
    listWidget.add(Row(
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "Contenedor: ",
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Color(CustomColor.black_medium))),
                TextSpan(
                    text: containerId,
                    style: TextStyle(color: Color(CustomColor.grey_medium_2))),
              ],
            ),
          ),
        ),
      ],
    ));
    if (ruteName != '' && ruteName.split('-').length > 0) {
      final name = ruteName.split('-')[0];
      listWidget.add(Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: "Zona de inicio: ",
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(CustomColor.black_medium))),
                  TextSpan(
                      text: name,
                      style:
                          TextStyle(color: Color(CustomColor.grey_medium_2))),
                ],
              ),
            ),
          ),
        ],
      ));
      String name2 = ruteName.split('-')[0];
      if (ruteName.split('-').length > 1) {
        name2 = ruteName.split('-')[1];
      }
      listWidget.add(Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: "Zona de término: ",
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(CustomColor.black_medium))),
                  TextSpan(
                      text: name2,
                      style:
                          TextStyle(color: Color(CustomColor.grey_medium_2))),
                ],
              ),
            ),
          ),
        ],
      ));
    } else {
      listWidget.add(Row(
        children: <Widget>[
          Expanded(
              child: Text(
            "Error: requiere conexión para visualizar rutas.",
            style: TextStyle(color: Color(CustomColor.black_medium)),
          ))
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listWidget,
    );
  }

  Widget _characteristics(Map<String, dynamic> data) {
    final commentExist = !emptyString(_detailSOBloc.serviceOrder?.comment);
    final existImageServer =
        !emptyString(_detailSOBloc.podUrl) || _detailSOBloc.existImage;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: SvgPicture.asset(
                    'assets/icons/check.svg',
                    height: 25.0,
                    color: Colors.white,
                  ),
                ),
                Container(height: 10.0),
                Text(
                  data["is_program"]
                      ? "Programa\nfinalizado"
                      : "Servicio\nfinalizado",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Column(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.55),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 22.0,
                    ),
                    Text(
                      data["score"]?.toString() ?? "-",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    )
                  ],
                ),
              ),
              Container(height: 10.0),
              Text(
                "Score\nobtenido",
                textAlign: TextAlign.center,
                maxLines: 2,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ]),
            GestureDetector(
              onTap: podButtonAction,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(3.0),
                    child: SvgPicture.asset(
                      'assets/icons/file-text.svg',
                      color: Colors.white,
                      height: 30.0,
                    ),
                  ),
                  Container(height: 10.0),
                  Text(
                    "Documentos",
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  textButton(
                    text: "Adjuntos",
                    //text: commentExist || existImageServer || _detailSOBloc.serviceOrder.documents!=null
                    //? "Ver adjunto" : "Adjuntar",
                    color: Colors.white,
                    size: 14.0,
                    onTap: podButtonAction,
                  )
                ],
              ),
            ),
          ],
        ));
  }

  podButtonAction() async {
    dropdownValue = list.first;
    if (widget.serviceOrder == null) {
      widget.serviceOrder = _detailSOBloc.serviceOrder;
    }
    print("_serviceOrder.documents.length:::::" +
        _serviceOrder.documents.length.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 500,
              child: DetailDocuments(
                serviceOrder: _serviceOrder,
                detailSOBloc: _detailSOBloc,
                tabController: widget.tabController,
                idSO: widget.idSO,
                tripSectionOrderId: null,
                totalTrips: (_serviceOrder.documents.length / 2).truncate(),
                boolDropDown: true,
              ),
            );
          },
        );
      },
    );
    /*setState(() {
      numberPageOS = 2;
    });*/
    //return DetailDocuments();
    //_modalPOD();
  }

  Widget _backButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Color(CustomColor.black_medium),
        ),
      ),
      // color: Color(CustomColor.black_medium),
      onPressed: () {
        widget.tabController.index--;
        widget.backFunction;
        print("tripPage:::: 10      ");
        tripPage = 0;
        numberPageOS = 1;
        AppBloc.instance.titleApp = "ZiYU";
      },
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(25.0),
      // ),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Text("Cerrar",
            style: TextStyle(fontSize: 20.0, color: Colors.white)),
      ),
    );
  }

  _modalPOD() async {
    AppBloc.instance.isModalPODOpen = true;
    print("pasa por modalPOD");
    dropdownValue = list.first;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalPODContent(
          tabController: widget.tabController,
          serviceOrder: widget.serviceOrder,
          pod: _detailSOBloc.documentFile,
          podUrl: widget.serviceOrder?.documentPath,
          comment: widget.serviceOrder?.comment,
          onSubmitData: (File podFile, String comment, int index) async {
            loadingScreen(context);
            //print(" _detailSOBloc.serviceOrder.documents::: " +  _detailSOBloc.serviceOrder.documents.toString());
            //print(" _detailSOBloc.serviceOrder.documents.documentId::: " +  _detailSOBloc.serviceOrder.documents.documentId.toString());
            /*_detailSOBloc.serviceOrder.documents.setComment
            _detailSOBloc.serviceOrder.documents.documentId = index;
            _detailSOBloc.serviceOrder.documents.file = podFile;
            _detailSOBloc.serviceOrder.documents.fileBackup = podFile;
            _detailSOBloc.serviceOrder.documents.title = " ";
            print(" _detailSOBloc.serviceOrder.documents::: " +  _detailSOBloc.serviceOrder.documents.toString());
            print("_detailSOBloc.serviceOrder.documents.documentId::::" + _detailSOBloc.serviceOrder.documents.documentId.toString());*/

            final response = await _detailSOBloc.savePOD(
              podFile,
              comment,
              false,
              index,
              1,
              widget.serviceOrder,
            );
            AppBloc.instance.identificationService = widget.idSO;
            AppBloc.instance.showDocuments = true;
            setState(() {
              _detailSOBloc.getData(widget.idSO);
            });
            Navigator.pop(context, true);

            return response;
          },
        );
      },
    );
  }

  Widget _errorScreen(String error) {
    return Center(
      child: InkWell(
        onTap: () async {
          loadingScreen(context);
          await _detailSOBloc.getData(widget.idSO);
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
}

Widget deliveryDate(String dateStart, String dateEnd) {
  String dateStartFinal = dateStart != ""
      ? " $dateStart hrs."
      : "Requiere conexión para visualizar fecha de inicio.";
  String dateEndFinal = dateEnd != ""
      ? " $dateEnd hrs."
      : "Requiere conexión para visualizar fecha de entrega.";

  return Container(
    padding: EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Color(CustomColor.white_container),
      border: Border.all(color: Color(CustomColor.grey_low), width: 1.5),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    child: Row(
      children: <Widget>[
        SvgPicture.asset(
          'assets/icons/calendar.svg',
          color: Color(CustomColor.black_medium),
          height: 30.0,
        ),
        Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FECHA SERVICIO:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_medium)),
                  ),
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
                            text: "Inicio:",
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(CustomColor.black_medium))),
                        TextSpan(
                            text: dateStartFinal,
                            style: TextStyle(
                                color: Color(CustomColor.grey_medium_2))),
                      ],
                    ),
                  ),
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
                            text: "Término:",
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(CustomColor.black_medium))),
                        TextSpan(
                            text: dateEndFinal,
                            style: TextStyle(
                                color: Color(CustomColor.grey_medium_2))),
                      ],
                    ),
                  ),
                ],
              )),
        )
      ],
    ),
  );
}
