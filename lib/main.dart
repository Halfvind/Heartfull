// main.dart
import 'package:flutter/material.dart';

import 'json_render.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Heartfullness',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  List<Map<String, dynamic>> saveddatalist = [];
  List<Map<String, dynamic>> _foundUsers = [];
  List<Map<String, dynamic>> results = [];



  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      saveddatalist = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {

    super.initState();
    _refreshJournals();

  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final String enteredValue="";
  String? gender;



  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      saveddatalist.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      contact.text = existingJournal['contact'];
      gender = existingJournal['gender'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: contact,
                decoration: const InputDecoration(hintText: 'contact'),
              ),
              Container(
                child: RadioListTile(
                  title: Text("Male"),
                  value: "male",
                  groupValue: gender,
                  onChanged: (value){
                    setState(() {
                      gender = value.toString();
                      print(gender);
                      print(value);
                    });
                  },
                ),
              ),
              Container(
                child: RadioListTile(
                  title: Text("female"),
                  value: "female",
                  groupValue: gender,
                  onChanged: (value){
                    setState(() {
                      gender = value.toString();
                      print(gender);
                      print(value);
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                      await _addItem();

                  }
                  if (id != null) {
                      await _updateItem(id);


                  }

                  // Clear the text fields
                  _titleController.text = '';
                  _descriptionController.text = '';
                  contact.text = '';
                  gender ='';

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text, contact.text,gender);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text, contact.text,gender);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD operation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFdbdbdb),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (val){
                    _runFilter(val);
                    },
                    enabled: true,
                    // controller: enteredValue,
                    textInputAction: TextInputAction.next,
                    onSaved: (email) {},
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "--search--",contentPadding: EdgeInsets.all(15),
                        suffixIcon: GestureDetector(
                          child: Icon(Icons.search),
                          onTap: (){},
                        ),
                      ),
                  ),
                ],
              ),
            ),
            Container(
              child: saveddatalist.isNotEmpty?
              ListView.builder(
                shrinkWrap: true,
                itemCount: saveddatalist.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.orange[200],
                  margin: const EdgeInsets.all(15),
                  child: Container(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(saveddatalist[index]['title']),
                          subtitle: Text(saveddatalist[index]['description']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showForm(saveddatalist[index]['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteItem(saveddatalist[index]['id']),
                                ),
                              ],
                            ),
                          ),

                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(left: 15,bottom: 5),
                          child: Text(saveddatalist[index]['contact']),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(left: 15,bottom: 5),
                          child: Text(saveddatalist[index]['gender']),
                        ),

                      ],
                    ),
                  ),
                ),
              ):Text("no data"),
            )


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            _showForm(null);
          });
        },
      ),
      bottomNavigationBar: Container(
         child: ElevatedButton(
           child: Text("For Json render"),
           onPressed: (){
             Navigator.push(context, MaterialPageRoute(builder: (context) => Json_Render(),));
           },
         ),
      )
    );
  }

  /* Textform field search filter */

  void _runFilter(String enteredKeyword) {
    print(enteredKeyword);
    print("enteredKeyword");

///working but need to check
 /*    for(int i=0;i<saveddatalist.length;i++){
       print(saveddatalist);
       if (saveddatalist[i]["title"].toLowerCase() == enteredValue.toLowerCase()) {
         print('IF');
         saveddatalist.add(_foundUsers[i]);
         break;
       }
     }*/


    //working.............
    if (enteredKeyword.isNotEmpty) {
      _foundUsers = saveddatalist
          .where((user) =>
          user["title"].toLowerCase().contains(enteredKeyword.toLowerCase()) || user["gender"].toLowerCase().contains(enteredKeyword.toLowerCase())||user["description"].toLowerCase().contains(enteredKeyword.toLowerCase())||user["contact"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      // Refresh the UI
      setState(() {
        saveddatalist=_foundUsers;
        _foundUsers = results;

      });

    } else if(enteredKeyword.isEmpty){

    }


  }
}