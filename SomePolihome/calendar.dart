import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:polihome1/SomeWidget.dart';
import 'package:polihome1/geolocalitation.dart';
import 'package:polihome1/main.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//DateTime _currentDate = DateTime(2020, 2, 10);
DateTime _currentDate2 = DateTime.now();
//DateTime _currentDate2 = DateTime(2020, 2, 10);
String _currentMonth;
DateTime _targetDateTime = DateTime.now();

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

Future<String> sendAppointment(
    String user, String dataTime, String personal) async {
  final response =
      await http.post("http://45.236.130.119/php_mysql/edit.php", body: {
    "user": user,
    "appointment_day": dataTime,
    "personal": personal,
    "institution": institution,
  });
}
Future<List> setAppointment(String user, String dataTime, String dataTime2, String bool1, String bool2) async {
  final response =
  await http.post("http://45.236.130.119/php_mysql/edit_appointment.php", body: {
    "user": user,
    "appointment_day": dataTime,
    "appointment_day_2": dataTime2,
    "institution": institution,
    "bool1": bool1,
    "bool2": bool2,
  });
  if (response.statusCode == 200) {
    // Si la llamada al servidor fue exitosa, analiza el JSON
    print("response:" + response.body.toString());
  } else {
    // Si la llamada no fue exitosa, lanza un error.
    throw Exception('Failed to load post');
  }

}

Future<String> sendAppointment2(
    String user, String dataTime, String personal) async {
  final response =
      await http.post("http://45.236.130.119/php_mysql/edit.php", body: {
    "user": user,
    "appointment_day_2": dataTime,
    "personal": personal,
    "institution": institution,
  });
}
Future<String> sendVisitedandRemoveAppointment(
    String user, String dataTime, String personal) async {
  final response =
  await http.post("http://45.236.130.119/php_mysql/edit.php", body: {
    "user": user,
    "visited": dataTime,
    "personal": personal,
    "institution": institution,
  });
}

class CalendarPage extends StatefulWidget {
  final List<String> items;
  CalendarPage({Key key, this.title, this.items}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CalendarPageState createState() => new _CalendarPageState(items: items);
}

class _CalendarPageState extends State<CalendarPage> {
  final List<String> items;
  _CalendarPageState({this.items});

  @override

//  List<DateTime> _markedDate = [DateTime(2018, 9, 20), DateTime(2018, 10, 11)];
  static Widget _eventIcon = new Container(

    decoration: new BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Fondo.png"),//fondo
          fit: BoxFit.fill,
          //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.amber,
    ),
  );

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {
      new DateTime.now(): [
        new Event(
          date: new DateTime.now(),
          title: 'Event 1',
          icon: _eventIcon,
          dot: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            color: Colors.red,
            height: 5.0,
            width: 5.0,
          ),
        ),
        new Event(
          date: new DateTime(2020, 2, 10),
          title: 'Event 2',
          icon: _eventIcon,
        ),
        new Event(
          date: new DateTime(2020, 2, 10),
          title: 'Event 3',
          icon: _eventIcon,
        ),
      ],
    },
  );
  List<bool> boolVisited = List.filled(200, false);
  CalendarCarousel _calendarCarousel, _calendarCarouselNoHeader;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _currentMonth = DateFormat.yMMM('es').format(_targetDateTime);
    boolVisited = List.filled(200, false);
    if (items.hashCode == true) {
      print(items.length);
    }

    /// Add more events to _markedDateMap EventList
    _markedDateMap.add(
        new DateTime(2020, 2, 25),
        new Event(
          date: new DateTime(2020, 2, 25),
          title: 'Event 5',
          icon: _eventIcon,
        ));

    _markedDateMap.add(
        new DateTime(2020, 2, 10),
        new Event(
          date: new DateTime(2020, 2, 10),
          title: 'Event 4',
          icon: _eventIcon,
        ));

    _markedDateMap.addAll(new DateTime(2020, 2, 11), [
      new Event(
        date: new DateTime(2020, 2, 11),
        title: 'Prueba 1',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2020, 2, 11),
        title: 'Event 2',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2020, 2, 11),
        title: 'Event 3',
        icon: _eventIcon,
      ),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Example with custom icon
    var listOfEvents = List<String>();
    var listPatient = List<Persona>();

    _calendarCarousel = CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate = date);
        this.setState(() => _targetDateTime = date);
        this.setState(() {
          boolVisited = List.filled(200, false);
        });
        events.forEach((event) => {
              listOfEvents.add(event.title),
            });
        print(listOfEvents);
        print(_targetDateTime);
        print(_currentDate.toString());
        setState(() {
          _currentMonth = DateFormat.yMMM('es').format(_targetDateTime);
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarPage(
                items: listOfEvents,
              ),
            ),
          );*/
        });
      },
      isScrollable: false,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      locale: "es",
      thisMonthDayBorderColor: Colors.grey,

      //showWeekDays: null, /// for pass null when you do not want to render weekDays
      headerText: _currentMonth.capitalize(),
      weekFormat: true,
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM('es').format(_targetDateTime);
          List<bool> boolVisited = List.filled(80, false);
        });
      },
      showOnlyCurrentMonthDate: false,
      selectedDayButtonColor: Colors.blueAccent[200],
      selectedDayBorderColor: Colors.black,
      markedDatesMap: _markedDateMap,
      height: 200.0,
      selectedDateTime: _currentDate,
      showIconBehindDayText: true,

