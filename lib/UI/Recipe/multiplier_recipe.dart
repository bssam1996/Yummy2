import 'package:flutter/material.dart';
import '../../shared/constants.dart';

Dialog showdialog(BuildContext context) {
  double _currentDoubleValue = 1.0;
  TextEditingController _controller = new TextEditingController();
  return Dialog(
    backgroundColor: lightBlue,
    shadowColor: darkBlue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    child: Container(
      constraints: const BoxConstraints(maxHeight: 450),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Text(
                  "Multiplyers",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    display_buttton_multiplyer(" 1 \n---\n 8 ", 1/8, context),
                    display_buttton_multiplyer(" 1 \n---\n 5 ", 0.2, context),
                    display_buttton_multiplyer(" 1 \n---\n 4 ", 0.25, context),
                    display_buttton_multiplyer(" 1 \n---\n 3 ", 1/3, context),
                    display_buttton_multiplyer(" 2 \n---\n 5 ", 2/5, context),
                    display_buttton_multiplyer(" 1 \n---\n 2 ", 1/2, context),
                    display_buttton_multiplyer(" 3 \n---\n 5 ", 3/5, context),
                    display_buttton_multiplyer(" 2 \n---\n 3 ", 2/3, context),
                    display_buttton_multiplyer(" 4 \n---\n 5 ", 4/5, context),
                    display_buttton_multiplyer(" 1.5 ", 1.5, context),
                    display_buttton_multiplyer(" 2 ", 2, context),
                    display_buttton_multiplyer(" 2.5 ", 2.5, context),
                    display_buttton_multiplyer(" 3 ", 3, context),
                  ],
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: "Type custom multiplier...",

                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _controller,
                textAlign: TextAlign.center,
                onChanged: (value){
                  try{
                    double val = double.parse(value);
                    _currentDoubleValue = val;
                  }catch(e){

                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, _currentDoubleValue);
                },
                child: Text("Confirm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget display_buttton_multiplyer(String text, double value, BuildContext context){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: OutlinedButton(
      onPressed: () {
        Navigator.pop(context, value);
      },
      child: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPurpleColor,
        side: BorderSide(
          color: darkPurpleColor,
        ),
      ),
    ),
  );
}
