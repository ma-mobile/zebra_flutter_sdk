import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zebraRfid/zebraRfid.dart';
import 'package:zebra_rfid_flutter/rfid/rfid_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => RfidBloc())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const DashBoard(),
      ),
    );
  }
}

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          "Dashboard",
          style: GoogleFonts.sunflower(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[DashboardItem()],
      ),
    );
  }
}

class DashboardItem extends StatefulWidget {
  const DashboardItem({super.key});

  @override
  State<DashboardItem> createState() => _DashboardItemState();
}

class _DashboardItemState extends State<DashboardItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade800, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RfidScanningPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Icon(FluentIcons.slide_grid_24_regular, size: 80),
              ),
              Text(
                "RFID",
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RfidScanningPage extends StatefulWidget {
  const RfidScanningPage({super.key});

  @override
  State<RfidScanningPage> createState() => _RfidScanningPageState();
}

class _RfidScanningPageState extends State<RfidScanningPage> {
  @override
  void initState() {
    context.read<RfidBloc>().add(DispatchConnectionStatusEvent());
    super.initState();
  }

  @override
  void dispose() {
    context.read<RfidBloc>().add(StopScanEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF3366FF), const Color(0xFF00CCFF)],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: BlocBuilder<RfidBloc, RfidState>(
          builder: (context, state) {
            if (state is RfidScanResult) {
              return Text(
                "RFID ${getTagCount(state.tags)}",
                style: GoogleFonts.sunflower(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Text(
                "RFID",
                style: GoogleFonts.sunflower(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
        actions: [
          BlocBuilder<RfidBloc, RfidState>(
            buildWhen: (prev, current) => current is RfidConnectionStatus,
            builder: (context, state) {
              if (state is RfidConnectionStatus) {
                var isTransition = false;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin:
                            state.isConnected
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                        end:
                            state.isConnected
                                ? Color(0xFF09B144)
                                : Colors.red.shade400,
                      ),
                      duration: Duration(milliseconds: 1500),
                      builder: (context, color, child) {
                        return Container(
                          height: 44,
                          width: 44,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey.shade300],
                              begin: const FractionalOffset(0.0, 0.0),
                              end: const FractionalOffset(1.0, 0.0),
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp,
                            ),
                            shape: CircleBorder(
                              side: BorderSide(width: 4, color: color!),
                            ),
                          ),
                          child: Expanded(
                            child:
                                state.isConnected
                                    ? Icon(
                                      size: 30,
                                      color: Colors.green.shade400,
                                      FluentIcons.plug_connected_24_regular,
                                    )
                                    : Icon(
                                      size: 30,
                                      color: Colors.red.shade400,
                                      FluentIcons.plug_disconnected_24_regular,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<RfidBloc, RfidState>(
        buildWhen: (prev, current) => current is RfidConnectionStatus,
        builder: (context, state) {
          if (state is RfidConnectionStatus) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed:() {
                    context.read<RfidBloc>().add(ConnectScannerEvent());
                  },
                  child: Icon(color: Colors.green, FluentIcons.connected_24_filled),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed:() {
                    context.read<RfidBloc>().add(DisconnectScannerEvent());
                  },
                  child: Icon(color: Colors.red, FluentIcons.plug_disconnected_24_filled),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor:
                      state.isConnected ? Colors.green : Colors.red,
                  onPressed:
                      state.isConnected
                          ? () {
                            context.read<RfidBloc>().add(StartScanEvent());
                          }
                          : () {},
                  child: Icon(color: Colors.white, FluentIcons.scan_24_regular),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor:
                      state.isConnected ? Colors.green : Colors.red,
                  onPressed:
                      state.isConnected
                          ? () {
                            context.read<RfidBloc>().add(StopScanEvent());
                          }
                          : () {},
                  child: Icon(
                    color: Colors.white,
                    FluentIcons.record_stop_24_regular,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        },
      ),
      body: BlocBuilder<RfidBloc, RfidState>(
        builder: (context, state) {
          if (state is RfidScanResult) {
            return ListView.builder(
              itemCount: state.tags.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${state.tags[index].epc} -> ",
                        style: GoogleFonts.saira(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Tag Length :- ${state.tags[index].epc.length}",
                            style: GoogleFonts.sunflower(
                              color: Colors.black45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "RSSI :- ${state.tags[index].rssi}",
                            style: GoogleFonts.sunflower(
                              color: Colors.black45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: getProximity(state.tags[index].rssi),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  String getTagCount(List<RfidTag> tags) {
    if (tags.isNotEmpty) {
      return " (${tags.length})";
    } else {
      return "";
    }
  }

  MaterialColor getProximity(int rssi) {
    // Strong signal: Tag is very close
    if (rssi >= -60) {
      return Colors.green;
    }
    // Medium signal: Tag is at a moderate distance
    else if (rssi >= -65) {
      return Colors.orange;
    }
    // Weak signal: Tag is far or obstructed, at the edge of or beyond read range
    else {
      return Colors.red;
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  ZebraRfid? zebra123;
  Interfaces interface = Interfaces.unknown;
  Status connectionStatus = Status.disconnected;
  List<Barcode> barcodes = [];
  String deviceInfo = "";
  bool isConnected = false;

  List<RfidTag> tags = [
    RfidTag(
      epc: "Tag 1",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
    RfidTag(
      epc: "Tag 2",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
    RfidTag(
      epc: "Tag 3",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
    RfidTag(
      epc: "Tag 4",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
    RfidTag(
      epc: "Tag 5",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
    RfidTag(
      epc: "Tag 6",
      antenna: 1,
      rssi: 1,
      distance: 1,
      memoryBankData: "",
      lockData: "",
      size: 1,
      seen: "",
      interface: Interfaces.rfidapi3,
    ),
  ];
  RfidTag? tag;

  bool scanning = false;
  bool tracking = false;

  @override
  void initState() {
    zebra123 = ZebraRfid(callback: callback);
    super.initState();
    _requestBluetoothPermission();
  }

  Future<void> _requestBluetoothPermission() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text(
              widget.title + getTagCount(tags),
              style: GoogleFonts.sunflower(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon:
                  isConnected
                      ? Icon(FluentIcons.plug_connected_24_regular)
                      : Icon(FluentIcons.plug_disconnected_24_regular),
              onPressed: () {},
              color: isConnected ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: isConnected ? stopScanning : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    isConnected ? Colors.indigo : Colors.grey.shade700,
              ),
              child: Text(
                "Stop",
                style: GoogleFonts.saira(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: isConnected ? startScanning : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    isConnected ? Colors.indigo : Colors.grey.shade700,
              ),
              child: Text(
                "Scan",
                style: GoogleFonts.saira(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0).copyWith(left: 0),
              child: Text(
                deviceInfo,
                maxLines: 1,
                style: GoogleFonts.saira(fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${tags[index].epc} -> ",
                        style: GoogleFonts.saira(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Tag Length :- ${tags[index].epc.length}",
                            style: GoogleFonts.sunflower(
                              color: Colors.black45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "RSSI :- ${tags[index].rssi}",
                            style: GoogleFonts.sunflower(
                              color: Colors.black45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: getProximity(tags[index].rssi),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String getTagCount(List<RfidTag> tags) {
    if (tags.isNotEmpty) {
      return " (${tags.length})";
    } else {
      return "";
    }
  }

  MaterialColor getProximity(int rssi) {
    // Strong signal: Tag is very close
    if (rssi >= -60) {
      return Colors.green;
    }
    // Medium signal: Tag is at a moderate distance
    else if (rssi >= -65) {
      return Colors.orange;
    }
    // Weak signal: Tag is far or obstructed, at the edge of or beyond read range
    else {
      return Colors.red;
    }
  }

  void callback(Interfaces interface, Events event, dynamic data) {
    this.interface = interface;
    setState(() {
      if (deviceInfo.isEmpty) {
        deviceInfo += "$event";
      } else {
        deviceInfo += " | $event";
      }
    });
    switch (event) {
      case Events.readBarcode:
        barcodes.clear();
        if (data is List<Barcode>) {
          for (Barcode barcode in data) {
            barcodes.add(barcode);
            if (kDebugMode) {
              print(
                "Barcode: ${barcode.barcode} Format: ${barcode.format} Seen: ${barcode.seen} Interface: ${barcode.interface} ",
              );
            }
          }
        }
        if (interface == Interfaces.datawedge && scanning) scanning = false;
        setState(() {});
        break;

      case Events.readRfid:
        tags.clear();
        if (data is List<RfidTag>) {
          for (RfidTag tag in data) {
            setState(() {
              tags.add(tag);
            });
            if (kDebugMode) {
              print(
                "Tag: ${tag.epc} Rssi: ${tag.rssi}  Seen: ${tag.seen} Interface: ${tag.interface}",
              );
            }
          }
        }
        if (interface == Interfaces.datawedge && scanning) scanning = false;
        setState(() {});
        break;

      case Events.error:
        if (data is Error) {
          if (kDebugMode) print("Interface: $interface Error: ${data.message}");
        }
        break;

      case Events.connectionStatus:
        if (data is ConnectionStatus) {
          if (data.status == Status.connected) {
            setState(() {
              isConnected = true;
            });
          } else {
            setState(() {
              isConnected = false;
            });
          }
          if (kDebugMode) {
            print("Interface: $interface ConnectionStatus: ${data.status}");
          }
        }
        if (data.status != connectionStatus) {
          setState(() {
            connectionStatus = data.status;
          });
        }
        break;

      case Events.reading:
        tags.clear();
        if (data is List<RfidTag>) {
          for (RfidTag tag in data) {
            print("[READING-INFO] current tag is - ${tag.epc}");
            setState(() {
              tags.add(tag);
            });
          }
        }
        if (interface == Interfaces.datawedge && scanning) scanning = false;
        setState(() {});
        break;

      default:
        if (kDebugMode) {
          if (kDebugMode) print("Interface: $interface Unknown Event: $event");
        }
    }
  }

  void startScanning() {
    zebra123?.setMode(Modes.rfid);
    zebra123?.startScanning();
    tags.clear();
    barcodes.clear();
    setState(() {
      scanning = true;
      tracking = false;
    });
  }

  void stopScanning() {
    zebra123?.stopScanning();
    setState(() {
      scanning = false;
      tracking = false;
    });
  }
}
