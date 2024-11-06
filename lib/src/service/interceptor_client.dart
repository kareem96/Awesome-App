import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../main.dart';

class InterceptorClient extends http.BaseClient {
  final http.Client _innerClient;
  final void Function() onRetry;

  InterceptorClient(this._innerClient, {required this.onRetry});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Intercept request before sending
      log('Request: ${request.method} ${request.url}');
      log('Headers: ${request.headers}');
      if (request is http.Request) {
        log('Request Body: ${request.body}');
      }

      // Send the request
      final response = await _innerClient.send(request);

      // Read the response body
      final responseBody = await response.stream.bytesToString();

      // Log the response body
      log('Response Body: $responseBody');


      final newResponse = http.Response(responseBody, response.statusCode, headers: response.headers);

      // Return the new response
      return http.StreamedResponse(
        Stream.value(newResponse.bodyBytes),
        response.statusCode,
        headers: response.headers,
        request: response.request,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
      );
    } catch (e) {
      if (e is SocketException) {
        // for Handle network error (no internet connection, etc.)
        log('No internet connection. Please check your network.');

        // for Show the network error dialog
        _showNetworkErrorDialog();

        // Return a default response to signify a failure
        return _handleNetworkError();
      } else {
        // for Handle other types of errors
        log('Unexpected error occurred: $e');
        return _handleGeneralError();
      }
    }
  }

  // for show a dialog for network error
  void _showNetworkErrorDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Network Error'),
        content: const Text('No internet connection. Please check your network.'),
        actions: [
          TextButton(
            onPressed: () async {
              bool isConnected = await _checkConnection();
              if (isConnected) {
                onRetry();
                Navigator.of(context).pop();
              } else {
                log('No internet connection available.');
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Check if the device is connected to the internet
  Future<bool> _checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Custom method to handle network error (no internet connection)
  http.StreamedResponse _handleNetworkError() {
    // Return a response with an appropriate status code (e.g., 503 Service Unavailable)
    final response = http.Response('No internet connection', 503);

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      isRedirect: false,
      persistentConnection: false,
    );
  }

  // Custom method to handle other types of errors
  http.StreamedResponse _handleGeneralError() {
    // Return a generic error message with a 500 status code
    final response = http.Response('An unexpected error occurred', 500);

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      isRedirect: false,
      persistentConnection: false,
    );
  }
}