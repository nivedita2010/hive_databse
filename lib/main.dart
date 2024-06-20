import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('shopping_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController namecnt = TextEditingController();
   final TextEditingController mailcnt = TextEditingController();
  final TextEditingController agecnt = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> __founduser = [];
  List<Map<String, dynamic>> _items = [];
  final _shopingBox = Hive.box('shopping_box');
  @override
  void initState() {
    super.initState();
    _refreshItems();
    __founduser = _items;
  }

  void _refreshItems() {
    final data = _shopingBox.keys.map((key) {
      final item = _shopingBox.get(key);
      return {
        "key": key,
        "name": item["name"],
        "description": item["description"],
        // "mail": item["mail"]
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shopingBox.add(newItem);
    _refreshItems();
    // print("amount data is ${_shopingBox.length}");
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _shopingBox.put(itemkey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _shopingBox.delete(itemkey);
    _refreshItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("An  item has deleted")));
  }

  //_createItem
  void _showform(BuildContext ctx, int? itemkey) async {
    if (itemkey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemkey);
      namecnt.text = existingItem['name'];
      agecnt.text = existingItem['age'];
      mailcnt.text = existingItem['mail'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Form(
                //  key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: namecnt,
                      keyboardType: TextInputType.name,
                      validator: ((value) {
                           if (value!.isEmpty) {
                          return 'Name Field is required';
                        }
                      }),
                      decoration: InputDecoration(
                        label: Text("enter name"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: mailcnt,
                      keyboardType: TextInputType.emailAddress,
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Name Field is required';
                        }
                        if (!RegExp(
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                        ).hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                      }),
                      decoration: InputDecoration(
                          label: Text("enter mail"),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: agecnt,
                      keyboardType: TextInputType.number,
                      /*validator: ((value) {
                        if (value!.isEmpty) {
                          return ' Field is required';
                        }
                      }),*/
                      decoration: InputDecoration(
                          label: Text("enter age"),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          /*if (!_formKey.currentState!.validate()) {
                            return;
                          }*/
                          if (itemkey == null) {
                            _createItem({
                              "name": namecnt.text,
                              "": agecnt.text,
                              // "mail": mailcnt.text,
                            });
                          }
                          if (itemkey != null) {
                            _updateItem(itemkey, {
                              'name': namecnt.text.trim(),
                              'age': agecnt.text.trim(),
                              // 'mail': mailcnt.text.trim(),
                            });
                          }
                          namecnt.text = '';
                          agecnt.text = '';
                          // mailcnt.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(itemkey == null ? 'Create new' : 'Upadte')),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ));
  }

  void _runFilter(String enterkey) {
    List<Map<String, dynamic>> results = [];
    if (enterkey.isEmpty) {
      results = _items;
    } else {
      print("match");
      results = _items
          .where((user) =>
              user['name'].toLowerCase().contains(enterkey.toLowerCase()))
          .toList();
    }
    setState(() {
      __founduser = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showform(context, null);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          TextField(
            onChanged: (value) => _runFilter(value),
            decoration: const InputDecoration(
              labelText: 'search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: __founduser.length,
              itemBuilder: (_, index) {
                final currentItem = __founduser[index];
                return Card(
                  key: ValueKey(currentItem['key']),
                  color: Colors.orange.shade100,
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentItem['name']),
                    subtitle: Text(currentItem['age'].toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              _showform(context, currentItem['key']),
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteItem(currentItem['key']);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