//          daysHaveCircularBorder: false, /// null for not rendering any border, true for circular border, false for rectangular border
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      selectedDayTextStyle: TextStyle(
        color: Colors.yellow,
      ),
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      minSelectedDate: _currentDate.subtract(Duration(days: 365)),
      maxSelectedDate: _currentDate.add(Duration(days: 365)),

      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.purple,
      markedDateMoreShowTotal:
          true, // null for not showing hidden events indicator
//          markedDateIconMargin: 9,
//          markedDateIconOffset: 3,
    );

    _showMaterialDialog() {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
            title: new Text("Alerta de Visita hecha"),
            content: new RichText(
              textScaleFactor: 1.1,
              text: TextSpan(
                text: '¿Estas seguro de designar los ',
                style: TextStyle(color: Colors.black),//DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(text: 'pacientes',),
                  TextSpan(text: ' seleccionados como visita concretada?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('¡Atras!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              FlatButton(
                child: Text("Continuar"),
                onPressed: () {
                  var list2 = List<Persona>();
                  list2 = listPersonaFunction(listPatient, _currentDate);
                  for(int i=0;i<list2.length;i++){
                    if(boolVisited[i]==true){
                      print("intenta pasar por sendVisitedandRemovedAppointment, list2[i].getNombre: " + list2[i].getNombre);
                      sendVisitedandRemoveAppointment(list2[i].getUser, _currentDate.toString(), list2[i].getPersonal);
                    }
                  }
                  setState(() {

                  });
                  Navigator.pop(
                    context,
                  );
                },
              ),
            ],
          ));
    }


    var dayPatientList = List<Persona>();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Calendario de Visitas"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Fondo.png"),//fondo
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
            ),
        ),
        child: Center(
          child: FutureBuilder<List<Persona>>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                listPatient = snapshot.data;
                bool change;
                bool change2;
                dayPatientList = listPersonaFunction(listPatient, _currentDate);
                for (int i=0; i<listPatient.length; i++){
                  change = false;
                  change2 = false;
                  if((listPatient[i].getCita!=null) && (DateTime.now().isAfter(DateTime.parse(listPatient[i].getCita)))==true && (DateTime.now().difference(DateTime.parse(listPatient[i].getCita))).inDays>=2){
                    listPatient[i].setCita = null;
                    change = true;
                  }
                  if((listPatient[i].getCita2!=null) && (DateTime.now().isAfter(DateTime.parse(listPatient[i].getCita2)))==true && (DateTime.now().difference(DateTime.parse(listPatient[i].getCita2))).inDays>=2){
                    listPatient[i].setCita2 = null;
                    change2 = true;
                  }
                  if(change == true || change2 == true){
                    setAppointment(listPatient[i].getUser, listPatient[i].getCita.toString(), listPatient[i].getCita2.toString(), change.toString(), change2.toString());
                  }
                }
                return Calendary(snapshot.data);
              }
              return Image.asset(
                "assets/poligif.gif",
                height: 125.0,
                width: 125.0,
              );
            },
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0.0, 20),
        child: SpeedDial(
            overlayOpacity: 0.0,
            animatedIcon: AnimatedIcons.menu_close,
            elevation: 0.0,
            children: [
            SpeedDialChild(
              child: Icon(Icons.person_add),
              label: 'Planificar visita',
              labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new NewEvent(dayPatientList: dayPatientList,),
                  ),
                );
                Flushbar(
                  icon: Icon(Icons.clear),
                  onTap: (flushbar) {
                    Navigator.pop(context);
                  },
                  message: "En el algoritmo Aleatorio, se considerarán solo las personas que no tengan día prefijado",
                  margin: EdgeInsets.all(8),
                  borderRadius: 8,
                  backgroundColor: Colors.blueGrey[500],
                ).show(context);
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.check_box),
              label: 'Guardar Visitados',
              labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.black,
              onTap: () {
                //_currentDate.toString();

                _showMaterialDialog();
              },
            ),
          ]
        ), /*FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new NewEvent(),
                ),
              );
            },
            child: Icon(Icons.person_add),
            backgroundColor: Colors.green,
          ),*/
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            heroTag: "btn4",
            child: Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 45,
            ), //Icons.insert_invitation),
            onPressed: () {
              for (int i = 0; i < listPatient.length; i++) {
                print(listPatient[i].getNombre + " prueba");
              }
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => MapEvents(
                          patients: listPatient,
                          currentDate: _currentDate,
                        )),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget Calendary(List<Persona> personList) {
    return new ListView(
      children: <Widget>[
        //custom icon
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: _calendarCarousel,
        ), // This trailing comma makes auto-formatting nicer for build methods.
        //custom icon without header
        //CalendarNotes(list: personList, currentDate: _currentDate,),
        CalendarNotes(personList, _currentDate),
      ],
    );
  }
  //List<bool> boolVisited = List.filled(200, false);
  List<Persona> listPersonaFunction(List<Persona> list, DateTime currentDate){
    var list2 = List<Persona>();
    for (int i = 0; i < list.length; i++) {
      //print(list[i].getCita + " selected: " + currentDate.toString());
      if (list[i].getCita == currentDate.toString()) {
        print(list[i].getNombre + " mostrando en pantalla");
        list2.add(list[i]);
      }
      if (list[i].getCita2 == currentDate.toString()) {
        print(list[i].getNombre + " mostrando en pantalla");
        list2.add(list[i]);
      }
    }
    return list2;
  }
  Widget CalendarNotes(List<Persona> list, DateTime currentDate) {
    var list2 = List<Persona>();
    list2 = listPersonaFunction(list, currentDate);
    _showMaterialDialogEliminate(Persona persona) {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
            title: new Text("Alerta de Visita hecha"),
            content: new RichText(
              textScaleFactor: 1.1,
              text: TextSpan(
                text: '¿Estas seguro de eliminar al ',
                style: TextStyle(color: Colors.black),//DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(text: 'paciente ',),
                  TextSpan(text: persona.getNombre + " " + persona.getApellido),
                  TextSpan(text: ' de la agenda de visita?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Atras'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              FlatButton(
                child: Text("Confirmar"),
                onPressed: () {
                  bool change = false;
                  bool change2 = false;
                  print(_currentDate.toString() + "currentDate");
                  print(persona.getCita);
                  print(persona.getCita2);
                  if(persona.getCita.toString()==_currentDate.toString()){
                    print("pasa por change");
                    change = true;
                  }
                  if(persona.getCita2.toString()==_currentDate.toString()){
                    print("pasa por change2");
                    change2 = true;
                  }
                  setAppointment(persona.getUser, persona.getCita.toString(),
                      persona.getCita2.toString(), change.toString(), change2.toString());
                  setState(() {

                  });
                  Navigator.pop(
                    context,
                  );
                },
              ),
            ],
          ));
    }

    print("tamaño de list2: " + list2.length.toString());
    if (list2.length == 0) {
      return Text("Sin citas hoy. Día seleccionado: " + currentDate.toString());
    } else {
      return ListView.builder(
          itemCount: list2.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            //List<bool> boolVisited = List.filled(80, false);
            final item3 = list2[index];
            return ListTile(
              title: Text(item3.getNombre + " " + item3.getApellido),
              subtitle: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: RichText(
                  textScaleFactor: 0.9,
                  text: TextSpan(
                    text: 'Designado por ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: item3.getPersonal,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          )),
                    ],
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    textColor: (boolVisited[index]) ? Colors.red : Colors.black26,
                    //color: boolVisited[index] ? Colors.red : Colors.black26,
                    child: Text(
                      "Visitado",
                      style: TextStyle(
                        color: (boolVisited[index]) ? Colors.red : Colors.black26,
                      ),
                    ),
                    onPressed: () {
                      boolVisited[index] = !boolVisited[index];
                      print(boolVisited[0].toString() + boolVisited[1].toString());
                      setState(() {});
                      /*Flushbar(
                      message: "Sin pacientes que buscar hoy",
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    )..show(context);*/
                    },
                  ),
                  IconButton(
                    //color: boolVisited[index] ? Colors.red : Colors.black26,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _showMaterialDialogEliminate(item3);
                      /*Flushbar(
                      message: "Sin pacientes que buscar hoy",
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(8),
                      borderRadius: 8,
                      backgroundColor: Colors.blueGrey[500],
                    )..show(context);*/
                    },
                  ),
                ],
              )
            );
          });
    }
  }

}

