import 'package:flutter/material.dart';

class PreFlightChecklist extends StatelessWidget{
  final Map<String,bool> checks;

  const PreFlightChecklist({
    super.key,
    required this.checks,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('Pre-Flight Checklist',
              style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(),
            ...checks.entries.map((e)=>ListTile(
              dense:true,
              leading: Icon(
                e.value?Icons.check_circle:Icons.cancel,
                color:e.value?Colors.green:Colors.red,
              ),
              title: Text(e.key),
            ))
          ],
        ),
      ),
    );
  }
}

