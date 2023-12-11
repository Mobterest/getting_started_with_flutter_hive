import 'package:calendar_app/widgets/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'eventlist.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime daySelected = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool search = false;
  final TextEditingController searchController = TextEditingController();
  bool viewAll = false;
  bool filter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: (search)
            ? TextField(
                controller: searchController,
                cursorColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    viewAll = false;
                    filter = true;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    hintText: "Search here",
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white)),
              )
            : const Text(
                "Calendar App",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
        centerTitle: false,
        actions: [
          (search)
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      search = false;
                    });
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      search = true;
                      viewAll = true;
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Visibility(
            visible: !search,
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  focusedDay: daySelected,
                  currentDay: daySelected,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      daySelected = selectedDay;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, EventDetails.routeName,
                            arguments: EventArguments(
                                daySelected: DateTime.utc(daySelected.year,
                                    daySelected.month, daySelected.day),
                                view: false));
                      },
                      label: const Text("Add Event"),
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
          ),
          EventList(
              all: viewAll,
              filter: filter,
              searchTerm: searchController.text,
              date: DateTime.utc(
                  daySelected.year, daySelected.month, daySelected.day))
        ],
      )),
    );
  }
}
