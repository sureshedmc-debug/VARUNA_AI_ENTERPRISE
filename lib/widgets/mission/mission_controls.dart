import 'package:flutter/material.dart';
import 'mission_planning_dialog.dart';

class MissionControls extends StatelessWidget {
  const MissionControls({super.key});

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            const Text(
              'Mission Planning',
              style: TextStyle(fontSize:20,fontWeight:FontWeight.bold),
            ),
            const SizedBox(height:12),
            ElevatedButton.icon(
              icon: const Icon(Icons.route),
              label: const Text('Open Mission Planner'),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (_)=>const MissionPlanningDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

