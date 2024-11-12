import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';

class TiltHistoryDisplay extends StatefulWidget {
  // static String routeName = "/TiltHistoryDisplay";
  // const TiltHistoryDisplay({Key? key}) : super(key: key);
  final String plat;

  const TiltHistoryDisplay({Key? key, required this.plat}) : super(key: key);

  @override
  State<TiltHistoryDisplay> createState() => _TiltHistoryDisplayState();
}

class _TiltHistoryDisplayState extends State<TiltHistoryDisplay> {
  final databaseRef = FirebaseDatabase.instance.reference().child("DataPerjalanan");

  _buildNoDataAvailableMessage() {
    return Center(
      child: Text(
        "Data Tidak Tersedia",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      //backgroundColor: Color.fromRGBO(255, 230, 173, 1.0),
      appBar: AppBar(
        backgroundColor: header,
        //backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // const SizedBox(width: 8),
             Text(
              'Tilt Data',
              style: TextStyle(color: textheader),
            ),
             SizedBox(width: 10),
             Icon(MyFlutterApp.gyroscope, color: texticon),
             //Icon(Icons.history, color: Colors.black),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: texticon),
      ),
      body: SafeArea(
        child: FirebaseAnimatedList(
          query: databaseRef.child(widget.plat).orderByChild('DateUnggah').limitToLast(1),
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
            dynamic value = snapshot.value;
            if (!(value is Map<dynamic, dynamic>)) {
              return Container();
            }
            List<Map<dynamic, dynamic>> journeys = [];
            value.forEach((key, value) {
              if (value is Map<dynamic, dynamic>) {
                journeys.add(value);
              }
            });

            // Filter out journeys with null datetime
            journeys = journeys.where((journey) => journey['datetime'] != null).toList();

            if (journeys.isEmpty) {
              return _buildNoDataAvailableMessage();
            }

            // Sort list of journeys by datetime
            journeys.sort((a, b) => a['datetime'].compareTo(b['datetime']));

            return Column(
              children: journeys.map<Widget>((journey) {
                var acceldatax = journey['accel_data_x'] as num?;
                var acceldatay = journey['accel_data_y'] as num?;
                var acceldataz = journey['accel_data_z'] as num?;
                if (acceldatax == null || acceldatay == null || acceldataz == null) {
                  return Container();
                }

                var time = journey['datetime'] as String?;
                var gyrodatax = journey['gyro_data_x'] as num?;
                var gyrodatay = journey['gyro_data_y'] as num?;
                var gyrodataz = journey['gyro_data_z'] as num?;
                if (time == null || gyrodatax == null || gyrodatay == null || gyrodataz == null) {
                  return Container();
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text('Gyro Time: $time'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Accel Data:'),
                          Text('X=${acceldatax.toStringAsFixed(5)}'),
                          Text('Y=${acceldatay.toStringAsFixed(5)}'),
                          Text('Z=${acceldataz.toStringAsFixed(5)}'),
                          const SizedBox(height: 8),
                          const Text('Gyro Data:'),
                          Text('X=${gyrodatax.toStringAsFixed(5)}'),
                          Text('Y=${gyrodatay.toStringAsFixed(5)}'),
                          Text('Z=${gyrodataz.toStringAsFixed(5)}'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

