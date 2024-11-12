import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:ta_visualisasi/configure/constants.dart';
import 'package:ta_visualisasi/configure/my_flutter_app_icons.dart';

class SpeedHistoryDisplay extends StatefulWidget {
  final String plat;

  const SpeedHistoryDisplay({Key? key, required this.plat}) : super(key: key);

  @override
  State<SpeedHistoryDisplay> createState() => _SpeedHistoryDisplayState();
}

class _SpeedHistoryDisplayState extends State<SpeedHistoryDisplay> {
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
      appBar: AppBar(
        backgroundColor: header,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Speed Data',
              style: TextStyle(color: textheader),
            ),
            SizedBox(width: 10),
            Icon(MyFlutterApp.speed, color: texticon),
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
            if (value == null || value is! Map<dynamic, dynamic>) {
              return _buildNoDataAvailableMessage();
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
                String? speed = journey['speed']?.toString();
                String? datetime = journey['datetime'] as String?;

                if (speed == null || datetime == null) {
                  return SizedBox(); // Ignore invalid entries
                }

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        "$speed km/h",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date Time: $datetime'),
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