class MapEvents extends StatelessWidget {
  List<Persona> patients;
  final DateTime currentDate;

  MapEvents({this.patients, this.currentDate});

  @override
  Widget build(BuildContext context) {
    var totalList = List<List<dynamic>>();
    var list2 = List<Persona>();
    for (int i = 0; i < patients.length; i++) {
      //print(patients[i].getCita + (" selected: ") + currentDate.toString());
      if (patients[i].getCita == currentDate.toString()) {
        list2.add(patients[i]);
      }
      if (patients[i].getCita2 == currentDate.toString()) {
        list2.add(patients[i]);
      }
    }
    if (list2.length != 0) {
      totalList = AlgorithmMaker(3, list2, null, list2.length, null);
      return SendDirections(
        listofAddress: totalList[1],
        personList: totalList[0],
        numberof: patients.length,
        onHaversine: false,
        colorofAddress: totalList[2],
        onCalendary: false,
        appointment: currentDate.toString(),
      );
    } else {
      Future.microtask(() => Navigator.pop(context)).then((value) => Flushbar(
            message: "Sin pacientes que buscar hoy",
            duration: Duration(seconds: 2),
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            backgroundColor: Colors.blueGrey[500],
          )..show(context));
    }
  }
}

class NewEvent extends StatelessWidget {

