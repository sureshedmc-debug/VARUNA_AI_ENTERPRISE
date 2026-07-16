import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/video/video_stream_service.dart';

class LiveVideoWidget extends StatefulWidget {
  const LiveVideoWidget({
    super.key,
  });

  @override
  State<LiveVideoWidget> createState() =>
      _LiveVideoWidgetState();
}

class _LiveVideoWidgetState extends State<LiveVideoWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VideoStreamService.instance,
      builder: (context, _) {
        return Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              //------------------------------------------------------
              // HEADER
              //------------------------------------------------------

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.blue.shade700,
                child: Row(
                  children: [
                    const Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Live Drone Camera",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      color: Colors.white,
                      icon: Icon(
                        _expanded
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                    ),
                  ],
                ),
              ),

              //------------------------------------------------------
              // VIDEO
              //------------------------------------------------------

              if (_expanded)
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: StreamBuilder<Uint8List>(
                    stream: VideoStreamService.instance.frames,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text(
                                  "Waiting for Raspberry Pi Video...",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [

                          //------------------------------------------------
                          // VIDEO FRAME
                          //------------------------------------------------

                          Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),

                          //------------------------------------------------
                          // LIVE BADGE
                          //------------------------------------------------

                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //------------------------------------------------
                          // AI PLACEHOLDER
                          //------------------------------------------------

                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "AI Detection Ready",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}