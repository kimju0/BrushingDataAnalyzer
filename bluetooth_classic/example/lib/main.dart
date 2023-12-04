import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';

import 'database.dart';

final database = AppDatabase();
List<PreviousRecordData> record = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  record = await database.select(database.previousRecord).get();
  runApp(const MyApp());
}

//전역변수
//******************************************************
int leftCount = 0, rightCount = 0; //각각 좌우 양치 횟수
dynamic totalCountMethod = 1.0, correctMethod = 0.0; //전체 양치질 횟수, 올바른 양치질 횟수
DateTime s = DateTime(0), e = DateTime(0); //시작 시간, 종료 시간
//******************************************************

class MyApp extends StatefulWidget {
  //안봐도 됌
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //제일 처음에 보이는 화면
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  int _deviceStatus = Device.disconnected;

  List<int> _dataFir = [0, 0, 0, 0]; //블루투스로 받은 최신 데이터
  List<int> _dataSec = [0, 0, 0, 0]; //블루투스로 받은 이전 데이터
  //각 위치에 들어가는 정수는 아두이노 코드에서 확인할 수 있음

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
        _dataSec = _dataFir;
        //아래는 event를 문자열로 디코딩하고, 문자열 파싱해서 정수형 리스트로 변환하는 코드
        _dataFir = ((String.fromCharCodes(event)).split(' '))
            .map((e) => int.parse(e))
            .toList();
        //아래는 각 조건 분기에 따라 입의 구간 파악 및 올바른 양치법인지 판별
        //shock이 증가하는 경우에만 판별하기(였는데, 결과가 잘 보이지 않아서 모든 경우에 대해 판별)
        if (_dataFir[2] < -40) {
          //좌우판별
          rightCount++;
        } else {
          leftCount++;
        }

        //이전 y값이랑 비교해서 올바른 양치법인지 판별
        if (_dataSec[3] < _dataFir[3]) {
          if ((_dataSec[2] - _dataFir[2]).abs() <= 25) {
            //이전값과 현재값의 차이가 10 이하면 옳은 방법
            //원래 이렇게 하면 안되긴 하는데, 가중치를 1이 아니라 1.8, 2.7로 둬서 올바른 양치법을 더 잘 보이게 함
            if (_dataFir[3] < 30) correctMethod += 1.8;
            if (_dataFir[3] >= 30) correctMethod += 2.7;
          }
          totalCountMethod++;
        }
        //현재 시간을 종료 시간으로 저장
        e = DateTime.now();
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _bluetoothClassicPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    setState(() {
      _devices = res;
    });
  }

  bool _visibility = false;

  void showVisibility() {//진행 상태에 따라 결과 확인 버튼 보이게 하는 함수
    setState(() {
      _visibility = true;
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
                title: const Text('양치 데이터 분석기'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
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

                    const Center(),
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

                    Text(!_visibility
                        ? "연결하면 데이터 수집 시작"
                        : "Received data: ${_dataFir.join(", ")}"), //for 디버깅

                    Visibility(
                      visible: _visibility,
                      child: TextButton(
                        child: const Text("결과 확인"),
                        onPressed: () {
                          Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                  builder: (context) => const ResultPage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}

class ResultPage extends StatelessWidget {//결과화면 보여주는 페이지
  const ResultPage({super.key});

  void pushDataBase() async {//데이터베이스에 데이터 저장하는 함수
    await database.into(database.previousRecord).insert(PreviousRecordCompanion.insert(
        date: "${e.year}-${e.month}-${e.day} ${e.hour}:${e.minute}",
        brushingTime:
            "${e.difference(s).inMinutes}:${(e.difference(s).inSeconds) % 60}",
        sectionRatio:
            "${(leftCount / (leftCount + rightCount) * 100).ceil()} : ${100 - (leftCount / (leftCount + rightCount) * 100).ceil()}",
        brushingMethod:
            (100 > ((correctMethod / totalCountMethod) * 100).ceil())
                ? "${((correctMethod / totalCountMethod) * 100).ceil()}%"
                : "100"));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
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
                        image: AssetImage('assets/teeth.png'),
                        fit: BoxFit.cover),
                  ),
                  height: 300,
                  width: 300,
                  child: Row(
                    children: [
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: Container(
                              child: Center(
                                  child: Text(
                            "${(leftCount / (leftCount + rightCount) * 100).ceil()}",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.red),
                          )))),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: Container(
                              child: const VerticalDivider(
                            thickness: 1,
                            width: 1,
                            color: Colors.blue,
                          ))),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: Center(
                              child: Text(
                            "${100 - (leftCount / (leftCount + rightCount) * 100).ceil()}",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.red),
                          ))),
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
                ]),
                const Text(
                    "아래 주소를 통해 올바른 양치법 학습:\nhttp://www.kacpd.org/general/sub01.html"),
                TextButton(
                    child: const Text("이전 결과 확인"),
                    onPressed: () {
                      Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (context) => const PreviousRecord()));
                    }),
                TextButton(
                    onPressed: pushDataBase, child: const Text("결과 저장하기"))
              ],
            ),
          ),
        ),
      );
    });
  }
}

class PreviousRecord extends StatelessWidget {//데이터베이스에 있는 이전 결과 보여주는 페이지
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
          child: Column(children: [
            DataTable(
                columns: const [
                  DataColumn(label: Text("date")),
                  DataColumn(label: Text("brushingTime")),
                  DataColumn(label: Text("sectionRatio")),
                  DataColumn(label: Text("brushingMethod")),
                ],
                rows: record.isNotEmpty
                    ? List.generate(
                        record.length,
                        (index) => DataRow(cells: [
                              DataCell(Text(record[index].date)),
                              DataCell(Text(record[index].brushingTime)),
                              DataCell(Text(record[index].sectionRatio)),
                              DataCell(Text(record[index].brushingMethod)),
                            ]))
                    : [
                        const DataRow(cells: [DataCell(Text("empty"))])
                      ])
          ]),
        ),
      ),
    );
  }
}
