import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ziyu_seg/src/components/icon_notification.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/models/milestones/documentList.dart';
import 'package:ziyu_seg/src/repositories/device_repository.dart';
import 'package:ziyu_seg/src/repositories/mileston/document_repository.dart';
import 'package:ziyu_seg/src/repositories/user_repository.dart';
import 'package:ziyu_seg/src/screens/camera/camera_screen.dart';
import 'package:ziyu_seg/src/screens/camera/signature.dart';
import 'package:ziyu_seg/src/screens/navegation/home_screen.dart';
import 'package:ziyu_seg/src/screens/navegation/so_list_tab.dart';
import 'package:ziyu_seg/src/services/shared_preferences.dart';
import 'package:ziyu_seg/src/utils/UrlToFile.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'package:ziyu_seg/src/utils/file_utils.dart';
import 'package:ziyu_seg/src/utils/permissions_utils.dart';
import 'package:ziyu_seg/src/models/navegation/service_order.dart';
import 'package:ziyu_seg/src/blocs/navegation/detail_so_bloc.dart';
import 'package:ziyu_seg/src/screens/navegation/detail_so/detail_so.dart';
import 'package:ziyu_seg/src/blocs/app_bloc.dart';
import 'package:ziyu_seg/src/components/modals/modal_pod.dart';
import 'package:ziyu_seg/src/components/image_network.dart';
import 'package:ziyu_seg/src/utils/string_utils.dart';
import 'package:ziyu_seg/src/repositories/nav/service_order_repository.dart';
import 'package:ziyu_seg/src/blocs/navegation/so_list_tab_bloc.dart';
import 'package:ziyu_seg/src/components/modals/loading_screen.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/home_tab.dart';
import 'package:ziyu_seg/src/models/navegation/trip_sections.dart';

import 'package:ziyu_seg/src/services/api/api_provider.dart';
import 'package:ziyu_seg/src/services/api/urls.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:ziyu_seg/src/components/error_default.dart';

List<List<dynamic>> listFileAndType;
List<bool> boolSignature;

List<String> listResultDocs = <String>[
  "",
  "En espera de revisión",
  'Cancelado por el usuario',
  'Aprobado',
  'Rechazado',
];

List<String> trips = [];
String dropdownValue2;

class DetailDocuments extends StatefulWidget {
  static const identifier = '/MilestonesAddScreen';
  final List data;
  File pod;
  String podUrl;
  String comment;
  DetailSOBloc detailSOBloc;
  TabController tabController;
  ServiceOrder serviceOrder;
  int idSO;
  bool boolHomeTab;
  int tripSectionOrderId;
  SOListTabBloc soListTabBloc;
  Widget widgetTitle;
  int totalTrips;
  bool boolDropDown;

  DetailDocuments(
      {this.data,
      this.pod,
      this.podUrl,
      this.comment,
      this.serviceOrder,
      this.detailSOBloc,
      this.tabController,
      this.idSO,
      this.boolHomeTab,
      this.tripSectionOrderId,
      this.soListTabBloc,
      this.widgetTitle,
      this.totalTrips,
      this.boolDropDown = false});
  @override
  _DetailDocumentsState createState() => _DetailDocumentsState();
}

class _DetailDocumentsState extends State<DetailDocuments> {
  var images = [];
  var deletImages = [];
  var first = 0;
  var indexs = [];
  var commetAlert = '';
  final imagePicker = ImagePicker();
  final textController = TextEditingController();
  var textController1 = TextEditingController();
  var textController2 = TextEditingController();
  var textController3 = TextEditingController();

  String currentLocation;

