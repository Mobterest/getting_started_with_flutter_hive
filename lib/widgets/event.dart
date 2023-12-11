import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_app/hive_objects/category.dart';
import 'package:calendar_app/hive_objects/event.dart';
import 'package:calendar_app/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:status_alert/status_alert.dart';

import '../func.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  static const routeName = "event";

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> with Func {
  final _formKey = GlobalKey<FormState>();
  Category? dropdownValue;
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController eventnameController = TextEditingController();
  final TextEditingController eventdescriptionController =
      TextEditingController();
  Uint8List? imageBytes;
  bool completed = false;
  bool viewed = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EventArguments;

    if (args.view && !viewed) {
      setState(() {
        dropdownValue = args.event?.category[0];
        eventnameController.text = args.event!.eventName;
        eventdescriptionController.text = args.event!.eventDescription;
        imageBytes = args.event!.file;
        completed = args.event!.completed;
        viewed = true;
      });
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          "Event",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: (args.view)
                  ? () {
                      updateExisitngEvent(args, context);
                    }
                  : null,
              icon: const Icon(Icons.save)),
          IconButton(
              onPressed: (args.view)
                  ? () {
                      deleteMethod(context, args);
                    }
                  : null,
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ValueListenableBuilder<Box<Category>>(
                          valueListenable: categoryBox.listenable(),
                          builder: (context, box, widget) {
                            return DropdownButton(
                                focusColor: const Color(0xffffffff),
                                dropdownColor: const Color(0xffffffff),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                value: dropdownValue,
                                items: box.values
                                    .toList()
                                    .map<DropdownMenuItem<Category>>(
                                        (Category value) {
                                  return DropdownMenuItem(
                                      value: value, child: Text(value.name));
                                }).toList(),
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                });
                          }),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          createNewCategory(context);
                        },
                        child: const Icon(Icons.add))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.deepPurple,
                    ),
                    Text(
                      DateFormat("EEEE d MMMM").format(args.daySelected),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: eventnameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Event name",
                      labelStyle: TextStyle(color: Colors.deepPurpleAccent)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: eventdescriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Event description",
                      labelStyle: TextStyle(color: Colors.deepPurpleAccent)),
                ),
              ),
              ListTile(
                tileColor: Colors.deepPurpleAccent,
                textColor: Colors.white,
                iconColor: Colors.white,
                title: const Text("Upload file"),
                trailing: (imageBytes != null)
                    ? const Icon(Icons.done)
                    : const Icon(Icons.upload),
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    imageBytes = await file.readAsBytes();
                    setState(() {});
                  }
                },
              ),
              (imageBytes != null)
                  ? Image.memory(
                      imageBytes!,
                      width: 100,
                    )
                  : const SizedBox.shrink(),
              SwitchListTile(
                  value: completed,
                  title: const Text(
                    "Event completed?",
                    style:
                        TextStyle(color: Colors.deepPurpleAccent, fontSize: 14),
                  ),
                  onChanged: (bool? value) {
                    setState(() {
                      completed = value!;
                    });
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: (args.view)
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  dropdownValue != null) {
                                await addEvent(
                                    Event(
                                        HiveList(categoryBox),
                                        args.daySelected,
                                        eventnameController.text,
                                        eventdescriptionController.text,
                                        imageBytes,
                                        completed),
                                    dropdownValue!);

                                if (context.mounted) {
                                  StatusAlert.show(context,
                                      duration: const Duration(seconds: 2),
                                      title: 'Calendar App',
                                      subtitle: 'Event added',
                                      configuration: const IconConfiguration(
                                          icon: Icons.done),
                                      maxWidth: 260);

                                  Navigator.pop(context);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: const RoundedRectangleBorder(),
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.8, 50)),
                      child: const Text("Add")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  createNewCategory(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "New Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            content: TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Add category",
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent)),
            ),
            actions: [
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurpleAccent),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurpleAccent),
                  onPressed: () {
                    if (categoryController.text.isNotEmpty) {
                      addCategory(Category(categoryController.text));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"))
            ],
          );
        });
  }

  updateExisitngEvent(EventArguments args, BuildContext context) {
    args.event?.category = HiveList(categoryBox);
    args.event?.date = args.daySelected;
    args.event?.eventName = eventnameController.text;
    args.event?.eventDescription = eventdescriptionController.text;
    args.event?.file = imageBytes;
    args.event?.completed = completed;
    updateEvent(args.event!, dropdownValue!);
    if (context.mounted) {
      StatusAlert.show(context,
          duration: const Duration(seconds: 2),
          title: 'Calendar App',
          subtitle: 'Event updated!',
          configuration: const IconConfiguration(icon: Icons.done),
          maxWidth: 260);

      Navigator.pop(context);
    }
  }

  deleteMethod(BuildContext context, EventArguments args) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Calendar App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            content: const Text("Do you want to delete this event?"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    deleteEvent(args.event!);

                    if (context.mounted) {
                      StatusAlert.show(context,
                          duration: const Duration(seconds: 2),
                          title: 'Calendar App',
                          subtitle: 'Event deleted!',
                          configuration:
                              const IconConfiguration(icon: Icons.done),
                          maxWidth: 260);

                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent),
                  child: const Text("Yes")),
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurpleAccent),
                  child: const Text("No"))
            ],
          );
        });
  }
}

class EventArguments {
  final DateTime daySelected;
  final Event? event;
  final bool view;

  EventArguments({required this.daySelected, required this.view, this.event});
}
