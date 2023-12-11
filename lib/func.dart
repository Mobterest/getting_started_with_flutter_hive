import 'hive_objects/category.dart';
import 'hive_objects/event.dart';
import 'main.dart';

mixin Func {
  /// Create a New Event
  addEvent(Event event, Category cat) async {
    event.category.add(cat);
    await eventBox.add(event);
    event.save();
  }

  /// Create a New Category
  addCategory(Category category) async {
    await categoryBox.add(category);
  }

  List<Event> getEventsByDate(DateTime dateTime) {
    return eventBox.values.where((event) => event.date == dateTime).toList();
  }

  updateEvent(Event event, Category cat) async {
    event.category.clear();
    event.category.add(cat);
    await eventBox.put(event.key, event);
    event.save();
  }

  deleteEvent(Event event) async {
    await eventBox.delete(event.key);
  }

  List<Event> searchEvent(String searchWord) {
    return eventBox.values
        .where((event) =>
            event.eventName.contains(searchWord) ||
            event.eventDescription.contains(searchWord) ||
            event.category[0].name.contains(searchWord))
        .toList();
  }

  List<Event> getByCategory(String category) {
    return eventBox.values
        .where((event) => event.category[0].name.contains(category))
        .toList();
  }
}
