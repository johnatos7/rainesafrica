// Network Information Interface
// Provides network connectivity information

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity information
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using Connectivity package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check to ensure we can actually reach the internet
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
