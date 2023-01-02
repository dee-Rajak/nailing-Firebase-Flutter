import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:learning_firebase/models/student_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  List<Student> studentList = [];

  bool updateStudent = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retriveStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          for (int i = 0; i < studentList.length; i++)
            studentWidget(studentList[i])
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.text = "";
          _ageController.text = "";
          _subjectController.text = "";
          updateStudent = false;
          studentDialog();
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  void studentDialog({String? key}) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(helperText: 'Name'),
                  ),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(helperText: 'Age'),
                  ),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(helperText: 'Subject'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> data = {
                        "name": _nameController.text.toString(),
                        "age": _ageController.text.toString(),
                        "subject": _subjectController.text.toString(),
                      };

                      if (updateStudent) {
                        dbRef
                            .child("Students")
                            .child(key!)
                            .update(data)
                            .then((value) {
                          int index = studentList
                              .indexWhere((element) => element.key == key);
                          studentList.removeAt(index);
                          studentList.insert(
                              index,
                              Student(
                                  key: key,
                                  studentData: StudentData.fromJson(data)));
                          setState(() {});
                          Navigator.of(context).pop();
                        });
                      } else {
                        dbRef.child("Students").push().set(data).then((value) {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: Text(updateStudent ? 'Update Data' : 'Save Data'),
                  )
                ],
              ),
            ),
          );
        });
  }

  void retriveStudentData() {
    dbRef.child("Students").onChildAdded.listen((data) {
      StudentData studentData =
          StudentData.fromJson(data.snapshot.value as Map);
      Student student =
          Student(key: data.snapshot.key, studentData: studentData);
      studentList.add(student);
      setState(() {});
    });
  }

  Widget studentWidget(Student student) {
    return InkWell(
        onTap: () {
          _nameController.text = student.studentData!.name!;
          _ageController.text = student.studentData!.age!;
          _subjectController.text = student.studentData!.subject!;
          updateStudent = true;
          studentDialog(key: student.key);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.studentData!.name!),
                  Text(student.studentData!.age!),
                  Text(student.studentData!.subject!),
                ],
              ),
              InkWell(
                onTap: () {
                  dbRef
                      .child('Students')
                      .child(student.key!)
                      .remove()
                      .then((value) {
                    int index = studentList
                        .indexWhere((element) => element.key == student.key!);
                    studentList.removeAt(index);
                    setState(() {});
                  });
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ));
  }
}
