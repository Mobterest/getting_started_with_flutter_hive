import 'dart:io';
import 'package:calendar_app/hive_objects/category.dart';
import 'package:calendar_app/hive_objects/event.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  // Declare Hive Boxes for storing Event and Category objects
  late Box<Event> eventbox;
  late Box<Category> categoryBox;

  setUpAll(() async {
    // Initialize Hive and get the path for storing Hive data
    final testPath = Directory.systemTemp.createTempSync();

    Hive.init(testPath.path);

    // Register the adapter for the Event and Category class
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(CategoryAdapter());

    // Open a Hive box for storing Event and Category objects
    eventbox = await Hive.openBox('events');
    categoryBox = await Hive.openBox('categories');
  });

  tearDown(() async {
    //Close the Hive box and Hive after each test
    await eventbox.clear();
    await categoryBox.clear();
  });

  test('Store and retrieve Event object', () async {
    // Simulating an image file path
    String imagePath = 'test/flutter.png'; // Replace with a real image path
    File file = File(imagePath);
    Uint8List imageBytes = await file.readAsBytes();

    // Create an Event object
    Event event = Event(
        HiveList(
            categoryBox), // Create a HiveList to store Event objects in the box
        DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        "Exam",
        "Prep up on state management",
        imageBytes,
        false);

    //Create Category object
    Category cat = Category("School");

    //Add it to the Category box
    await categoryBox.add(cat);

    // Add Category objects to the HiveList
    event.category.add(cat);

    // Store the Event object in the box
    await eventbox.add(event);

    //Persists this object.
    event.save();

    // Retrieve the stored Event object from the box
    final retrievedEvent = eventbox.getAt(0);

    // Assert that the retrieved   object is not null
    expect(retrievedEvent, isNotNull);

    // Assert that the retrieved Event object matches the original Event object
    expect(retrievedEvent!.eventName, event.eventName);
    expect(retrievedEvent.date, event.date);
  });

  test('Update and delete Event object in a Hive box', () async {
    // Simulating an image file path
    String imagePath = 'test/flutter.png'; // Replace with a real image path
    File file = File(imagePath);
    Uint8List imageBytes = await file.readAsBytes();

    // Add initial data to the Hive box
    Event event = Event(
        HiveList(categoryBox),
        DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        "Exam",
        "Prep up on state management",
        imageBytes,
        false);

    //Create Category object
    Category cat = Category("School");

    //Add it to the Category box
    await categoryBox.add(cat);

    // Add Category objects to the HiveList
    event.category.add(cat);

    await eventbox.add(event);

    //Persists this object.
    event.save();

    // Retrieve and verify the initial data
    final retrievedInitialEvent = eventbox.get(event.key);
    expect(retrievedInitialEvent, isNotNull);
    expect(retrievedInitialEvent!.key, event.key);
    expect(retrievedInitialEvent.eventName, event.eventName);

    // Update the data in the Hive box
    event.completed = true;
    await eventbox.put(event.key, event);

    //Persists this object.
    event.save();

    // Retrieve and verify the updated data
    final retrievedUpdatedEvent = eventbox.get(event.key);
    expect(retrievedUpdatedEvent, isNotNull);
    expect(retrievedUpdatedEvent!.key, event.key);
    expect(retrievedUpdatedEvent.completed, event.completed);

    // Delete the data from the Hive box
    await eventbox.delete(event.key);

    // Verify that the data has been deleted
    final deletedData = eventbox.get(event.key);
    expect(deletedData, isNull);
  });
}
