import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

import 'database.dart';

final database = AppDatabase();
List<PreviousRecordData> record = []; //null이 들어올 수도 있으니 유의하자

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  record = await database.select(database.previousRecord).get();
  runApp(const MyApp());
}

int leftCount = 0, rightCount = 0;
dynamic totalCountMethod = 1.0, correctMethod = 0.0;
DateTime s = DateTime(0), e = DateTime(0);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  int _deviceStatus = Device.disconnected;

  //Uint8List _data = Uint8List(0);
  List<int> _dataFir = [0, 0, 0, 0];
  List<int> _dataSex = [0, 0, 0, 0]; //이전 값
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((event) {
      setState(() {
        _deviceStatus = event;
      });
    });
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      setState(() {
        //기존코드//_data = Uint8List.fromList([..._data, ...event]);
        _dataSex = _dataFir;
        //아래는 event를 문자열로 디코딩하고, 문자열 파싱하고, 정수형 리스트로 변환하는 코드
        _dataFir = ((String.fromCharCodes(event)).split(' '))
            .map((e) => int.parse(e))
            .toList();
        //print("\n\n${_data_fir[0]}, ${_data_fir[1]}, ${_data_fir[2]}, ${_data_fir[3]}\n\n");//for 디버깅
        //아래는 조건 분기에 따라 입의 구간 파악 및 올바른 양치법인지 판별
        //shock이 증가하는 경우에만 판별하기
        if (_dataFir[2] < -40) {
          rightCount++;
        } else {
          leftCount++;
        }
        if (_dataSex[3] < _dataFir[3]) {
          if ((_dataSex[2] - _dataFir[2]).abs() <= 25) {
            //이전값과 현재값의 차이가 10 이하면 옳은 방법
            if (_dataFir[3] < 30) correctMethod += 1.8;
            if (_dataFir[3] >= 30) correctMethod += 2.7;
          }
          totalCountMethod++;
        }
        e = DateTime.now();
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    setState(() {
      _devices = res;
    });
  }

  Future<void> _scan() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      await _bluetoothClassicPlugin.startScan();
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (event) {
          setState(() {
            _discoveredDevices = [..._discoveredDevices, event];
          });
        },
      );
      setState(() {
        _scanning = true;
      });
    }
  }

  bool _visibility = false; //안보이다가 조건을 충족하면 보이게 함
  void showVisibility() {
    setState(() {
      _visibility = true;
    });
  }

  void _hide_visibility() {
    setState(() {
      _visibility = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (BuildContext ctx) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('양치 데이터 분석기-22:20'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
//Text("Device status is $_deviceStatus"),
                    TextButton(
                      onPressed: () async {
                        await _bluetoothClassicPlugin.initPermissions();
                      },
                      child: const Text("권한 확인"),
                    ),
                    TextButton(
                      onPressed: _getDevices,
                      child: const Text("페이링 됀 기기에 연결"),
                    ),
                    TextButton(
                      onPressed: _deviceStatus == Device.connected
                          ? () async {
                              await _bluetoothClassicPlugin.disconnect();
                            }
                          : null,
                      child: const Text("연결 해제"),
                    ),

// TextButton(
//   onPressed: _deviceStatus == Device.connected
//       ? () async {
//           await _bluetoothClassicPlugin.write("ping");
//         }
//       : null,
//   child: const Text("send ping"),
// ),
                    const Center(
//child: Text('Running on: $_platformVersion\n'),
                        ),
                    ...[
                      for (var device in _devices)
                        TextButton(
                            onPressed: () async {
                              await _bluetoothClassicPlugin.connect(
                                  device.address,
                                  "00001101-0000-1000-8000-00805f9b34fb");
                              showVisibility();
                              s = DateTime.now();
                              setState(() {
                                _discoveredDevices = [];
                                _devices = [];
                              });
                            },
                            child: Text(device.name ?? device.address))
                    ],

//아래 코드는 새로운 기기를 페어링하는 코드
// TextButton(
//   onPressed: _scan,
//   child: Text(_scanning ? "Stop Scan" : "Start Scan"),
// ),
// ...[
//   for (var device in _discoveredDevices)
//     Text(device.name ?? device.address)
// ],

//아래 코드 수정
//Text("Received data: ${String.fromCharCodes(_data)}"),
                    Text(!_visibility
                        ? "연결하면 데이터 수집 시작"
                        : "Received data: ${_dataFir.join(", ")}"), //for 디버깅

                    Visibility(
                      visible: _visibility,
                      child: TextButton(
                        //누르면 다른 화면으로 넘어가는 버튼
                        child: const Text("수집 종료 및 결과 확인"),
                        onPressed: () {
                          Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                  builder: (context) => const ResultPage()));
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("양치 데이터 분석기"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/teeth.png'), fit: BoxFit.cover),
                ),
                height: 300,
                width: 300,
                child: Row(
                  children: [
                    Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                            child: Center(
                                child: Text(
                          "${(leftCount / (leftCount + rightCount) * 100).ceil()}",
                          style: TextStyle(fontSize: 40, color: Colors.red),
                        ))),
                        flex: 5),
                    Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                            child: VerticalDivider(
                          thickness: 1,
                          width: 1,
                          color: Colors.blue,
                        )),
                        flex: 5),
                    Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                            child: Center(
                                child: Text(
                          "${100 - (leftCount / (leftCount + rightCount) * 100).ceil()}",
                          style: TextStyle(fontSize: 40, color: Colors.red),
                        ))),
                        flex: 5),
                  ],
                ),
              ),
              DataTable(columns: const [
                DataColumn(label: Text('항목')),
                DataColumn(label: Text('권장 수치')),
                DataColumn(label: Text('수집 데이타')),
              ], rows: [
                DataRow(cells: [
                  //양치 시간
                  const DataCell(Text("양치 시간")),
                  const DataCell(Text("3:00")),
                  DataCell(Text(
                      "${e.difference(s).inMinutes}:${(e.difference(s).inSeconds) % 60}")),
                ]),
                DataRow(cells: [
                  //양치 횟수(좌우 비율)
                  const DataCell(Text("양치 비율")),
                  const DataCell(Text("50:50")),
                  DataCell(Text(
                      "${(leftCount / (leftCount + rightCount) * 100).ceil()} : ${100 - (leftCount / (leftCount + rightCount) * 100).ceil()}")),
                ]),
                DataRow(cells: [
                  //양치 방법
                  const DataCell(Text("양치 방법")),
                  const DataCell(Text("100%")),
                  DataCell(Text((100 >
                          ((correctMethod / totalCountMethod) * 100).ceil())
                      ? "${((correctMethod / totalCountMethod) * 100).ceil()}%"
                      : "100")),
                ]),
                // DataRow(cells: [//시간당 양치 횟수
                //   DataCell(Text("양치 횟수/분")),
                //   DataCell(Text("data1")),
                //   DataCell(Text("data1")),
                // ]),
              ]),
              const Text(
                  "아래 주소를 통해 올바른 양치법 학습:\nhttp://www.kacpd.org/general/sub01.html")
            ],
          ),
        ),
      ),
    );
  }
}

class PreviousRecord extends StatelessWidget {
  const PreviousRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("이전 결과"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                //for debuggind
                ListView.builder(
                  itemCount: record.length,
                    itemBuilder: (BuildContext context, int index){return Text("$record");}
                )
                /*
                //차트 형식으로 이전 결과 보여주기
                for()
                 */
              ],
            ),
          ),
        ));
  }
}
