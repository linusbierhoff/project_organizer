import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
        body: Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        ));
  }
}

class LoadingContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor:
              new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
    ));
  }
}
