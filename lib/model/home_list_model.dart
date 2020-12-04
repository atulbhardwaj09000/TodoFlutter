class HomeListModel {
  String task;
  bool completed;
  int position;
  String id;

  HomeListModel(String task, bool completed, int position, String id) {
    this.task = task;
    this.completed = completed;
    this.id = id;
    this.position = position;
  }
}
