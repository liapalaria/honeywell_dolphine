import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:honeywell_scanner/scanner_callback.dart';

export 'package:honeywell_scanner/scanner_callback.dart';
export 'package:honeywell_scanner/code_format.dart';

class HoneywellScanner {
  static const _METHOD_CHANNEL = "honeywellscanner";
  static const _IS_SUPPORTED = "isSupported";
  static const _SET_PROPERTIES = "setProperties";
  static const _START_SCANNER = "startScanner";
  static const _RESUME_SCANNER = "resumeScanner";
  static const _PAUSE_SCANNER = "pauseScanner";
  static const _STOP_SCANNER = "stopScanner";
  static const _ON_DECODED = "onDecoded";
  static const _ON_ERROR = "onError";

  static const MethodChannel _channel = MethodChannel(_METHOD_CHANNEL);
  ScannerCallBack? _scannerCallBack;

  HoneywellScanner({ScannerCallBack? scannerCallBack}) {
    _channel.setMethodCallHandler(_onMethodCall);
    _scannerCallBack = scannerCallBack;
  }

  set scannerCallBack(ScannerCallBack scannerCallBack) =>
      _scannerCallBack = scannerCallBack;

  void setScannerCallBack(ScannerCallBack scannerCallBack) =>
      this.scannerCallBack = scannerCallBack;

  Future<void> _onMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case _ON_DECODED:
          onDecoded(call.arguments);
          break;
        case _ON_ERROR:
          onError(Exception(call.arguments));
          break;
        default:
          print(call.arguments);
      }
    } catch (e) {
      print(e);
    }
  }

  ///Called when decoder has successfully decoded the code
  ///<br>
  ///Note that this method always called on a worker thread
  ///
  ///@param code Encapsulates the result of decoding a barcode within an image
  void onDecoded(String? code) {
    _scannerCallBack?.onDecoded(code);
  }

  ///Called when error has occurred
  ///<br>
  ///Note that this method always called on a worker thread
  ///
  ///@param error Exception that has been thrown
  void onError(Exception error) {
    _scannerCallBack?.onError(error);
  }

  Future<bool> isSupported() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>(_IS_SUPPORTED) ?? false;
  }

  Future<void> setProperties(Map<String, dynamic> mapProperties) {
    return _channel.invokeMethod(_SET_PROPERTIES, mapProperties);
  }

  Future<bool> startScanner() async {
    return await _channel.invokeMethod<bool>(_START_SCANNER) ?? false;
  }

  Future<bool> resumeScanner() async {
    return await _channel.invokeMethod(_RESUME_SCANNER) ?? false;
  }

  Future<bool> pauseScanner() async {
    return await _channel.invokeMethod(_PAUSE_SCANNER) ?? false;
  }

  Future<bool> stopScanner() async {
    return await _channel.invokeMethod(_STOP_SCANNER) ?? false;
  }
}
