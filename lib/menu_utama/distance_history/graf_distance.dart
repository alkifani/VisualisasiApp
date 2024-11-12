import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/menu_utama/distance_history/distance_history.dart';

class GrafDistanceHistory extends StatefulWidget {
  final String plat;

  const GrafDistanceHistory({Key? key, required this.plat}) : super(key: key);

  @override
  _GrafDistanceHistoryState createState() => _GrafDistanceHistoryState();
}

class _GrafDistanceHistoryState extends State<GrafDistanceHistory> {
  List<TimeSeriesDistance> _datadistance = [];
  double _totalDistance = 0.0;
  int _dataCountdistance = 0;
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");

  @override
  void initState() {
    super.initState();
    databaseRef.child(widget.plat).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
        if (values != null) {
          // Urutkan perjalanan berdasarkan DateUnggah
          List<MapEntry<dynamic, dynamic>> sortedEntries = values.entries.toList();
          sortedEntries.sort((a, b) {
            DateTime dateA = DateTime.parse(a.value['DateUnggah']);
            DateTime dateB = DateTime.parse(b.value['DateUnggah']);
            return dateB.compareTo(dateA); // Urutkan dalam urutan menurun
          });

          // Ambil data dari perjalanan terakhir
          Map<dynamic, dynamic>? latestTrip = sortedEntries.first.value;
          _datadistance = [];
          _totalDistance = 0.0;
          _dataCountdistance = 0;

          latestTrip?.forEach((key, value) {
            if (value is Map<dynamic, dynamic>) {
              dynamic distance = value['distance'];
              dynamic time = value['datetime'];
              if (distance != null && time != null && time.toString().isNotEmpty) {
                try {
                  String formattedTime = time.toString().replaceAll(',  ', ' ');
                  DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(formattedTime);
                  double parsedDistance = double.tryParse(distance.toString()) ?? 0.0;
                  _datadistance.add(TimeSeriesDistance(dateTime, parsedDistance));
                  _totalDistance += parsedDistance;
                  _dataCountdistance++;
                } catch (e) {
                  if (kDebugMode) {
                    print('Failed to parse date: $time. Error: $e');
                  }
                }
              }
            }
          });

          // Sort data based on time
          _datadistance.sort((a, b) => a.time.compareTo(b.time));
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate average distance
    double averageDistance = _dataCountdistance > 0 ? _totalDistance / _dataCountdistance : 0.0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text('Data Jarak Kendaraan',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 30,
                  width: 40,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DistanceHistoryDisplay(plat: widget.plat),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(button),
                      ),
                      child: Icon(CupertinoIcons.decrease_indent, color: texticon, size: 18,)
                  ),
                ),
                SizedBox(width: 10,),
                SizedBox(
                  height: 30,
                  width: 40,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenDistanceGraph(data: _datadistance),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(button),
                      ),
                      child: Icon(CupertinoIcons.fullscreen, color: texticon, size: 18,)
                  ),
                ),
                SizedBox(width: 10,),
              ],
            ),
            SizedBox(
              height: size.height * 0.7,
              child: SfCartesianChart(
                title: ChartTitle(
                    text: 'meter',
                    alignment: ChartAlignment.near,
                    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enableDoubleTapZooming: true,
                  enablePanning: true,
                ),
                primaryXAxis: DateTimeAxis(
                  labelRotation: 45,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  majorGridLines: MajorGridLines(width: 0),
                  intervalType: DateTimeIntervalType.auto,
                  enableAutoIntervalOnZooming: true,
                ),
                primaryYAxis: NumericAxis(
                  axisLine: AxisLine(width: 0),
                  labelFormat: '{value}',
                  majorTickLines: MajorTickLines(size: 0),
                  plotBands: [
                    PlotBand(
                        color: Colors.redAccent,
                        start: 5,
                        end: 5,
                        borderColor: Colors.red,
                        borderWidth: 2
                    )
                  ],
                ),
                series: [
                  LineSeries<TimeSeriesDistance, DateTime>(
                    dataSource: _datadistance,
                    xValueMapper: (TimeSeriesDistance distance, _) => distance.time,
                    yValueMapper: (TimeSeriesDistance distance, _) => distance.distance,
                    // dataLabelSettings: DataLabelSettings(
                    //   isVisible: true,
                    //   textStyle: TextStyle(color: Colors.black),
                    //   builder: (dynamic data, ChartPoint<dynamic> chartPoint, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
                    //     if (data.distance < 5) {
                    //       return Container(
                    //         padding: EdgeInsets.all(5),
                    //         decoration: BoxDecoration(
                    //           color: Colors.red,
                    //           borderRadius: BorderRadius.circular(5),
                    //         ),
                    //         child: Text(
                    //           data.distance.toString(),
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //       );
                    //     } else {
                    //       return Text(
                    //         data.distance.toString(),
                    //         style: TextStyle(color: Colors.black),
                    //       );
                    //     }
                    //   },
                    // ),
                    // markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Jarak Rata-Rata: ${averageDistance.toStringAsFixed(2)} meter'),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenDistanceGraph extends StatefulWidget {
  final List<TimeSeriesDistance> data;

  const FullScreenDistanceGraph({Key? key, required this.data}) : super(key: key);

  @override
  _FullScreenDistanceGraphState createState() => _FullScreenDistanceGraphState();
}

class _FullScreenDistanceGraphState extends State<FullScreenDistanceGraph> {
  List<TimeSeriesDistance> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  // void filterData(DateTimeRange dateRange) {
  //   setState(() {
  //     filteredData = widget.data
  //         .where((speedData) =>
  //     speedData.time.isAfter(dateRange.start) &&
  //         speedData.time.isBefore(dateRange.end))
  //         .toList();
  //   });
  // }

  void filterData(DateTimeRange dateRange) {
    setState(() {
      filteredData = widget.data
          .where((distanceData) =>
      distanceData.time.isAfter(dateRange.start) &&
          distanceData.time.isBefore(dateRange.end))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    DateTime minDate = widget.data.first.time;
    DateTime maxDate = widget.data.first.time;
    for (var data in widget.data) {
      if (data.time.isBefore(minDate)) {
        minDate = data.time;
      }
      if (data.time.isAfter(maxDate)) {
        maxDate = data.time;
      }
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: header,
        centerTitle: true,
        iconTheme: const IconThemeData(color: texticon),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Data Jarak Kendaraan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () async {
                final List<DateTime>? dateTime = await showOmniDateTimeRangePicker(
                  context: context,
                  startInitialDate: minDate,
                  startFirstDate: minDate,
                  startLastDate: maxDate,
                  endInitialDate: maxDate,
                  endFirstDate: minDate,
                  endLastDate: maxDate,
                  is24HourMode: true,
                  isShowSeconds: false,
                  minutesInterval: 1,
                  secondsInterval: 1,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  constraints: const BoxConstraints(
                    maxWidth: 350,
                    maxHeight: 650,
                  ),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return FadeTransition(
                      opacity: anim1.drive(
                        Tween(
                          begin: 0,
                          end: 1,
                        ),
                      ),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                  barrierDismissible: true,
                );

                if (dateTime != null && dateTime.length == 2) {
                  DateTimeRange dateRange = DateTimeRange(
                    start: dateTime[0],
                    end: dateTime[1],
                  );
                  filterData(dateRange);
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SfCartesianChart(
            title: ChartTitle(
                text: 'meter',
                alignment: ChartAlignment.near,
                textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              enableDoubleTapZooming: true,
              enablePanning: true,
            ),
            primaryXAxis: DateTimeAxis(
              labelRotation: 45,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              majorGridLines: MajorGridLines(width: 0),
              intervalType: DateTimeIntervalType.auto,
              enableAutoIntervalOnZooming: true,
            ),
            primaryYAxis: NumericAxis(
              axisLine: AxisLine(width: 0),
              labelFormat: '{value}',
              majorTickLines: MajorTickLines(size: 0),
              plotBands: [
                PlotBand(
                    color: Colors.redAccent,
                    start: 5,
                    end: 5,
                    borderColor: Colors.red,
                    borderWidth: 2
                )
              ],
            ),
            series: [
              LineSeries<TimeSeriesDistance, DateTime>(
                dataSource: filteredData,
                xValueMapper: (TimeSeriesDistance distance, _) => distance.time,
                yValueMapper: (TimeSeriesDistance distance, _) => distance.distance,
                dataLabelSettings: DataLabelSettings(
                  isVisible: false,
                  textStyle: TextStyle(color: Colors.black),
                  builder: (dynamic data, ChartPoint<dynamic> chartPoint, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
                    if (data.distance < 5) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          data.distance.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return Text(
                        data.distance.toString(),
                        style: TextStyle(color: Colors.black),
                      );
                    }
                  },
                ),
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 2,
                  width: 2,
                ),
                onPointTap: (ChartPointDetails details) {
                  final TimeSeriesDistance tappedData = details.pointIndex != null
                      ? filteredData[details.pointIndex!]
                      : filteredData[0];
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Detail Jarak'),
                        content: Text(
                          'Waktu: ${tappedData.time}\nJarak: ${tappedData.distance} meter',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Tutup'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TimeSeriesDistance {
  final DateTime time;
  final double distance;

  TimeSeriesDistance(this.time, this.distance);
}

// class FullScreenDistanceGraph extends StatelessWidget {
//   final List<TimeSeriesDistance> data;
//
//   const FullScreenDistanceGraph({Key? key, required this.data}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: header,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: texticon),
//         title: Text('Data Jarak Kendaraan',
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: textheader
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           height: MediaQuery.of(context).size.height * 1,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: SfCartesianChart(
//             title: ChartTitle(
//                 text: 'meter',
//                 alignment: ChartAlignment.near,
//                 textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
//             ),
//             zoomPanBehavior: ZoomPanBehavior(
//               enablePinching: true,
//               enableDoubleTapZooming: true,
//               enablePanning: true,
//             ),
//             primaryXAxis: DateTimeAxis(
//               labelRotation: 45,
//               edgeLabelPlacement: EdgeLabelPlacement.shift,
//               majorGridLines: MajorGridLines(width: 0),
//               intervalType: DateTimeIntervalType.auto,
//               enableAutoIntervalOnZooming: true,
//             ),
//             primaryYAxis: NumericAxis(
//               axisLine: AxisLine(width: 0),
//               labelFormat: '{value}',
//               majorTickLines: MajorTickLines(size: 0),
//               plotBands: [
//                 PlotBand(
//                     color: Colors.redAccent,
//                     start: 5,
//                     end: 5,
//                     borderColor: Colors.red,
//                     borderWidth: 2
//                 )
//               ],
//             ),
//             series: [
//               LineSeries<TimeSeriesDistance, DateTime>(
//                 dataSource: data,
//                 xValueMapper: (TimeSeriesDistance distance, _) => distance.time,
//                 yValueMapper: (TimeSeriesDistance distance, _) => distance.distance,
//                 dataLabelSettings: DataLabelSettings(
//                   isVisible: true,
//                   textStyle: TextStyle(color: Colors.black),
//                   builder: (dynamic data, ChartPoint<dynamic> chartPoint, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
//                     if (data.distance < 5) {
//                       return Container(
//                         padding: EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           data.distance.toString(),
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       );
//                     } else {
//                       return Text(
//                         data.distance.toString(),
//                         style: TextStyle(color: Colors.black),
//                       );
//                     }
//                   },
//                 ),
//                 markerSettings: MarkerSettings(isVisible: true),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class TimeSeriesDistance {
//   final DateTime time;
//   final double distance;
//
//   TimeSeriesDistance(this.time, this.distance);
// }


// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:ta_visualisasi/configure/constants.dart';
// import 'package:ta_visualisasi/menu_utama/distance_history/distance_history.dart';
//
// class GrafDistanceHistory extends StatefulWidget {
//   final String plat;
//
//   const GrafDistanceHistory({Key? key, required this.plat}) : super(key: key);
//
//   @override
//   _GrafDistanceHistoryState createState() => _GrafDistanceHistoryState();
// }
//
// class _GrafDistanceHistoryState extends State<GrafDistanceHistory> {
//   List<TimeSeriesDistance> _datadistance = [];
//   double _totalDistance = 0.0;
//   int _dataCountdistance = 0;
//   final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");
//
//   @override
//   void initState() {
//     super.initState();
//     databaseRef.child(widget.plat).onValue.listen((event) {
//       DataSnapshot snapshot = event.snapshot;
//       if (snapshot.value != null) {
//         Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
//         _datadistance = [];
//         _totalDistance = 0.0;
//         _dataCountdistance = 0;
//
//         values?.forEach((key, value) {
//           if (value is Map<dynamic, dynamic>) {
//             value.forEach((dataKey, dataValue) {
//               if (dataValue is Map<dynamic, dynamic>) {
//                 dynamic distance = dataValue['distance'];
//                 dynamic time = dataValue['datetime'];
//                 if (distance != null && time != null && time.toString().isNotEmpty) {
//                   try {
//                     String formattedTime = time.toString().replaceAll(',  ', ' ');
//                     DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(formattedTime);
//                     double parsedDistance = double.tryParse(distance.toString()) ?? 0.0;
//                     _datadistance.add(TimeSeriesDistance(dateTime, parsedDistance));
//                     _totalDistance += parsedDistance;
//                     _dataCountdistance++;
//                   } catch (e) {
//                     if (kDebugMode) {
//                       print('Failed to parse date: $time. Error: $e');
//                     }
//                   }
//                 }
//               }
//             });
//           }
//         });
//
//         // Sort data based on time
//         _datadistance.sort((a, b) => a.time.compareTo(b.time));
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     // Calculate average distance
//     double averageDistance = _dataCountdistance > 0 ? _totalDistance / _dataCountdistance : 0.0;
//
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 10,),
//             Text('Data Jarak Kendaraan',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SizedBox(
//                   height: 30,
//                   width: 40,
//                   child: TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DistanceHistoryDisplay(plat: widget.plat),
//                           ),
//                         );
//                       },
//                       style: ButtonStyle(
//                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(button),
//                       ),
//                       child: Icon(CupertinoIcons.decrease_indent, color: texticon, size: 18,)
//                   ),
//                 ),
//                 SizedBox(width: 10,),
//                 SizedBox(
//                   height: 30,
//                   width: 40,
//                   child: TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FullScreenDistanceGraph(data: _datadistance),
//                           ),
//                         );
//                       },
//                       style: ButtonStyle(
//                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(button),
//                       ),
//                       child: Icon(CupertinoIcons.fullscreen, color: texticon, size: 18,)
//                   ),
//                 ),
//                 SizedBox(width: 10,),
//               ],
//             ),
//             SizedBox(
//               height: size.height * 0.7,
//               child: SfCartesianChart(
//                 title: ChartTitle(
//                     text: 'meter',
//                     alignment: ChartAlignment.near,
//                     textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
//                 ),
//                 zoomPanBehavior: ZoomPanBehavior(
//                   enablePinching: true,
//                   enableDoubleTapZooming: true,
//                   enablePanning: true,
//                 ),
//                 primaryXAxis: DateTimeAxis(
//                   labelRotation: 45,
//                   edgeLabelPlacement: EdgeLabelPlacement.shift,
//                   majorGridLines: MajorGridLines(width: 0),
//                   intervalType: DateTimeIntervalType.auto,
//                   enableAutoIntervalOnZooming: true,
//                 ),
//                 primaryYAxis: NumericAxis(
//                   axisLine: AxisLine(width: 0),
//                   labelFormat: '{value}',
//                   majorTickLines: MajorTickLines(size: 0),
//                   plotBands: [
//                     PlotBand(
//                         color: Colors.redAccent,
//                         start: 5,
//                         end: 5,
//                         borderColor: Colors.red,
//                         borderWidth: 2
//                     )
//                   ],
//                 ),
//                 series: [
//                   LineSeries<TimeSeriesDistance, DateTime>(
//                     dataSource: _datadistance,
//                     xValueMapper: (TimeSeriesDistance distance, _) => distance.time,
//                     yValueMapper: (TimeSeriesDistance distance, _) => distance.distance,
//                     dataLabelSettings: DataLabelSettings(
//                       isVisible: true,
//                       textStyle: TextStyle(color: Colors.black),
//                       builder: (dynamic data, ChartPoint<dynamic> chartPoint, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
//                         if (data.distance < 5) {
//                           return Container(
//                             padding: EdgeInsets.all(5),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               data.distance.toString(),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           );
//                         } else {
//                           return Text(
//                             data.distance.toString(),
//                             style: TextStyle(color: Colors.black),
//                           );
//                         }
//                       },
//                     ),
//                     markerSettings: MarkerSettings(isVisible: true),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text('Jarak Rata-Rata: ${averageDistance.toStringAsFixed(2)} meter'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FullScreenDistanceGraph extends StatelessWidget {
//   final List<TimeSeriesDistance> data;
//
//   const FullScreenDistanceGraph({Key? key, required this.data}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: header,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: texticon),
//         title: Text('Data Jarak Kendaraan',
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: textheader
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           height: MediaQuery.of(context).size.height * 1,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: SfCartesianChart(
//             title: ChartTitle(
//                 text: 'meter',
//                 alignment: ChartAlignment.near,
//                 textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
//             ),
//             zoomPanBehavior: ZoomPanBehavior(
//               enablePinching: true,
//               enableDoubleTapZooming: true,
//               enablePanning: true,
//             ),
//             primaryXAxis: DateTimeAxis(
//               labelRotation: 45,
//               edgeLabelPlacement: EdgeLabelPlacement.shift,
//               majorGridLines: MajorGridLines(width: 0),
//               intervalType: DateTimeIntervalType.auto,
//               enableAutoIntervalOnZooming: true,
//             ),
//             primaryYAxis: NumericAxis(
//               axisLine: AxisLine(width: 0),
//               labelFormat: '{value}',
//               majorTickLines: MajorTickLines(size: 0),
//               plotBands: [
//                 PlotBand(
//                     color: Colors.redAccent,
//                     start: 5,
//                     end: 5,
//                     borderColor: Colors.red,
//                     borderWidth: 2
//                 )
//               ],
//             ),
//             series: [
//               LineSeries<TimeSeriesDistance, DateTime>(
//                 dataSource: data,
//                 xValueMapper: (TimeSeriesDistance distance, _) => distance.time,
//                 yValueMapper: (TimeSeriesDistance distance, _) => distance.distance,
//                 dataLabelSettings: DataLabelSettings(
//                   isVisible: true,
//                   textStyle: TextStyle(color: Colors.black),
//                   builder: (dynamic data, ChartPoint<dynamic> chartPoint, ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {
//                     if (data.distance < 5) {
//                       return Container(
//                         padding: EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           data.distance.toString(),
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       );
//                     } else {
//                       return Text(
//                         data.distance.toString(),
//                         style: TextStyle(color: Colors.black),
//                       );
//                     }
//                   },
//                 ),
//                 markerSettings: MarkerSettings(isVisible: true),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class TimeSeriesDistance {
//   final DateTime time;
//   final double distance;
//
//   TimeSeriesDistance(this.time, this.distance);
// }
