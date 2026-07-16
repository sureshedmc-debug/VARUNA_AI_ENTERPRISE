import 'package:flutter/material.dart';

class AIDetectionPanel extends StatelessWidget {
  final Map<String,int> detections;
  final double confidence;
  final String lastDetection;
  final String lastTime;
  final VoidCallback onExportCsv;
  final VoidCallback onExportImages;
  final VoidCallback onGenerateReport;

  const AIDetectionPanel({
    super.key,
    required this.detections,
    required this.confidence,
    required this.lastDetection,
    required this.lastTime,
    required this.onExportCsv,
    required this.onExportImages,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('AI Detection',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(),
            ...detections.entries.map((e)=>ListTile(
              dense:true,
              title:Text(e.key),
              trailing:Text(e.value.toString()),
            )),
            Text('Confidence: ${confidence.toStringAsFixed(1)}%'),
            Text('Last Detection: $lastDetection'),
            Text('Time: $lastTime'),
            const SizedBox(height:12),
            Wrap(
              spacing:10,
              children:[
                ElevatedButton(onPressed:onExportCsv, child:const Text('Export CSV')),
                ElevatedButton(onPressed:onExportImages, child:const Text('Export Images')),
                FilledButton(onPressed:onGenerateReport, child:const Text('Generate Report')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

