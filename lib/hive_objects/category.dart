import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1, adapterName: "CategoryAdapter")
class Category extends HiveObject {
  @HiveField(0)
  String name;

  Category(this.name);
}
