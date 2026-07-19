import '../models/drone_model.dart';
import 'network/websocket_service.dart';

/// Thin adapter that exposes the [WebSocketService] stream to [DroneProvider].
///
/// All real connectivity and reconnection logic lives in [WebSocketService].
class DroneService {
  DroneService();

  /// Live stream of [DroneModel] snapshots received from the backend.
  Stream<DroneModel> get droneStream => WebSocketService.instance.stream;

  /// Start the WebSocket connection to the Raspberry Pi backend.
  void start() {
    WebSocketService.instance.start();
  }

  /// Stop the WebSocket connection permanently.
  void stop() {
    WebSocketService.instance.stop();
  }
}
