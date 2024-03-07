import 'dart:convert';
import 'dart:io';
import 'package:events_app/db_connections/data_post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  String? jwt;
  HomePage( {required this.jwt, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController e_id_controller = new TextEditingController();
  TextEditingController title_controller = new TextEditingController();
  TextEditingController details_controller = new TextEditingController();
  TextEditingController date_controller = new TextEditingController();
  TextEditingController time_controller = new TextEditingController();
  TextEditingController prize_money_controller = new TextEditingController();
  TextEditingController entry_pass_controller = new TextEditingController();
  TextEditingController image_link_controller = new TextEditingController();
  String? eid;
  String? title;
  String? details;
  DateTime selectedDate = DateTime.now();
  String? time;
  int? prize_money;
  int? entry_pass;
  String? image_link;
  String? Date;
  File? _imageFile;
  String? _imageUrl;
  bool _uploadingImage = false;
  String? jwt="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jwt = widget.jwt;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Events App')),
        actions:[ IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
              jwt= '';
              Navigator.pop(context);
          },
        ),
      ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.date_range_rounded,
                      size: 35,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                  Text(
                    Date == null ? " Select Date" : " $Date",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    eid = _value.toString();
                  },
                  controller: e_id_controller,
                //  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the E_ID'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    title = _value.toString();
                  },
                  controller: title_controller,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the title'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    details = _value.toString();
                  },
                  controller: details_controller,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the Details'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    time = _value.toString();
                  },
                  controller: time_controller,
                 // keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the Time'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    prize_money = int.parse(_value);
                  },
                  controller: prize_money_controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the Prize Money'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextFormField(
                  onChanged: (_value) {
                    entry_pass = int.parse(_value);
                  },
                  controller: entry_pass_controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Enter the Entry Pass'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                    child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Select picture'),
                    ),
                    if (_imageFile != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Image.file(_imageFile!)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_uploadingImage) {
                              _uploadImage();
                            }
                          },
                          child: _uploadingImage
                              ? CircularProgressIndicator()
                              : const Text('Upload'),
                        ),
                      ),
                    ],
                    if (_imageUrl != null) ...[
                      //Image.network(_imageUrl!),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("Image Link :\n\n$_imageUrl"),
                      )
                    ]
                  ],
                )),
              ),
              if (_imageUrl != null)

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      image_link = _imageUrl;

                      if (eid == null ||
                          title == null ||
                          details == null ||
                          time == null ||
                          prize_money == null ||
                          entry_pass == null ||
                          image_link == null ||
                          Date == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Please fill the above details"),
                          duration: Duration(seconds: 2),
                        ));
                      } else {
                        if (await postData(
                            jwt!,
                            eid.toString(),
                            title ?? "",
                            details ?? "",
                            Date.toString(),
                            time.toString(),
                            prize_money.toString(),
                            entry_pass.toString(),
                            image_link ?? "")) {
                          setState(() {
                            e_id_controller.clear();
                             title_controller.clear();
                             details_controller.clear();
                             date_controller.clear();
                             time_controller.clear();
                             prize_money_controller.clear();
                             entry_pass_controller.clear();
                             image_link_controller.clear();
                            eid= null;
                            title = null;
                            details =null;
                            Date = null;
                            time = null;
                            prize_money = null;
                            entry_pass =null;
                            image_link = null;
                            _imageFile = null;
                            _imageUrl = null;
                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Data submitted successfully"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Data Submission Fails"),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 2),
                          ));
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        Date = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      _uploadingImage = true;
    });
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/dgs7fbmta/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'alumni_student_platform'
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = utf8.decode(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        final url = jsonMap['url'];
        _imageUrl = url;
        _uploadingImage = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) _imageFile = File(pickedFile.path);
    });
  }
}
