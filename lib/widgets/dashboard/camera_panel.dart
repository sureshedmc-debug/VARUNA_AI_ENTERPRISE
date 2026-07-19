import 'package:flutter/material.dart';
class CameraPanel extends StatelessWidget {
  final Widget videoWidget;
  final bool recording;
  final String resolution;
  final int fps;
  final VoidCallback onSnapshot;
  final VoidCallback onToggleOverlay;

  const CameraPanel({
    super.key,
    required this.videoWidget,
    required this.recording,
    required this.resolution,
    required this.fps,
    required this.onSnapshot,
    required this.onToggleOverlay,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                const Text('Live Camera',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
                Row(children:[
                  Icon(recording?Icons.fiber_manual_record:Icons.circle_outlined,
                      color: recording?Colors.red:Colors.grey),
                  const SizedBox(width:8),
                  Text('$resolution | ${fps}fps')
                ])
              ],
            ),
            const SizedBox(height:12),
            SizedBox(height:360, child: videoWidget),
            const SizedBox(height:12),
            Row(children:[
              ElevatedButton.icon(onPressed:onSnapshot,icon:const Icon(Icons.camera),label:const Text('Snapshot')),
              const SizedBox(width:12),
              OutlinedButton.icon(onPressed:onToggleOverlay,icon:const Icon(Icons.visibility),label:const Text('AI Overlay'))
            ])
          ],
        ),
      ),
    );
  }
}

 