import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../shared/loading.dart';
import '/shared/snack.dart';
import 'package:flutter/services.dart';

import '/models/user.dart';

import '/configurations/configurations.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
class userQRPage extends StatefulWidget {
  CustomUser? customUser;
  userQRPage({this.customUser});
  @override
  _userQRPageState createState() => _userQRPageState();
}

class _userQRPageState extends State<userQRPage> {
  TextEditingController useridcontroller = new TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  final RoundedLoadingButtonController _createController = new RoundedLoadingButtonController();
  TextEditingController NameController = new TextEditingController();
  TextEditingController PhoneController = new TextEditingController();
  final customstyle = TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.deepPurple);
  @override
  Widget build(BuildContext context) {
    CustomUser? customUser = widget.customUser;
    if(customUser != null){
      useridcontroller.text = customUser.uid;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(Configurations().globalAppName),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').doc(widget.customUser?.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return Loading();
            NameController.text = (NameController.text == "") ? ((snapshot.data?.data() as Map)["Name"] ?? "") : NameController.text;
            PhoneController.text = (PhoneController.text == "") ? ((snapshot.data?.data() as Map)["Phone"] ?? "") : PhoneController.text;
            return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Your info",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.indigoAccent),),
                        Divider(),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
                              icon: Icon(Icons.border_color),
                              hintText: "What is the full name",
                              labelText: "Your Name"
                          ),
                          controller: NameController,
                        ),
                        Divider(),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
                              icon: Icon(Icons.phone),
                              hintText: "What is the phone number",
                              labelText: "Your number"
                          ),
                          controller: PhoneController,
                          keyboardType: TextInputType.number,
                        ),
                        Divider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "User ID",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue
                              ),
                            ),
                            Divider(),
                            BarcodeWidget(
                              barcode: Barcode.qrCode(),
                              data: customUser?.uid ?? "",
                              width: 150.0,
                              height: 150.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: TextField(
                                textAlign: TextAlign.center,
                                readOnly: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            50.0)),
                                    labelText: "User ID",
                                    suffixIcon: Container(
                                      width: 50,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              try {
                                                if (useridcontroller.text
                                                    .isNotEmpty) {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: useridcontroller
                                                              .text));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                      snack().displaySnackBar(
                                                          "Copied",
                                                          Colors.green));
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                    snack().displaySnackBar(
                                                        e.toString(),
                                                        Colors.red));
                                              }
                                            },
                                            icon: Icon(Icons.copy),
                                            iconSize: 20,
                                          )
                                        ],
                                      ),
                                    )
                                ),
                                controller: useridcontroller,
                              ),
                            ),
                          ],
                        ),
                        RoundedLoadingButton(
                          child: Text("Save", style: TextStyle(fontSize:24,fontWeight:FontWeight.bold,color: Colors.white)),
                          controller: _createController,
                          onPressed: (){
                            _handlesubmit();
                          },
                        ),
                      ]
                  ),
                )
            );
          }
          )
    );
  }
  void _handlesubmit() async{
    Widget NoButton = TextButton(
      child: Text("No"),
      onPressed:  () {
        _createController.stop();
        Navigator.pop(context);
      },
    );
    Widget YesButton = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        if(NameController.text.isEmpty || NameController.text == "" ||
            PhoneController.text.isEmpty || PhoneController.text == "")
        {
          ScaffoldMessenger.of(context).showSnackBar(snack().displaySnackBar("Some information is missing"));
          Navigator.of(context).pop();
          _createController.stop();
          return;
        };
        firestoreInstance.collection("Users").doc(widget.customUser?.uid).set(
            {
              "Name":NameController.text,
              "Phone" : PhoneController.text,
            },SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(snack().displaySnackBar("Information was saved successfully!"));
        Navigator.of(context).pop();
        _createController.stop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Saving"),
      content: Text("Are you sure you want to save this information"),
      actions: [
        NoButton,
        YesButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
