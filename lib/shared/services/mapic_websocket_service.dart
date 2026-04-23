import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

import '../../core/constants/api_constants.dart';

class MapicWebSocketService {
  WebSocketChannel? _channel;
  final Logger _logger = Logger();
  
  // Stream controllers for different data types
  final _userActivityController = StreamController<Map<String, dynamic>>.broadcast();
  final _contentQueueController = StreamController<Map<String, dynamic>>.broadcast();
  final _systemHealthController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationsController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Public streams
  Stream<Map<String, dynamic>> get userActivityStream => _userActivityController.stream;
  Stream<Map<String, dynamic>> get contentQueueStream => _contentQueueController.stream;
  Stream<Map<String, dynamic>> get systemHealthStream => _systemHealthController.stream;
  Stream<Map<String, dynamic>> get notificationsStream => _notificationsController.stream;
  
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 5);

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) {
      _logger.i('WebSocket already connected');
      return;
    }
    
    try {
      _logger.i('Connecting to WebSocket: ${ApiConstants.wsBaseUrl}');
      
      // TODO: Add authentication token to WebSocket connection
      final uri = Uri.parse(ApiConstants.wsBaseUrl);
      _channel = WebSocketChannel.connect(uri);
      
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      // Start heartbeat
      _startHeartbeat();
      
      // Subscribe to channels
      _subscribeToChannels();
      
      _logger.i('WebSocket connected successfully');
    } catch (e) {
      _logger.e('Failed to connect to WebSocket: $e');
      _isConnected = false;
      // Don't auto-reconnect on startup failures to avoid performance issues
      if (_reconnectAttempts > 0) {
        _scheduleReconnect();
      }
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final channel = data['channel'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;
      
      if (channel == null || payload == null) {
        _logger.w('Invalid message format: $message');
        return;
      }
      
      _logger.d('Received message on channel $channel: $payload');
      
      switch (channel) {
        case ApiConstants.wsChannelUserActivity:
          _userActivityController.add(payload);
          break;
        case ApiConstants.wsChannelContentQueue:
          _contentQueueController.add(payload);
          break;
        case ApiConstants.wsChannelSystemHealth:
          _systemHealthController.add(payload);
          break;
        case 'notifications':
          _notificationsController.add(payload);
          break;
        default:
          _logger.w('Unknown channel: $channel');
      }
    } catch (e) {
      _logger.e('Error handling message: $e');
    }
  }

  void _handleError(error) {
    _logger.e('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    _logger.w('WebSocket disconnected');
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _logger.e('Max reconnection attempts reached. Giving up.');
      return;
    }
    
    _reconnectAttempts++;
    _logger.i('Scheduling reconnection attempt $_reconnectAttempts in ${reconnectDelay.inSeconds}s');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _sendMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _subscribeToChannels() {
    final channels = [
      ApiConstants.wsChannelUserActivity,
      ApiConstants.wsChannelContentQueue,
      ApiConstants.wsChannelSystemHealth,
      'notifications',
    ];
    
    for (final channel in channels) {
      _sendMessage({
        'type': 'subscribe',
        'channel': channel,
      });
    }
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        _logger.e('Error sending message: $e');
      }
    }
  }

  // Public methods for sending specific messages
  
  void subscribeToUserActivity() {
    _sendMessage({
      'type': 'subscribe',
      'channel': ApiConstants.wsChannelUserActivity,
    });
  }

  void unsubscribeFromUserActivity() {
    _sendMessage({
      'type': 'unsubscribe',
      'channel': ApiConstants.wsChannelUserActivity,
    });
  }

  void subscribeToNotifications() {
    _sendMessage({
      'type': 'subscribe',
      'channel': 'notifications',
    });
  }

  void unsubscribeFromNotifications() {
    _sendMessage({
      'type': 'unsubscribe',
      'channel': 'notifications',
    });
  }

  Future<void> disconnect() async {
    _logger.i('Disconnecting WebSocket');
    
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    await _channel?.sink.close();
    _channel = null;
    
    _logger.i('WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _userActivityController.close();
    _contentQueueController.close();
    _systemHealthController.close();
    _notificationsController.close();
  }
}