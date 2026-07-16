import 'package:flutter/material.dart';

class MissionPlanningDialog extends StatefulWidget{
  const MissionPlanningDialog({super.key});

  @override
  State<MissionPlanningDialog> createState()=>_MissionPlanningDialogState();
}

class _MissionPlanningDialogState extends State<MissionPlanningDialog>{
  String mission='Manual Mission';
  double altitude=20;
  String direction='North';
  String mode='AUTO';

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: const Text('Mission Planning'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            DropdownButtonFormField<String>(
              value: mission,
              items:['Manual Mission','AI Survey Mission','Garbage Detection','Area Mapping']
                .map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
              onChanged:(v)=>setState(()=>mission=v!),
            ),
            const SizedBox(height:12),
            ListTile(
              title: const Text('Altitude'),
              subtitle: Slider(
                value:altitude,min:10,max:100,divisions:9,
                label:'${altitude.round()} m',
                onChanged:(v)=>setState(()=>altitude=v),
              ),
            ),
            DropdownButtonFormField<String>(
              value:direction,
              items:['North','South','East','West','Clockwise','Counter Clockwise']
                .map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
              onChanged:(v)=>setState(()=>direction=v!),
            ),
            const SizedBox(height:12),
            DropdownButtonFormField<String>(
              value:mode,
              items:['AUTO','GUIDED','LOITER','RTL']
                .map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
              onChanged:(v)=>setState(()=>mode=v!),
            ),
          ],
        ),
      ),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
        ElevatedButton(onPressed:()=>Navigator.pop(context),child:const Text('Create Mission')),
      ],
    );
  }
}

