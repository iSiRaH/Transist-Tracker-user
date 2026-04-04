import 'package:flutter/material.dart';
import '../widgets/reusable/find_bus_page/destination_input_field.dart';
import '../widgets/reusable/find_bus_page/border_component.dart';

class FindBusPage extends StatelessWidget {
  const FindBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                  radius: 24,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Hello Rose!",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Where you want to go?",
                        style:
                            TextStyle(color: Color(0xffFFD800), fontSize: 14)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.filter_list, size: 26),
                const SizedBox(width: 12),
                const Icon(Icons.notifications_none, size: 26),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xffFFD800),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  DestinationInputField(
                    hintname: "Boarding From",
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  DestinationInputField(
                    hintname: "Where are you going",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BorderComponent(name: "Today", iconName: Icons.today),
                      BorderComponent(
                          name: "Tomorrow", iconName: Icons.calendar_today),
                      BorderComponent(
                          name: "Other", iconName: Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      "Find Buses",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
