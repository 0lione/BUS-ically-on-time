import 'dart:async';

import 'package:carris/pages/patterns.dart';
import 'package:carris/pages/routes.dart';
import 'package:carris/pages/stopestimation.dart';
import 'package:flutter/material.dart';

class MyPanel extends StatefulWidget {
  final int idStop;
  final Map<String,Routes> routes;
  final Function(String?, Future<Pattern>) callback;

  const MyPanel({super.key, required this.idStop, required this.callback, required this.routes}); 


  @override
  State<MyPanel> createState() => _MyPanelState();
}

class _MyPanelState extends State<MyPanel> {
  late Future<List<StopEstimation>> stopEstimation;
  late Timer? updateEstimationTimer;
  late String selectedTripId= "";

  @override
  void initState() {
    super.initState();
    updateEstimationTimer = Timer.periodic(const Duration(seconds: 45), (Timer t) => _updateEstimation());
    _updateEstimation();
  }

  @override
  void didUpdateWidget(covariant MyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idStop != widget.idStop) {
      _updateEstimation();
    }
  }

  @override
  void dispose() {
    updateEstimationTimer?.cancel();
    super.dispose();
  }
//TODO: always save the estiamtion of time if the next fetch has null then use the previous one
  _updateEstimation() {
        setState(() {
          stopEstimation = fetchStopEstimation(widget.idStop);
        });
  }

  bool _buildCalled() {
    print("Build called ${widget.idStop}");
    return true;
  }


List<StopEstimation> _getLines(List<StopEstimation> stopEstimation) {
  List<StopEstimation> lines = [];
  TimeOfDay now = TimeOfDay.now();
  for (var stop in stopEstimation) {
      int differenceInMinutesEstimated = 0;
      if (stop.estimatedTime == null || stop.estimatedTime == "N/A") {
        stop.estimatedTime = "N/A";
      } else {
        List<String> estimatedTimeParts = stop.estimatedTime!.split(':');
        if(int.parse(estimatedTimeParts[0]) >= 24) estimatedTimeParts[0] = (int.parse(estimatedTimeParts[0]) - 24).toString();
        TimeOfDay estimatedTime = TimeOfDay(hour: int.parse(estimatedTimeParts[0]), minute: int.parse(estimatedTimeParts[1]));
        differenceInMinutesEstimated = estimatedTime.minute - now.minute + (estimatedTime.hour - now.hour) * 60;
        stop.estimatedTime = "${estimatedTimeParts[0]}:${estimatedTimeParts[1]}";
      }
      List<String> timeParts = stop.scheduledTime.split(':');
      if(int.parse(timeParts[0]) >= 24) timeParts[0] = (int.parse(timeParts[0]) - 24).toString();
      TimeOfDay scheduledTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      int differenceInMinutes = scheduledTime.minute - now.minute + (scheduledTime.hour - now.hour) * 60;
      stop.scheduledTime = "${timeParts[0]}:${timeParts[1]}";
      if ((differenceInMinutes >= 0 && differenceInMinutesEstimated >= 0 && differenceInMinutes < 61) || differenceInMinutesEstimated >= 0 && differenceInMinutesEstimated < 61 && stop.estimatedTime != "N/A") {
        lines.add(stop);
      }
  }
  return lines;
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       _buildCalled()
        ? Expanded(
          flex: 1,
          child:
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
              ),
              margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
              child: const Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24.0,),
              ),
            ),
        )
        : Container(),
        Expanded(
          flex: 7,
          child:
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20.0,
                    color: Colors.grey,
                  ),
                ]
              ),
              child: FutureBuilder(
                future: stopEstimation,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<StopEstimation> stopEstimation = snapshot.data as List<StopEstimation>;
                    stopEstimation = _getLines(stopEstimation); //gets the bus coming in the next hour 
                    if (stopEstimation.isEmpty) {
                      return const Center(child: Text('No buses arriving in the next hour'));
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: stopEstimation.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () => {
                              setState(() {
                                if(stopEstimation[index].trip == selectedTripId) {
                                  selectedTripId = "";
                                } else {
                                  selectedTripId = stopEstimation[index].trip;
                                }
                              }),
                              widget.callback(stopEstimation[index].trip, fetchPattern(stopEstimation[index].pattern))
                            },
                            child: AnimatedContainer(
                              alignment: Alignment.center,
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueGrey,
                                  width: 1,
                                ),
                                color: selectedTripId == stopEstimation[index].trip ? Colors.blueGrey : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                  height: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 60,
                                            height: 35,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(widget.routes[stopEstimation[index].line]!.color.substring(1),radix: 16) + 0xFF000000),
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              stopEstimation[index].line,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                        ),
                                      ),
                                      Expanded(flex: 2,child: Text(textAlign: TextAlign.center,stopEstimation[index].destination)),
                                      stopEstimation[index].estimatedTime != 'N/A' 
                                        ? Padding(
                                          padding: const EdgeInsets.fromLTRB(4.0, 2.0, 8.0, 2.0),
                                          child: Container(
                                              padding: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                              '${stopEstimation[index].estimatedTime}',
                                              style: const TextStyle(color: Colors.white),
                                                                            ),
                                            ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.fromLTRB(4.0, 8.0, 16.0, 8.0),
                                          child:  Text(stopEstimation[index].scheduledTime),
                                        ),
                                    ],
                                  ),),
                              ),
                         );
                        },
                      );
                  } else if (snapshot.hasError && widget.idStop == -1) {
                    return const Center(child: Text('Select a stop to see the buses arriving in the next hour'));
                  }
                  return const Center(child: CircularProgressIndicator());
                }
            ),
        ),
        ),
      ],

    );
  }
}

