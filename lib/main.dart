import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:tester3/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tester3',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        const SizedBox(width: 90),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 50),
            Joystick(
              listener: (details) {
                double x = details.x;
                double y = details.y;
                String direction = "center";
                // Deadzone (optional, add your logic here)
                // Calculate direction based on quadrant
                if (x > 0 && y > 0) {
                  direction = "Up-Right"; // Quadrant 1
                } else if (x < 0 && y > 0) {
                  direction = "Up-Left"; // Quadrant 2
                } else if (x < 0 && y < 0) {
                  direction = "Down-Left"; // Quadrant 3
                } else if (x > 0 && y < 0) {
                  direction = "Down-Right"; // Quadrant 4
                } else if (x.abs() > 0.1 && y.abs() < 0.1) {
                  // X-axis movement (adjust deadzone)
                  direction = x > 0 ? "Right" : "Left";
                } else if (x.abs() < 0.1 && y.abs() > 0.1) {
                  // Y-axis movement (adjust deadzone)
                  direction = y > 0 ? "Up" : "Down";
                }

                // Handle direction based on your needs
                print("Joystick direction: $direction");
                FirebaseFirestore.instance
                    .collection("System")
                    .doc("System")
                    .update({'vehicle_direction': direction});
                // This is your string output
              },
              // ... other joystick properties
            ),
            const SizedBox(
              height: 30,
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("System")
                    .doc("System")
                    .snapshots(),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      Text(
                          'Sensor_1 = ${snapshot.data!.data()!["sensor1"].toString()}'),
                      Text(
                          'Sensor_2 = ${snapshot.data!.data()!["sensor2"].toString()}'),
                      Text(
                          'Sensor_3 = ${snapshot.data!.data()!["sensor3"].toString()}'),
                    ],
                  );
                }),
            const SizedBox(
              height: 30,
            ),
            const PowerButton(),
          ],
        ),
      ],
    ));
  }
}

class PowerButton extends StatefulWidget {
  const PowerButton({super.key});

  @override
  State<PowerButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<PowerButton> {
  bool _PowerOn = true; // Flag to track button state

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        FirebaseFirestore.instance
            .collection("System")
            .doc("System")
            .update({'power_state': _PowerOn});
        setState(() => _PowerOn = !_PowerOn);
      }, // Toggle state on press
      style: ElevatedButton.styleFrom(
        backgroundColor: _PowerOn ? Colors.green : Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(_PowerOn ? 'Power on' : 'Power off'),
    );
  }
}