  bool existImage;
  final commentController = TextEditingController();
  final meterEndController = TextEditingController();
  Size sizeScreen;
  bool validForm = false;
  bool _firstRendering = true;
  bool _visibleKeyBoard = false;
  bool commentServerExist;
  bool existImageServer;
  File podFile;
  String imageUrl;
  final apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
    dropdownValue2 = "Tramo 1";
    tripSectionOrderId = 2;
    boolSignature = null;
  }

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    trips = [];
    if (widget.totalTrips != null) {
      for (int i = 1; i < widget.totalTrips; i++) {
        trips.add("Tramo " + (i).toString());
      }
    }
    if (tripSectionOrderId == null) {
      tripSectionOrderId = 2;
    }
    if (widget.tripSectionOrderId != null) {
      //tripSectionOrderId = widget.tripSectionOrderId;
    }
    print("trips:::" + trips.toString());

    return Scaffold(
        backgroundColor: Colors.black54,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _topper(),
            Expanded(child: _milestonesContent()),
            if (widget.serviceOrder.serviceModel != null) _buttons()
          ],
        ));
  }

  Container _topper() {
    return Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )),
        padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        height: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: widget.tripSectionOrderId == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          children: [
            if (widget.boolDropDown)
              Expanded(
                child: DropdownButtonHideUnderline(
                    child: Center(
                  child: DropdownButton<String>(
                    isDense: true,
                    value: dropdownValue2,
                    dropdownColor: Colors.white,
                    hint: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Selecciona tipo de documento",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                        color: Color(CustomColor.black_low),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue2 = newValue;
                        tripSectionOrderId = trips.indexOf(dropdownValue2) + 2;
                        print("tripSectionOrderId:::" +
                            tripSectionOrderId.toString());
                        widget.tripSectionOrderId = tripSectionOrderId;
                      });
                    },
                    items: trips.map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )),
              ),
            if (!widget.boolDropDown)
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Center(
                        child: Text(
                      "ID " +
                          widget.serviceOrder.id
                              .toString(), //"Tramo " + (widget.tripSectionOrderId - 1).toString(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ));
                  },
                ),
              ),
            arrowBack(),
          ],
        ));
  }

  Widget arrowBack() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.black,
        onPressed: () async {
          print("widget.idSO::::: " + widget.idSO.toString());
          setState(() {
            textController1.clear();
            textController2.clear();
            textController3.clear();
            /*AppBloc.instance.backDetailSO = true;
            AppBloc.instance.identificationService = widget.serviceOrder.id;
            
            AppBloc.instance.showDocuments = true;
            AppBloc.instance.refreshApp();*/
            print("tripPage::: " + tripPage.toString());
            print("widget.boolHomeTab::::" + widget.boolHomeTab.toString());
            print("en botton arrow_back, numberPageOS:::: " +
                numberPageOS.toString());
          });
          if (widget.boolHomeTab == true && !widget.boolDropDown) {
            print("tripPage:::: 4      ");
            tripPage = 0;
          }
          if (widget.boolDropDown) {
            tripSectionOrderId = 2;
          }
          setState(() {
            AppBloc.instance.titleApp = "ZiYU";
          });
          Navigator.pop(context);
          if (widget.comment != null) {
            widget.soListTabBloc.getlistSO();

            AppBloc.instance.refreshScreen("fromNameFunction");
          }
        },
      ),
    );
  }

  Widget dropDownButton() {
    int indexaux;

    return DropdownButtonHideUnderline(
        child: Center(
      child: DropdownButton<String>(
        isDense: true,
        value: dropdownValue2,
        dropdownColor: Colors.white,
        hint: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Selecciona tipo de documento",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        style: const TextStyle(
            color: Color(CustomColor.black_low),
            fontSize: 16,
            fontWeight: FontWeight.bold),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue2 = newValue;
            tripSectionOrderId = trips.indexOf(dropdownValue2) + 1;
            widget.tripSectionOrderId = tripSectionOrderId;
          });
        },
        items: trips.map<DropdownMenuItem<String>>((dynamic value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Text(value),
              ],
            ),
          );
        }).toList(),
      ),
    ));
  }

  Container _dropDown() {
    List<TextEditingController> listTextController = <TextEditingController>[
      textController1,
      textController2,
      textController3,
    ];
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              if (widget.boolHomeTab == true) {
                print("tripPage:::: 5      ");
                tripPage = 0;
                if (widget.boolDropDown) {
                  tripPage = 0;
                }
                await AppBloc.instance.refreshScreen("boton cancelar");
              }
              setState(() {
                numberPageOS = 1;
                /*AppBloc.instance.backDetailSO = true;
                AppBloc.instance.identificationService = widget.serviceOrder.id;
                
                AppBloc.instance.showDocuments = true;
                AppBloc.instance.refreshApp();*/
                print("en botton Cancelar, numberPageOS:::: " +
                    numberPageOS.toString());
              });
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.grey[200],
              ),
            ),
            // color: Colors.grey[200],
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          ),
          ElevatedButton(
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: () async {
              print("guarda aca 1");
              if (!FlavorConfig.instance.values.domain.contains("plq")) {
                loadingScreen(context);
                print("images::::: " + images.toString());
                for (int i = 0; i < images.length; i++) {
                  //File pod = await pathToImage(listFileAndType[i][1]);
                  print("images.length:::" + images.length.toString());
                  print("images[i]:::" + images[i].toString());
                  File imagesPath = File(images[i][1]);

                  print(
                      "listTextController[list.indexOf(images[i][0])-1].text:::::" +
                          listTextController[list.indexOf(images[i][0]) - 1]
                              .text
                              .toString());
                  //savePOD(File image precharged, obs x Doc, nameofDoc)

                  widget.tripSectionOrderId = tripSectionOrderId;
                  print("boolSignature::::::" + boolSignature.toString());
                  print("widget.tripSectionOrderId:::::1::" +
                      widget.tripSectionOrderId.toString());
                  var response = await widget.detailSOBloc.savePOD(
                      imagesPath,
                      listTextController[list.indexOf(images[i][0]) - 1].text,
                      boolSignature[list.indexOf(images[i][0])],
                      list.indexOf(images[i][0]),
                      widget.tripSectionOrderId,
                      widget.serviceOrder);
                  listTextController[list.indexOf(images[i][0]) - 1].text = "";
                  listTextController[list.indexOf(images[i][0]) - 1].clear();
                  if (response) {
                    print("POD " + images[i][0] + " cargado con éxito");

                    //AppBloc.instance.refreshScreen("prueba setState");
                  } else if (response == false) {
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 4),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message:
                          "Error de conexión. Se guardará su documento cuando tenga acceso a internet",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context);
                  }
                }
                if (widget.comment == null) {
                  await widget.detailSOBloc
                      .getData(widget.idSO, fromInternet: true);
                }
                if (widget.soListTabBloc != null) {
                  await widget.soListTabBloc.getlistSO();
                }
                if (widget.boolHomeTab == true) {
                  print("tripPage:::: 7      ");
                  tripPage = 0;
                  if (widget.boolDropDown) {
                    tripPage = 0;
                  }
                }
                Navigator.pop(context);
                setState(() {
                  images = [];
                  numberPageOS = 0;

                  //AppBloc.instance.backDetailSO = true;
                  //AppBloc.instance.identificationService = widget.serviceOrder.id;

                  //AppBloc.instance.refreshApp();
                });
                Navigator.pop(context);
                await AppBloc.instance.refreshScreen("boton guardar");
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                FlavorConfig.instance.color,
              ),
            ),
            // color: FlavorConfig.instance.color,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          )
        ],
      ),
    );
  }

  _milestonesAll() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Opacity(
          child: Container(
            child: widget.widgetTitle,
          ),
          opacity: 0.5,
        ),
        Positioned(bottom: 50, child: _milestonesContent()),
      ],
    );
  }

  _milestonesTitle() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: _icon(),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 30),
                    child: FittedBox(
                      child: Text(
                        'Carga de documentos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 30),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: FittedBox(
                        child: Text(
                          'Adjunta fotografía del documento',
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        color: FlavorConfig.instance.color,
      ),
    );
  }

  Column _icon() {
    var index;
    if (widget.serviceOrder.documents == null) {
      index = 1;
    } else {
      index = widget.serviceOrder.documents.length;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: 2,
          height: 25,
          color: Colors.white,
        ),
      ],
    );
  }

  _milestonesContent() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: widget.serviceOrder.serviceModel != null
          ? _content()
          : ErrorDefault(
              "Revise su conexión a internet para visualizar sus documentos y vuelva a entrar.",
              tryagain: false,
            ),
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  _content() {
    _function() {
      List list3 = list;
      print("list3:::::" + list3.toString());
      if (list3.length > 1 || list3.length == 1) {
        /*if (list3[0].comment != '' && first == 0) {
          first = first + 1;
          textController.text = list3[0].comment;
        }*/
        Map<String, dynamic> doc2;
        listFileAndType = [];
        List<TextEditingController> listTextController =
            <TextEditingController>[
          textController1,
          textController2,
          textController3,
        ];
        List<String> list4 = [];
        //Categories = (
        //(IMPORT, 'Importación'),
        //(EXPORT, 'Exportación'),
        //(NATIONAL, 'Carga nacional'),
        //(OTHER, 'Otro'),
        list4.add(list3[0]);
        if (widget.serviceOrder.serviceModel["category"] == 1) {
          //IMPORTACION
          list4.add(list3[1]);
          list4.add(list3[3]);
        } else if (widget.serviceOrder.serviceModel["category"] == 2) {
          //EXPORTACION
          list4.add(list3[1]);
          list4.add(list3[2]);
        } else if (widget.serviceOrder.serviceModel["category"] == 3) {
          //CARGA NACIONAL
          list4.add(list3[1]);
        } else if (widget.serviceOrder.serviceModel["category"] != null) {
          //OTRO
          list4.add(list3[1]);
        }

        if (list4.length == 1) {
          print("PASA POR CATEGORY_SERVICE");
          print("category_service:::" +
              widget.serviceOrder.serviceModel["category_service"].toString());
          if (widget.serviceOrder.serviceModel["category_service"] == 1) {
            //IMPORTACION
            list4.add(list3[1]);
            list4.add(list3[3]);
          } else if (widget.serviceOrder.serviceModel["category_service"] ==
              2) {
            //EXPORTACION
            list4.add(list3[1]);
            list4.add(list3[2]);
          } else if (widget.serviceOrder.serviceModel["category_service"] ==
              3) {
            //CARGA NACIONAL
            list4.add(list3[1]);
          } else {
            //OTRO
            if (FlavorConfig.instance.values.domain.contains("plq")) {
              list4.add("POD");
            } else {
              list4.add(list3[1]);
            }

            //list4.add("POD");
          }
        }
        if (boolSignature == null)
          boolSignature = List.filled(list.length, false, growable: true);
        print("list4:::::" + list4.toString());
        print("j = widget.serviceOrder.documents::::" +
            widget.serviceOrder.documents.toString());
        //print("widget.serviceOrder.documents.map::::" + widget.serviceOrder.documents.map((doc2)).toString());
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: list4.map((doc) {
            int indexDocuments;
            bool boolSignatureConfirm;
            print("tripSectionOrderId:::::::::::::::::::::::::" +
                tripSectionOrderId.toString());
            if (!FlavorConfig.instance.values.domain.contains("plq")) {
              for (int i = 0; i < widget.serviceOrder.documents.length; i++) {
                for (int j = 0; j < list4.length; j++) {
                  if (widget.serviceOrder.documents[i]["document_definition"] ==
                      doc) {
                    if (widget.serviceOrder.documents[i]["status"] == 2) {
                      widget.serviceOrder.documents[i]["file"] = null;
                    }
                    if (widget.serviceOrder.documents[i]
                            ["order_trip_section"] ==
                        tripSectionOrderId) {
                      print("pasa por aca indexDocument= $i");
                      indexDocuments = i;
                      break;
                    } else if (widget.serviceOrder.documents[i]
                            ["order_trip_section"] ==
                        null) {
                      print("pasa por aca indexDocument= $i   el otro 2");
                      indexDocuments = i;
                      break;
                    }
                  }
                }
              }
            }
            //print("widget.serviceOrder.documents::::" + widget.serviceOrder.documents.toString());
            if (indexDocuments != null)
              print("widget.serviceOrder.documents[indexDocuments]:::::" +
                  widget.serviceOrder.documents[indexDocuments].toString());
            int indexImage;
            for (int i = 0; i < images.length; i++) {
              //print("images[i][0]::::" + images[i][0]);
              if (images[i][0] == doc) {
                indexImage = i;
                break;
              }
            }
            bool boolPlus = true;
            String auxFile;
            if (indexDocuments != null)
              auxFile = widget.serviceOrder.documentFinalUrl(
                  widget.serviceOrder.documents[indexDocuments]["file"]);
            if (FlavorConfig.instance.values.domain.contains("plq")) {
              auxFile = widget.serviceOrder
                  .documentFinalUrl(widget.serviceOrder.podUrl);
              print("auxFile:::" + auxFile.toString());
            }
            if (indexImage != null || auxFile != null) {
              print("pasa por bool = false");
              boolPlus = false;
            }
            if (FlavorConfig.instance.values.domain.contains("plq") &&
                widget.serviceOrder.podFinalUrl != null) {
              print("pasa por bool = false 2");
              boolPlus = false;
            }
            String stateDocuments;
            if (indexDocuments != null) {
              if (widget.serviceOrder.documents[indexDocuments]["comment"] !=
                  null) {
                if (widget.serviceOrder.documents[indexDocuments]["status"] !=
                    0) {
                  stateDocuments = listResultDocs[
                      widget.serviceOrder.documents[indexDocuments]["status"]];
                } else {
                  print("stateDocuments...pasa por aca1");
                  stateDocuments = "Documentos faltantes";
                }
              } else {
                print("stateDocuments...pasa por aca2");
                stateDocuments = "Documentos faltantes";
              }
            } else {
              print("stateDocuments...pasa por aca3");
              if (FlavorConfig.instance.values.domain.contains("plq")) {
                stateDocuments = "Documento asociado";
              } else {
                stateDocuments = "Documentos faltantes";
              }
            }

            if (indexImage != null &&
                !FlavorConfig.instance.values.domain.contains("plq")) {
              setState(() {
                boolSignatureConfirm =
                    boolSignature[list.indexOf(images[indexImage][0])];
              });

              print("boolSignatureConfirm ::: " +
                  boolSignatureConfirm.toString());
            } else if (indexDocuments != null) {
              boolSignatureConfirm =
                  widget.serviceOrder.documents[indexDocuments]["signed"];
              if (widget.serviceOrder.documents[indexDocuments]["status"] ==
                  3) {
                boolSignatureConfirm = true;
              }
            } else {
              boolSignatureConfirm = false;
            }
            print("indexDocuments::" + indexDocuments.toString());
            if (doc != list4[0]) {
              print("widget.serviceOrder.documents::::::::::::::" +
                  widget.serviceOrder.documents.toString());
              if (indexDocuments != null) {
                if (!FlavorConfig.instance.values.domain
                        .contains("preprod.ziyu") &&
                    !FlavorConfig.instance.values.domain
                        .contains("preprod.ziyu")) if (widget
                            .serviceOrder.documents[indexDocuments]
                        ["order_trip_section"] ==
                    null) {
                  widget.serviceOrder.documents.removeAt(indexDocuments);
                }
              }
              return Container(
                  height: 190,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        stateDocuments == "Documento asociado"
                            ? FontAwesomeIcons.fileImport
                            : indexDocuments == null
                                ? FontAwesomeIcons.fileImport
                                : widget.serviceOrder.documents[indexDocuments]
                                            ["status"] ==
                                        3
                                    ? FontAwesomeIcons.fileCircleCheck
                                    : widget.serviceOrder
                                                    .documents[indexDocuments]
                                                ["status"] ==
                                            1
                                        ? FontAwesomeIcons.spinner
                                        : FontAwesomeIcons
                                            .fileCircleExclamation,
                        color: stateDocuments == "Documento asociado"
                            ? Colors.orange
                            : indexDocuments == null
                                ? Colors.red
                                : widget.serviceOrder.documents[indexDocuments]
                                            ["status"] ==
                                        3
                                    ? Colors.green
                                    : widget.serviceOrder
                                                    .documents[indexDocuments]
                                                ["status"] ==
                                            1
                                        ? Colors.grey
                                        : Colors.red,
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: doc,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: stateDocuments,
                                    style: stateDocuments ==
                                            "Documento asociado"
                                        ? TextStyle(
                                            color: Colors.orange, fontSize: 14)
                                        : indexDocuments == null
                                            ? TextStyle(
                                                color: Colors.red, fontSize: 14)
                                            : widget.serviceOrder.documents[
                                                            indexDocuments]
                                                        ["status"] ==
                                                    3
                                                ? TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 14)
                                                : widget.serviceOrder.documents[
                                                                indexDocuments]
                                                            ["status"] ==
                                                        1
                                                    ? TextStyle()
                                                    : TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (indexDocuments == null &&
                                    FlavorConfig.instance.values.domain
                                        .contains("preprod.ziyu") &&
                                    indexImage == null)
                                  Expanded(
                                    child: Container(),
                                    flex: 3,
                                  ),
                                if (indexDocuments != null)
                                  if (widget.serviceOrder
                                              .documents[indexDocuments]
                                          ["status"] !=
                                      2)
                                    Expanded(
                                      flex: 3,
                                      child: _milestoneDocument(
                                          widget.serviceOrder
                                              .documents[indexDocuments],
                                          indexDocuments),
                                    ),
                                if (indexDocuments == null &&
                                    indexImage != null &&
                                    !FlavorConfig.instance.values.domain
                                        .contains("plq"))
                                  Expanded(
                                    flex: 3,
                                    child: _milestoneImages(images, indexImage),
                                  ),
                                if (FlavorConfig.instance.values.domain
                                        .contains("plq") &&
                                    indexImage == null)
                                  Expanded(
                                    flex: 3,
                                    child: _milestoneDocument({
                                      "file": widget.serviceOrder.podUrl,
                                      "document_definition": "POD",
                                      "comment": null,
                                    }, indexDocuments),
                                  ),
                                if (FlavorConfig.instance.values.domain
                                        .contains("plq") &&
                                    indexImage != null)
                                  Expanded(
                                    flex: 3,
                                    child: _milestoneImages(images, indexImage),
                                  ),
                                if (!FlavorConfig.instance.values.domain
                                        .contains("plq") &&
                                    !FlavorConfig.instance.values.domain
                                        .contains("preprod.ziyu"))
                                  if (indexDocuments != null ||
                                      indexImage != null)
                                    if (boolSignatureConfirm != null)
                                      Expanded(
                                        flex: 3,
                                        child: Container(),
                                      ),
                                if (boolSignatureConfirm != true &&
                                    !boolPlus &&
                                    !FlavorConfig.instance.values.domain
                                        .contains("plq"))
                                  Expanded(
                                    flex: 3,
                                    child: TextButton(
                                      style: ButtonStyle(
                                          alignment: Alignment.centerRight),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              color: ColorsCustom.ziyu_color),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: "Firmar",
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () async {
                                        var fileImg;
                                        Future<File> urlToFile(
                                            String imageUrl) async {
                                          var rng = new Random();
                                          Directory tempDir =
                                              await getTemporaryDirectory();
                                          String tempPath = tempDir.path;
                                          File file = new File('$tempPath' +
                                              (rng.nextInt(100)).toString() +
                                              '.png');
                                          http.Response response = await http
                                              .get(Uri.parse(imageUrl));
                                          await file
                                              .writeAsBytes(response.bodyBytes);
                                          return file;
                                        }

                                        if (indexImage != null) {
                                          fileImg = FileImage(
                                              File(images[indexImage][1]));
                                        } else if (indexDocuments != null) {
                                          var aux = ImageNetwork(widget
                                              .serviceOrder
                                              .documentFinalUrl(widget
                                                      .serviceOrder
                                                      .documents[indexDocuments]
                                                  ["file"]));
                                          fileImg = FileImage(
                                              await urlToFile(aux.url));
                                        }
                                        String resp = await Navigator.of(
                                                context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    SignatureScreen(
                                                        imageBackround: fileImg,
                                                        indexImage: indexImage !=
                                                                null
                                                            ? indexImage
                                                            : indexDocuments)));
                                        if (resp != null) {
                                          if (indexImage != null) {
                                            final val = [
                                              images[indexImage][0],
                                              resp
                                            ];

                                            setState(() {
                                              print("boolSignature::::list:::" +
                                                  list.toString());
                                              boolSignature[list.indexOf(
                                                      images[indexImage][0])] =
                                                  true;
                                              print("boolSignature:::::" +
                                                  boolSignature.toString());
                                              images.removeAt(indexImage);
                                              images.add(val);
                                            });
                                          } else {
                                            loadingScreen(context);
                                            //savePOD(File image precharged, obs x Doc, nameofDoc)
                                            if (widget.tripSectionOrderId ==
                                                null) {
                                              widget.tripSectionOrderId =
                                                  tripSectionOrderId;
                                            }
                                            await widget.detailSOBloc.savePOD(
                                                File(resp),
                                                widget.serviceOrder.documents[
                                                    indexDocuments]["comments"],
                                                true,
                                                list.indexOf(
                                                    widget.serviceOrder
                                                                .documents[
                                                            indexDocuments][
                                                        "document_definition"]),
                                                widget.tripSectionOrderId,
                                                widget.serviceOrder);

                                            //await widget.detailSOBloc.getData(widget.idSO, fromInternet: true);

                                            if (widget.soListTabBloc != null) {
                                              await widget.soListTabBloc
                                                  .getlistSO();
                                            }
                                            await AppBloc.instance
                                                .refreshScreen(
                                                    "fromNameFunction");
                                            setState(() {
                                              print("documents changed_::::::" +
                                                  widget.serviceOrder.documents
                                                      .toString());
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Flushbar(
                                                icon: Icon(Icons.clear),
                                                duration: Duration(seconds: 6),
                                                onTap: (flushbar) {
                                                  Navigator.pop(context);
                                                },
                                                message: "OS " +
                                                    widget.serviceOrder.id
                                                        .toString() +
                                                    ": Documento firmado con éxito",
                                                margin: EdgeInsets.all(8),
                                                borderRadius: 8,
                                                backgroundColor:
                                                    Colors.blueGrey[500],
                                              ).show(context);
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                // if (indexDocuments == null &&
                                //     indexImage == null)
                                //   Text(
                                //     " ",
                                //     style: TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.bold),
                                //   ),
                                if (indexDocuments != null)
                                  Expanded(
                                    flex: !boolPlus ? 7 : 5,
                                    child: _addButton(
                                      auxFile != null ? auxFile : doc,
                                      boolPlus,
                                      widget.serviceOrder
                                              .documents[indexDocuments]
                                          ["document_definition"],
                                    ),
                                  ),
                                if (indexDocuments == null)
                                  Expanded(
                                    flex: !boolPlus ? 7 : 5,
                                    child: Column(
                                      children: [
                                        _addButton(
                                            auxFile != null ? auxFile : doc,
                                            boolPlus,
                                            doc),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (!FlavorConfig.instance.values.domain
                                .contains("plq"))
                              Container(
                                height: 20,
                              ),
                            if ((indexDocuments == null || auxFile == null) &&
                                !FlavorConfig.instance.values.domain
                                    .contains("plq"))
                              Expanded(
                                child: Container(
                                  child: TextField(
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    controller: listTextController[
                                        list3.indexOf(doc) - 1],
                                    decoration: InputDecoration(
                                        hintText: "Observaciones en " + doc),
                                  ),
                                ),
                              ),
                            if (!FlavorConfig.instance.values.domain
                                .contains("plq"))
                              if (indexDocuments != null && auxFile != null)
                                Container(
                                  height: 10,
                                ),
                            if (!FlavorConfig.instance.values.domain
                                .contains("plq"))
                              if (indexDocuments != null && auxFile != null)
                                if (widget.serviceOrder
                                        .documents[indexDocuments]["status"] ==
                                    4)
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        // Note: Styles for TextSpans must be explicitly defined.
                                        // Child text spans will inherit styles from parent
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: 'Razón: ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: widget
                                                    .serviceOrder
                                                    .documents[indexDocuments]
                                                        ["rejected_status"]
                                                    .toString() ??
                                                "",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            if (!FlavorConfig.instance.values.domain
                                .contains("plq"))
                              if (indexDocuments != null && auxFile != null)
                                if (widget.serviceOrder
                                        .documents[indexDocuments]["status"] !=
                                    4)
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        // Note: Styles for TextSpans must be explicitly defined.
                                        // Child text spans will inherit styles from parent
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                              text: 'Obs: ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: widget.serviceOrder.documents[
                                                        indexDocuments]
                                                    ["comment"] ??
                                                "",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: new BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: new BorderRadius.all(Radius.circular(20))));
            } else {
              return Container(
                height: 0,
              );
            }
          }).toList(),
        );
      } else {
        if (list3.length == 1) {
          if (list3[0].comment != '' && first == 0) {
            first = first + 1;
            textController.text = list3[0].comment;
          }
        }
        return Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: 'Agregar información complementaria'),
                ),
              ),
            ),
          ],
        );
      }
    }

    return ListView(
      children: [
        _function(),
      ],
    );
  }

  /*_content() {
    return ListView(
      children: [
        FutureBuilder<List<DocumentList>>(
            future: repositoryDocument.getDocumentList(widget.data[1]),
            builder: (context, AsyncSnapshot snapshot) {
              List<DocumentList> list = snapshot.data ?? [];
              if(snapshot.hasData){
                if (list.length > 1 || list.length == 1 && list[0].documentType != '') {
                  if (list[0].comment != '' && first == 0) {
                    first = first + 1;
                    textController.text = list[0].comment;
                  }
                  return Column(
                    children: [
                      Column(
                        children: list.map((doc) {
                          if(doc.documentType != ''){
                             return Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _milestoneDocument(doc),
                                  ),
                                  _addButton(doc.typeId),
                                ],
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              decoration: new BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                    new BorderRadius.all(Radius.circular(20)),
                              ));
                          }else{
                            return Container();
                          }
                         
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                                hintText: 'Agregar información complementaria'),
                          ),
                        ),
                      ),
                    ],
                  );
              } else {
                print(list.length);
                if (list.length == 1) {
                  if (list[0].comment != '' && first == 0) {
                    first = first + 1;
                    textController.text = list[0].comment;
                  }}
                  return Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                                hintText: 'Agregar información complementaria'),
                          ),
                        ),
                      ),
                    ],
                  );

              }
              }else{
                return Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                      child: CircularProgressIndicator(),
                    ),
                );
              }

            }),
        SizedBox(
          height: 50,
        ),
        _buttons()
      ],
    );
  }*/

  Future loadingScreenAndText(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              CircularProgressIndicator(),
              FutureBuilder(
                  future: UserRepository().getCurrentPositionForce(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Text(
                          'Subiendo documento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Text(
                          'Cargando ubicación GPS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }),
            ]));
      },
    );
    var position = await UserRepository().getCurrentPositionForce();
    return position;
  }

  Container _buttons() {
    List<TextEditingController> listTextController = <TextEditingController>[
      textController1,
      textController2,
      textController3,
    ];
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              if (widget.boolHomeTab == true) {
                print("tripPage:::: 8      ");
                tripPage = 0;
                await AppBloc.instance.refreshScreen("boton cancelar");
              }
              setState(() {
                numberPageOS = 1;
                /*AppBloc.instance.backDetailSO = true;
                AppBloc.instance.identificationService = widget.serviceOrder.id;
                
                AppBloc.instance.showDocuments = true;
                AppBloc.instance.refreshApp();*/
                print("en botton Cancelar, numberPageOS:::: " +
                    numberPageOS.toString());
              });
              Navigator.pop(context);
              if (widget.comment != null) {
                widget.soListTabBloc.getlistSO();
                setState(() {
                  AppBloc.instance.titleApp = "ZiYU";
                });
                AppBloc.instance.refreshScreen("fromNameFunction");
              }
            },
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.grey[200],
              ),
            ),
            // color: Colors.grey[200],
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          ),
          ElevatedButton(
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: () async {
              print("guarda aca 2");
              if (!FlavorConfig.instance.values.domain.contains("plq")) {
                loadingScreen(context);
                print("images::::: " + images.toString());
                for (int i = 0; i < images.length; i++) {
                  //File pod = await pathToImage(listFileAndType[i][1]);
                  File imagesPath = File(images[i][1]);
                  //savePOD(File image precharged, obs x Doc, nameofDoc)
                  widget.tripSectionOrderId = tripSectionOrderId;

                  var response = await widget.detailSOBloc.savePOD(
                      imagesPath,
                      listTextController[list.indexOf(images[i][0]) - 1].text,
                      boolSignature[list.indexOf(images[i][0])],
                      list.indexOf(images[i][0]),
                      widget.tripSectionOrderId,
                      widget.serviceOrder);
                  listTextController[list.indexOf(images[i][0]) - 1].text = "";
                  listTextController[list.indexOf(images[i][0]) - 1].clear();
                  if (response) {
                    print("POD " + images[i][0] + " cargado con éxito");
                    //AppBloc.instance.refreshScreen("prueba setState");
                  } else if (response == false) {
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 4),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message:
                          "Error de conexión. Se guardará su documento cuando tenga acceso a internet",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context);
                  }
                }
                if (widget.soListTabBloc != null) {
                  await widget.soListTabBloc.getlistSO();
                }
                if (widget.boolHomeTab == true) {
                  print("tripPage:::: 9      ");
                  tripPage = 0;
                }
                Navigator.pop(context);
                setState(() {
                  images = [];
                  numberPageOS = 1;

                  //AppBloc.instance.backDetailSO = true;
                  //AppBloc.instance.identificationService = widget.serviceOrder.id;

                  //AppBloc.instance.refreshApp();
                });
                Navigator.pop(context);
                if (widget.comment != null) {
                  widget.soListTabBloc.getlistSO();
                  setState(() {
                    AppBloc.instance.titleApp = "ZiYU";
                  });
                  AppBloc.instance.refreshScreen("fromNameFunction");
                }
              } else {
                loadingScreen(context);
                File imagesPath = File(images[0][1]);
                bool response = await widget.detailSOBloc
                    .savePODPlq(imagesPath, widget.serviceOrder);

                if (response) {
                  print("POD " + " cargado con éxito");
                  await widget.soListTabBloc.getlistSO();
                  Navigator.pop(context);
                  setState(() {
                    images = [];
                  });
                  Navigator.pop(context);
                  Flushbar(
                    icon: Icon(Icons.clear),
                    duration: Duration(seconds: 5),
                    onTap: (flushbar) {
                      Navigator.pop(context);
                    },
                    message: "POD de OS n°" +
                        widget.serviceOrder.id.toString() +
                        " ha sido guardado",
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                    backgroundColor: Colors.blueGrey[500],
                  ).show(context);
                } else {
                  Navigator.pop(context);
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                FlavorConfig.instance.color,
              ),
            ),
            // color: FlavorConfig.instance.color,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          )
        ],
      ),
    );
  }

  Future<bool> askLocationAndPhonePermissions(BuildContext context,
      {showCancelButton = false, bool locationAlways = false}) async {
    try {
      final locationPermission = await permissionUtils.askAndRequestPermission(
          context: context,
          typesPermission: [
            PermissionsType.LOCATION_TYPE,
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

  ElevatedButton _addButton(docId, bool boolPlus, String documentDefinition) {
    print("auxFile::::::" + docId.toString());
    if (boolPlus) {
      return ElevatedButton(
        onPressed: () async {
          String resp = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CameraScreen()));

          if (resp != null) {
            final val = [docId, resp];
            setState(() {
              images.add(val);
            });
            //var response = await widget.detailSOBloc.savePOD(imagesPath, listTextController[list.indexOf(images[i][0])-1].text, list.indexOf(images[i][0]), widget.tripSectionOrderId, widget.serviceOrder);
          }
        },
        child: Text("Cargar Documentos", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.all(15),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: _contentImage(docId, documentDefinition),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Volver'),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
        child: Text("Ver Documentos", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.all(15),
        ),
      );
    }
  }

  Column _milestoneDocument(Map<String, dynamic> doc, int indexDocument) {
    print("doc:::" + doc.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 5,
        ),
        contentPictures(doc, indexDocument)
      ],
    );
  }

  Column _milestoneImages(var images, int indexDocument) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        newPrePicture(images[indexDocument][1]),
      ],
    );
  }

  contentPictures(Map<String, dynamic> doc, int indexDocument) {
    List<Widget> listElements = [];
    widget.podUrl = widget.serviceOrder.documentFinalUrl(doc["file"]);
    print("widget.podurl:::" + widget.podUrl.toString());
    bool boolDelete = FlavorConfig.instance.values.domain.contains("plq")
        ? true
        : widget.serviceOrder.documents[indexDocument]["status"] == 3
            ? false
            : true;
    if (widget.podUrl != null)
      listElements.add(
          prePicture(widget.podUrl, indexDocument, boolDelete: boolDelete));
    imageUrl = widget.podUrl;
    listFileAndType.add([doc["document_definition"], widget.podUrl]);
    print("images::::" + images.toString());
    print(
        "doc[document_definition]::::::::::::::" + doc["document_definition"]);
    for (final fileImage in images) {
      if (fileImage[0] == doc["document_definition"]) {
        listElements.add(newPrePicture(fileImage[1]));
        print("fileImage[1]:::::" + fileImage[1].toString());
        listFileAndType.add(fileImage);
      }
    }
    print("listElements::::::::::::::::::::::::::::" +
        listElements.length.toString());
    if (listElements.length > 0) {
      return Container(
        height: 50,
        width: double.maxFinite,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: listElements,
        ),
      );
    } else {
      return Container();
    }
  }

  Container newPrePicture(file) {
    return Container(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 5),
            child: Container(
              width: 50.0,
              height: 50.0,
              child: GestureDetector(
                onTap: () {
                  return Dialog(
                    insetPadding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: _visibleKeyBoard ? 0.0 : 24.0),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Container(
                        child: _contentImage("", ""),
                      ),
                    ),
                  );
                },
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orange[500],
                  width: 4,
                ),
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(File(file))),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("eliminando POD 1");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: deletePicturesDialogContent(context, file),
                    );
                  });
            },
            child: Container(
              child: SvgPicture.asset(
                "assets/icons/mileston/close.svg",
                color: Colors.white,
                width: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentImage(String docId, String documentDefinition) {
    //print("dropdownValue::::::::" + dropdownValue);
    print("docId:::: " + docId.toString());
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(documentDefinition + ":"),
        Container(
          margin: EdgeInsets.only(
            top: 20.0,
            bottom: 5.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: imageSelected(docId),
        ),
      ],
    ));
  }

  Widget imageSelected(String docId) {
    /*if (!existImageServer && podFile != null)
      return Container(
        height: sizeScreen.height/4,
        alignment: Alignment.center,
        child: Stack(
          overflow: Overflow.visible,
          children: [
            Image.file(podFile),
            existImageServer ? SizedBox() :
            Positioned(
              top: -15.0, right: -15.0,
              child: ClipOval(
                child: Material(
                  color: Colors.red[400],
                  child: InkWell(
                    child: SizedBox(
                      height: 30.0, width: 30.0,
                      child: Icon(Icons.close,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ),
                  )
                )
              ),
            )
          ],
        ),
      );*/
    podFile = null;
    for (int i = 0; i < images.length; i++) {
      if (images[i][0] == docId) {
        podFile = File(images[i][1]);
        break;
      }
    }

    if (podFile != null) {
      return Container(child: Image.file(podFile));
    }
    imageUrl = docId;

    if (imageUrl != null) {
      return Container(child: ImageNetwork(imageUrl));
    }
    return SizedBox();
  }

  Container prePicture(url, imageId, {bool boolDelete = true}) {
    return Container(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 5),
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage('$url')),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
          if (boolDelete)
            GestureDetector(
              onTap: () {
                print("eliminando POD 2");
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: deletePicturesDbDialogContent(context, imageId),
                      );
                    });
              },
              child: Container(
                child: SvgPicture.asset(
                  "assets/icons/mileston/close.svg",
                  color: Colors.white,
                  width: 15.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Container dbPrePicture(url, imageId) {
    return Container(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 5),
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(File('$url'))),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("eliminando POD 3");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: deletePicturesDbDialogContent(context, imageId),
                    );
                  });
            },
            child: Container(
              child: SvgPicture.asset(
                "assets/icons/mileston/close.svg",
                color: Colors.white,
                width: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 35),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: SvgPicture.asset(
              "assets/icons/mileston/check-circle.svg",
              color: FlavorConfig.instance.color,
              width: 80.0,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            'Usted ha registrado un nuevo hito con éxito',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                FlavorConfig.instance.color,
              ),
            ),
            // color: FlavorConfig.instance.color,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          ),
        ],
      ),
    );
  }

  errorDialogContent(BuildContext context, milestoneCode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 35),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: SvgPicture.asset(
              "assets/icons/mileston/info.svg",
              color: FlavorConfig.instance.color,
              width: 80.0,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            milestoneCode == 0
                ? 'Ha ocurrido un error al intentar registrar un nuevo hito'
                : 'Se encuentra fuera del área de ingreso de esta etapa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(13),
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                FlavorConfig.instance.color,
              ),
            ),
            // color: FlavorConfig.instance.color,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
          ),
        ],
      ),
    );
  }

  deletePicturesDbDialogContent(BuildContext context, imageId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 35),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: SvgPicture.asset(
              "assets/icons/mileston/info.svg",
              color: Colors.red,
              width: 80.0,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            '¿Está seguro de eliminar esta imagen?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppBloc.instance.refreshScreen("fromNameFunction");
                },
                child: Container(
                  margin: EdgeInsets.all(13),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.grey[200],
                  ),
                ),
                // color: Colors.grey[200],
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(25.0),
                // ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  //setState(() {
                  if (!FlavorConfig.instance.values.domain.contains("plq")) {
                    print("widget.serviceOrder.documents[imageId]:::::::" +
                        widget.serviceOrder.documents[imageId].toString());
                    var aux = widget.serviceOrder.documentFinalUrl(
                        widget.serviceOrder.documents[imageId]["file"]);

                    //File imagesPath = await urlToFile(aux);
                    //if(imagesPath==null){
                    //  return CircularProgressIndicator();
                    //}
                    boolSignature[imageId] = false;
                    final documentFile =
                        await pathToImage(widget.serviceOrder.documentPath);
                    var response = await apiProvider.uploadFile2(
                        url: so_change_pod_url,
                        data: widget.serviceOrder.documents[imageId],
                        fileKey: "pod");
                    //print("imagesPath::::" + imagesPath.toString());
                    //savePOD(File image precharged, obs x Doc, nameofDoc)
                    //var response = await widget.detailSOBloc.savePOD(imagesPath, widget.serviceOrder.documents[imageId]["comment"], list.indexOf(widget.serviceOrder.documents[imageId]["document_definition"]));
                    if (response != null) {
                      print("POD " +
                          widget.serviceOrder.documents[imageId]
                              ["document_definition"] +
                          " borrado con éxito");
                    }

                    //widget.serviceOrder.documents.remove(imageId);
                    //deletImages.add(imageId);
                    loadingScreen(context);
                    //await widget.detailSOBloc.getData(widget.idSO, fromInternet: true);
                    if (widget.soListTabBloc != null) {
                      await widget.soListTabBloc.getlistSO();
                    }
                    Navigator.pop(context);
                    setState(() {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                    setState(() {
                      numberPageOS = 2;

                      //AppBloc.instance.backDetailSO = true;
                      //AppBloc.instance.identificationService = widget.serviceOrder.id;

                      //AppBloc.instance.showDocuments = true;
                      //AppBloc.instance.refreshApp();
                    });
                    AppBloc.instance.refreshScreen("fromNameFunction");

                    //});
                  } else {
                    print("pasa por else de borrar pod");
                    loadingScreen(context);
                    widget.serviceOrder.podPath = null;
                    widget.serviceOrder.podUrl = null;
                    widget.serviceOrder.podUploaded = false;
                    var response = await apiProvider.uploadFile2(
                        url: so_upload_pod_url,
                        data: {
                          "id": widget.serviceOrder.id,
                          "file": null,
                          "comment": null,
                        },
                        fileKey: "pod");
                    if (response != null) {
                      await widget.soListTabBloc.getlistSO();
                      print("POD " + " borrado con éxito");
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                    Navigator.pop(context);
                    Flushbar(
                      icon: Icon(Icons.clear),
                      duration: Duration(seconds: 5),
                      onTap: (flushbar) {
                        Navigator.pop(context);
                      },
                      message: "El POD de OS n°" +
                          widget.serviceOrder.id.toString() +
                          " fue eliminado",
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    ).show(context);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(13),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    FlavorConfig.instance.color,
                  ),
                ),
                // color: FlavorConfig.instance.color,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(25.0),
                // ),
              )
            ],
          ),
        ],
      ),
    );
  }

  deletePicturesDialogContent(BuildContext context, file) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 35),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: SvgPicture.asset(
              "assets/icons/mileston/info.svg",
              color: Colors.red,
              width: 80.0,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            '¿Está seguro de eliminar esta imagen?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(13),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                ),
                // color: Colors.grey[200],
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(25.0),
                // ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    int index =
                        images.indexWhere((element) => element[1] == file);
                    print(
                        "images.where((element) => element[1] == file)):::::" +
                            images
                                .indexWhere((element) => element[1] == file)
                                .toString());
                    boolSignature[list.indexOf(images[index][0])] = false;
                    images.removeWhere((img) => img[1] == file);
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(13),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    FlavorConfig.instance.color,
                  ),
                ),
                // color: FlavorConfig.instance.color,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(25.0),
                // ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
