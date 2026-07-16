import 'package:flutter/material.dart';

class MissionTimelinePanel extends StatelessWidget {
  final int currentStep;

  const MissionTimelinePanel({
    super.key,
    required this.currentStep,
  });

  static const _steps=[
    'Pre-Flight',
    'Takeoff',
    'Mission Running',
    'AI Detection',
    'Return To Launch',
    'Landing',
    'Mission Complete',
  ];

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('Mission Timeline',
              style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(),
            ...List.generate(_steps.length,(i){
              final active=i<=currentStep;
              return ListTile(
                dense:true,
                leading: Icon(
                  active?Icons.check_circle:Icons.radio_button_unchecked,
                  color: active?Colors.green:Colors.grey,
                ),
                title: Text(_steps[i]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

