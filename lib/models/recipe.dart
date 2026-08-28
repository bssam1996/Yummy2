
class Recipe {
  String id;
  String parentId;
  String sharing;
  DateTime created;
  String type;
  String title;
  String description;
  String ingredients;
  String directions;
  int numberOfMinutes;
  int ovenTemp;
  int servings;
  String notes;
  List<dynamic>? videos;
  Recipe({
    required this.id,
    this.parentId = "",
    this.sharing = "Private",
    required this.created,
    this.type = "",
    this.title = "",
    this.description = "",
    this.ingredients = "",
    this.directions = "",
    this.numberOfMinutes = 0,
    this.ovenTemp = 0,
    this.servings = 0,
    this.notes = "",
    this.videos = const []});
}