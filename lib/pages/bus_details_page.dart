import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/providers/auth_provider.dart';
import '../widgets/reusable/bus_details_page/bus_card.dart';

class BusDetailsPage extends ConsumerWidget {
  const BusDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = (authState.currentUser?.name != null &&
            authState.currentUser!.name.trim().isNotEmpty)
        ? authState.currentUser!.name.trim()
        : "Passenger";

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
                  children: [
                    Text("Hello $userName!",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Select your bus!",
                        style: TextStyle(color: Color(0xffFFD800), fontSize: 14)),
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
              color:  Color(0xffFFD800),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
              
                Image.asset('assets/images/Bus_Image.png',width: 150, height: 75, ),
                
                const SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Lorem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.swap_horiz, color: Colors.white, ),
                    ),
                    const Text("Lorem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  ],
                ),
                const SizedBox(height: 12,),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12)

                  ),
                  child: const Text("08 th - Dec - 2024 | Sunday", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                ),

                const SizedBox(height: 12,),
              ],
            ),
           ),
                        
            BusCard(
              name: "Silva Travels",
              type: "A/C Sleeper (2+2)",
              time: "9:00 AM - 9:45 AM",
              price: "\$200",
              duration: "45 Min",
              seatsLeft: 15,
              seatColor: Colors.green,
            ),

            BusCard(
              name: "Silva Travels",
              type: "A/C Sleeper (2+2)",
              time: "9:00 AM - 9:45 AM",
              price: "\$200",
              duration: "45 Min",
              seatsLeft: 15,
              seatColor: Colors.green,
            ),


            BusCard(
              name: "Silva Travels",
              type: "A/C Sleeper (2+2)",
              time: "9:00 AM - 9:45 AM",
              price: "\$200",
              duration: "45 Min",
              seatsLeft: 15,
              seatColor: Colors.green,
            ),

             BusCard(
              name: "Silva Travels",
              type: "A/C Sleeper (2+2)",
              time: "9:00 AM - 9:45 AM",
              price: "\$200",
              duration: "45 Min",
              seatsLeft: 15,
              seatColor: Colors.green,
            ),
          ],
         ),
      ),
    );
  }

}
