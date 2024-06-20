import 'package:hive/hive.dart';

import '../models/notes_model.dart';

class Boxes {
  static Box<NoteModel> getData() => Hive.box<NoteModel>('notes');
}
