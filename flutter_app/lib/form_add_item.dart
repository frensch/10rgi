import 'package:flutter/material.dart';

class FormAddItem extends StatefulWidget {
  final Function callbackReturn;

  FormAddItem(this.callbackReturn);

  @override
  FormAddItemState createState() {
    return FormAddItemState(callbackReturn);
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class FormAddItemState extends State<FormAddItem> {
  final Function callbackReturn;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  FormAddItemState(this.callbackReturn);

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          TextFormField(
            decoration: InputDecoration(hintText: 'Digite o número do Talão'),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value.isEmpty) {
                return 'Adicione o número do Talão';
              }
              int id = 0;
              try {
                id = int.parse(value);
              } catch (e) {
                return 'Deve utilizar apenas números';
              }
              callbackReturn(id);
              return null;
            },
          ),
          RaisedButton(
            onPressed: () {
              // Validate returns true if the form is valid, otherwise false.
              if (_formKey.currentState.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.

                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
            child: Text('Submit'),
          )
        ]));
  }
}
