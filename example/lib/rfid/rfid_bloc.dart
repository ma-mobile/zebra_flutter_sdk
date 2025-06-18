import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zebraRfid/zebraRfid.dart';

part 'rfid_event.dart';
part 'rfid_state.dart';

class RfidBloc extends Bloc<RfidEvent, RfidState> {
  ZebraRfid? zebraRfid;
  Interfaces interface = Interfaces.unknown;
  Status connectionStatus = Status.disconnected;
  String deviceInfo = "";
  bool isConnected = false;
  bool scanning = false;
  bool tracking = false;
  List<RfidTag> tags = [];
  RfidBloc() : super(RfidInitial()) {
    print("[RfidBloc] - Init section");
    _requestBluetoothPermission();
    zebraRfid = ZebraRfid(callback: callback);
    zebraRfid?.connectionStatus;
    on<InitRfidEvent>((event, emit) {});
    on<StartScanEvent>((event, emit) {
      zebraRfid?.setPowerLevel(10);
      startScanning();
    });
    on<StopScanEvent>((event, emit) {
      stopScanning();
    });
    on<ConnectScannerEvent>((event, emit) {
      zebraRfid?.connect();
    });
    on<DisconnectScannerEvent>((event, emit) {
      zebraRfid?.stopScanning();
      zebraRfid?.disconnect();
    });
    on<StartTrackEvent>((event, emit) {});
    on<RequestTagCountEvent>((event, emit) {});
    on<DispatchScanResultEvent>((event, emit) {
      emit(RfidScanResult(tags: event.tags));
    });
    on<DispatchConnectionStatusEvent>((event, emit) {
      emit(RfidConnectionStatus(isConnected: isConnected));
    });
  }

  Future<void> _requestBluetoothPermission() async {
    if (kDebugMode) print("[RfidBloc] - request permission section");
    final status = await Permission.bluetooth.request();
    if (status.isGranted) {
      print("Bluetooth permission granted");
    }

    final status1 = await Permission.bluetoothAdvertise.request();
    if (status1.isGranted) {
      print("Bluetooth permission granted bluetoothAdvertise ");
    }

    final status2 = await Permission.bluetoothConnect.request();
    if (status2.isGranted) {
      print("Bluetooth permission granted bluetoothConnect ");
    }

    final status3 = await Permission.bluetoothScan.request();
    if (status3.isGranted) {
      print("Bluetooth permission granted bluetoothScan ");
    }
  }

  void callback(Interfaces interface, Events event, dynamic data) {
    this.interface = interface;
    if (kDebugMode) print("[RfidBloc] - callback section");
    if (deviceInfo.isEmpty) {
      deviceInfo += "$event";
    } else {
      deviceInfo += " | $event";
    }

    switch (event) {
      case Events.readBarcode:
        // Barcode logic
        break;

      case Events.readRfid:
        tags.clear();
        if (data is List<RfidTag>) {
          for (RfidTag tag in data) {
            tags.add(tag);

            if (kDebugMode) {
              print(
                "Tag: ${tag.epc} Rssi: ${tag.rssi}  Seen: ${tag.seen} Interface: ${tag.interface}",
              );
            }
          }
        }
        if (interface == Interfaces.datawedge && scanning) scanning = false;
        break;

      case Events.error:
        if (data is Error) {
          if (kDebugMode) print("Interface: $interface Error: ${data.message}");
        }
        break;

      case Events.connectionStatus:
        if (data is ConnectionStatus) {
          if (data.status == Status.connected) {
            isConnected = true;
          } else {
            isConnected = false;
          }
          add(DispatchConnectionStatusEvent());
          if (kDebugMode) {
            print("Interface: $interface ConnectionStatus: ${data.status}");
          }
        }
        if (data.status != connectionStatus) {
          connectionStatus = data.status;
        }
        break;

      case Events.reading:
        tags.clear();
        if (data is List<RfidTag>) {
          for (RfidTag tag in data) {
            print("[READING-INFO] current tag is - ${tag.epc}");
            tags.add(tag);
          }
        }
        if (interface == Interfaces.datawedge && scanning) scanning = false;
        add(DispatchScanResultEvent(tags: tags));
        break;

      default:
        if (kDebugMode) {
          if (kDebugMode) print("Interface: $interface Unknown Event: $event");
        }
    }
  }

  void startScanning() {
    zebraRfid?.setMode(Modes.rfid);
    zebraRfid?.startScanning();
    tags.clear();
    scanning = true;
    tracking = false;
  }

  void stopScanning() {
    zebraRfid?.stopScanning();
    scanning = false;
    tracking = false;
  }
}