  List<Persona> dayPatientList;

  NewEvent({this.dayPatientList});

  @override
  Widget build(BuildContext context) {
    print("dayPatientList.length en newEvent: " + dayPatientList.length.toString());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Nueva Visita"),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              /*Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new GlobalMenu(items: fetchPost(), notSayHi: true,)),
              );*/
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text("Cambiar usuario"),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/loginPage', (Route<dynamic> route) => false);
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(120, 120), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color(0xFFFFFFFF), // button color
                          child: InkWell(
                            splashColor: Colors.lightGreen, // splash color
                            onTap: () {
                              print("dayPatientList.length: " + dayPatientList.length.toString());
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new PacientWidget(
                                    items: fetchPost(),
                                    appointment: _currentDate.toString(),
                                    dayPatientList: dayPatientList,
                                  ),
                                ),
                              );
                            }, // button pressed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[

                                Icon(FontAwesomeIcons.peopleArrows, color: Color(0xFF30E3CA), size: 50,), // icon
                                // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(child: Text("Priorizar Paciente", style: TextStyle(fontWeight: FontWeight.bold),),),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(120, 120), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color(0xFFFFFFFF), // button color
                          child: InkWell(
                            splashColor: Colors.lightGreen, // splash color
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new CalendaryAlgoritm(
                                    algorithm: "actualizacion",
                                    onAleatory: false,
                                    appointment: _currentDate.toString(),
                                    dayPatientList: dayPatientList,
                                  ),
                                ),
                              );
                            }, // button pressed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.handHoldingHeart, color: Color(0xFF30E3CA), size: 50,), // icon// text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(child: Text("Visita más Antigua", style: TextStyle(fontWeight: FontWeight.bold),),),
                  ],
                ),

              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(120, 120), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color(0xFFFFFFFF), // button color
                          child: InkWell(
                            splashColor: Colors.lightGreen, // splash color
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new CalendaryAlgoritm(
                                    algorithm: "gravedad",
                                    onAleatory: false,
                                    appointment: _currentDate.toString(),
                                    dayPatientList: dayPatientList,
                                  ),
                                ),
                              );
                            }, // button pressed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.briefcaseMedical, color: Color(0xFF30E3CA), size: 50,), // icon
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(child: Text("Gravedad", style: TextStyle(fontWeight: FontWeight.bold),),),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(120, 120), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Color(0xFFFFFFFF), // button color
                          child: InkWell(
                            splashColor: Colors.lightGreen, // splash color
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new CalendaryAlgoritm(
                                      onAleatory: true, appointment: _currentDate.toString(), dayPatientList: dayPatientList,),
                                ),
                              );
                              Flushbar(
                                icon: Icon(Icons.clear),
                                onTap: (flushbar) {
                                  Navigator.pop(context);
                                },
                                message: "En el algoritmo Aleatorio, se considerarán solo las personas que no tengan día prefijado",
                                margin: EdgeInsets.all(8),
                                borderRadius: 8,
                                backgroundColor: Colors.blueGrey[500],
                              ).show(context);
                            }, // button pressed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.random, color: Color(0xFF30E3CA), size: 50,), // icon
                                Text("Aleatorio"), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(child: Text("Aleatorio", style: TextStyle(fontWeight: FontWeight.bold),),),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TestText extends StatelessWidget {
  final DateTime time;

  TestText({this.time});
  @override
  Widget build(BuildContext context) {
    /*return ListView(

      children: <Widget>[
        ListTile(
          title: Text(listEvents[index]),
        ),
      ],
    );*/
    return Text(time.toString());
  }
}
