import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:ziyu_seg/src/components/expanded_section.dart';
import 'package:ziyu_seg/src/components/fuel_zone_not_planning_card.dart';
import 'package:ziyu_seg/src/flavor_config.dart';
import 'package:ziyu_seg/src/models/navegation/vehicle_fueling.dart';
import 'package:ziyu_seg/src/models/navegation/vehicle_planning.dart';
import 'package:ziyu_seg/src/models/navegation/zone_planning.dart';
import 'package:ziyu_seg/src/screens/navegation/home_tab/fuel_zone_card.dart';
import 'package:ziyu_seg/src/utils/colors.dart';
import 'package:ziyu_seg/src/utils/string_utils.dart';

import 'detail_so.dart';

class DetailProgramContent extends StatelessWidget{
  final Widget topScreen;
  final Widget backButton;
  final Map<String, dynamic> data;

  DetailProgramContent({
    @required this.backButton,
    @required this.topScreen,
    @required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final List<VehicleFueling> vehiclesFueling = data["vehicles_fueling"] ?? [];
    final double totalLitersWithoutProjection = data["total_liter_dispatched"] ?? 0;

    return ListView(
      children: <Widget>[
        topScreen,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              if (data["date_start"].isNotEmpty || data["date_end"].isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  child: deliveryDate(data["date_start"], data["date_end"]),
                ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 15.0),
                child: _routeElementProgramChargerContent(),
              ),

              if(vehiclesFueling.length > 0)
                Container(
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: FuelZoneNotPlanningCard(
                    vehiclesFueling: vehiclesFueling,
                    totalLiters: totalLitersWithoutProjection,
                  )
                ),

              Container(
                child: _litersDispatched(data["total_liter_dispatched"])
              ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 25.0),
                width: double.maxFinite,
                child: backButton,
              ),
            ],
          ),
        )
      ],
    );
  }


  Widget _routeElementProgramChargerContent(){
    final List<ZonePlanning> zonesPlanning = data["zones_planning"] ?? [];

    int count = 0;
    return Container(
      decoration: BoxDecoration(
        color: Color(CustomColor.white_container),
        border: Border.all(
          color: Color(CustomColor.grey_low),
          width: 1.5
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(5.0)
        ),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: zonesPlanning.map((zonePlanning) {
              count ++;

              return FuelZoneCardDetail(zonePlanning: zonePlanning, isExpanded: count == 1);
            }).toList(),
          ),
        ],
      )
    );
  }

  Widget _litersDispatched(double totalLitersDispatchers){
    if(totalLitersDispatchers == null){
      return SizedBox();
    }

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Totales despachados: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 1.0),
                  child: Icon(Icons.local_gas_station,
                    color: Color(CustomColor.black_medium),
                    size: 16.0,
                  ),
                ),
                Text("${doubleToStringTruncate(totalLitersDispatchers, 2) ?? 0} lt",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                  ),
                ),

              ],
            )
          ),
        ],
      ),
    );
  }

}

class FuelZoneCardDetail extends StatefulWidget{
  final ZonePlanning zonePlanning;
  final bool isExpanded;

  FuelZoneCardDetail({
    @required this.zonePlanning,
    @required this.isExpanded,
  });

  @override
  State<StatefulWidget> createState() {
    return _FuelZoneCardDetailState();
  }
}

class _FuelZoneCardDetailState extends State<FuelZoneCardDetail>{
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            ExpandedSection(
              expand: isExpanded,
              child: contentHidden(),
            )
          ],
        ),
      )
    );
  }

  Widget header(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 10.0, left: 10.0),
            child: Row(
              children: [
                Container(
                  child: Icon(Icons.place,
                    size: 26.0,
                    color: Color(CustomColor.black_medium),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    margin: EdgeInsets.only(left: 10.0),
                    child: Text(widget.zonePlanning.zoneName ?? "",
                      style: TextStyle(fontWeight: FontWeight.bold,
                        color: Color(CustomColor.black_medium)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Icon(Icons.access_time,
                          color: Color(CustomColor.black_medium),
                          size: 16.0,
                        ),
                      ),
                      Text(widget.zonePlanning.dateHrs ?? "",
                        style: TextStyle(
                          color: Color(CustomColor.black_medium)
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Icon(Icons.local_gas_station,
                          color: Color(CustomColor.black_medium),
                          size: 16.0,
                        ),
                      ),
                      Text(widget.zonePlanning.gasolineAndPlannedStr ?? "",
                        style: TextStyle(
                          color: Color(CustomColor.black_medium)
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0),
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onCollapse,
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Color(CustomColor.grey_medium_2)
                      ),
                    )
                  )
                )
              )
            ),
          ],
        )
      ],
    );
  }

  Widget contentHidden(){
    int count = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
          height: 1.5,
          color: Color(CustomColor.grey_lower),
        ),
        widget.zonePlanning.vehiclePlannings.length > 0
        ? Column(children: widget.zonePlanning.vehiclePlannings.map((vehiclePlanning) {
          count ++;
          return VehicleChargerRow(
            vehiclePlanning: vehiclePlanning,
            number: count,
            buttonCustom: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0)
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5.0),
                  onTap: () => _onPressedModalCharger(vehiclePlanning),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                    padding: EdgeInsets.all(7.5),
                    child: Icon(Icons.remove_red_eye,
                      color: FlavorConfig.instance.color,
                      size: 20.0,
                    ),
                  ),
                )
              ),
            ),
          );

        }).toList())
        : Container(
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: Text("No tiene cargas de vehículos asignados.",
            style: TextStyle(
              color: Color(CustomColor.black_medium)
            )
          ),
        )
      ],
    );
  }

  _onCollapse(){
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  _onPressedModalCharger(VehiclePlanning vehiclePlanning){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: ModalChargerVehicle(
            vehiclePlanning: vehiclePlanning,
          )
        );
      },
    );
  }

}

class ModalChargerVehicle extends StatefulWidget{
  final VehiclePlanning vehiclePlanning;

  ModalChargerVehicle({
    @required this.vehiclePlanning
  });

  @override
  State<StatefulWidget> createState() {
    return _ModalChargerVehicleState();
  }
}

class _ModalChargerVehicleState extends State<ModalChargerVehicle>{

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.minPositive,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 20.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: Text(widget.vehiclePlanning.plate ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text("¿Vehículo cargado?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    // color: FlavorConfig.instance.color,
                    borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5.0),
                      onTap: null,
                      child: Icon(!widget.vehiclePlanning.isChargerDriver ? Icons.check_box_outline_blank : Icons.check_box,
                        color: Color(CustomColor.grey_medium),
                        size: 40.0,
                      ),
                    )
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Comentario: ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17.0,
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(widget.vehiclePlanning.commentIssue ?? "")
            ),
            SizedBox(height: 20.0),
            Container(
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: DialogButton(
                      color: Color(CustomColor.black_medium),
                      child: Text("Volver",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              )
            )
          ],
        )
      ),
    );
  }
}