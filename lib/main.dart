import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_crud/boxes/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/notes_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('notes');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  var box = Hive.box<NoteModel>('notes');
  ValueNotifier<List<NoteModel>> data = ValueNotifier([]);
  List<NoteModel> items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    data.value = box.values.toList().cast<NoteModel>();
    items = data.value;
  }

  Future<void> getupdateData() async {
    data.value = box.values.toList().cast<NoteModel>();
    items = data.value;
  }

  Future<void> getItemsByName(String name) async {
    if (name.isEmpty) {
      data.value = items;
    } else {
      print(name);
      try {
        data.value = box.values
            .where((item) => item.title.contains(name))
            .toList()
            .cast<NoteModel>();

        print('nameeee${data.value.length}');
      }
      //await box.close();}

      catch (e) {
        print('exception catch$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive Databse"),
      ),
      body: ValueListenableBuilder<List<NoteModel>>(
        valueListenable: data,
        builder: (context, box, _) {
          print(' types:${data.runtimeType}');

          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: TextField(
                  onChanged: (value) {
                    print(value);
                    // runfilter(value);
                    getItemsByName(value);
                    setState(() {});
                  },
                  //runfilter(value)
                  //

                  decoration: InputDecoration(
                      labelText: "search", suffixIcon: Icon(Icons.search)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  //reverse: true,
                  shrinkWrap: true,
                  itemCount: data.value.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => {
                                _editDialog(
                                    data.value[index],
                                    data.value[index].title.toString(),
                                    data.value[index].description.toString()),
                              },
                              backgroundColor: Colors.grey,
                              icon: Icons.edit,
                              label: "edit",
                            ),
                            SlidableAction(
                              onPressed: (context) =>
                                  {delete(data.value[index]), getupdateData()},
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: "delete",
                            )
                          ],
                        ),
                        child: Container(
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            data.value[index].title.toString()),
                                      ],
                                    ),
                                    Text(data.value[index].description
                                        .toString()),
                                  ]),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showMyDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void delete(NoteModel noteModel) async {
    await noteModel.delete();
    getupdateData();
  }

  Future<void> _editDialog(
      NoteModel noteModel, String title, String description) async {
    titleController.text = title;
    descriptionController.text = description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Notes'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: 'Enter Title', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: 'Enter description',
                    border: OutlineInputBorder()),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
          TextButton(
              onPressed: () async {
                noteModel.title = titleController.text.toString();
                noteModel.description = descriptionController.text.toString();
                noteModel.save();
                getupdateData();
                Navigator.pop(context);
              },
              child: Text("Edit"))
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: 'Enter Title', border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: 'Enter description',
                    border: OutlineInputBorder()),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
          TextButton(
              onPressed: () {
                final data = NoteModel(
                    title: titleController.text,
                    description: descriptionController.text);
                final box = Boxes.getData();
                box.add(data);
                //  data.save();
                titleController.clear();
                descriptionController.clear();
                getupdateData();
                Navigator.pop(context);
              },
              child: Text("Add"))
        ],
      ),
    );
  }
}
