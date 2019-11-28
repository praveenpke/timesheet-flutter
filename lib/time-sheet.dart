import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secondaryColor = const Color(0xFF03a9f4);
final primaryColor = const Color(0xFFe1f5fe); //cell color
final totalDays = 100;
final FlutterSecureStorage storage = FlutterSecureStorage();

class TimeSheet extends StatefulWidget {
  @override
  _TimeSheetState createState() => _TimeSheetState();
}

class _TimeSheetState extends State<TimeSheet> {
  final Map<num, bool> daysSelected = <num, bool>{};
  num daysCount = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String value = await storage.read(key: 'count');
      daysCount = num.parse(value) ?? 0;
    });
    mapDateSelections();
    setState(() {});
  }

  calculateDaysCount() async {
    daysCount = 0;
    for (num i = 0; i <= daysSelected.length; i++) {
      if (daysSelected[i] == true) {
        daysCount++;
      }
    }
    await storage.write(key: 'count', value: daysCount.toString());
  }

  onCellTapped(String selectedDate) async {
    num value;
    if (selectedDate.substring(0, 1) == '0') {
      value = num.parse(
        selectedDate.substring(1, 2),
      );
    } else {
      value = num.parse(
        selectedDate,
      );
    }
    daysSelected[value] = !daysSelected[value];
    await calculateDaysCount();
    setState(() {});
  }

  onReset() {
    mapDateSelections();
    daysCount = 0;
    setState(() {});
  }

  mapDateSelections() {
    for (num i = 1; i < totalDays + 1; i++) {
      if(i<daysCount){
        daysSelected[i] = true;
      }
      else{
        daysSelected[i] = false;
      }
    }
  }

  List<GridCell> getDaysInWeekWidgets() {
    List<GridCell> gridCells = <GridCell>[];
    final List<String> daysInWeek = <String>[
      'Su',
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa'
    ];
    for (num i = 0; i < daysInWeek.length; i++) {
      gridCells.add(
        GridCell(
          textValue: daysInWeek[i],
          cellTapped: true,
          cellColor: secondaryColor,
          textColor: primaryColor,
        ),
      );
    }
    return gridCells;
  }

  List<GridCell> prepareGrid() {
    mapDateSelections();
    List<GridCell> gridCells = <GridCell>[];
    for (num i = 1; i < totalDays + 1; i++) {
      gridCells.add(
        GridCell(
          textValue: i.toString().padLeft(2, '0'),
          cellTapped: daysSelected[i],
          onCellTapped: onCellTapped,
          cellColor: primaryColor,
        ),
      );
    }
    return gridCells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GridText(
          textContent: 'TimeSheet',
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          bottom: 40,
          right: 20,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: getDaysInWeekWidgets(),
            ),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: prepareGrid(),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: GridText(
                      textContent:
                          daysCount != 0 ? 'Days Completed  :  $daysCount' : '',
                      fontSize: 18,
                      textColor: secondaryColor,
                    ),
                  ),
                  Container(
                    child: FloatingActionButton(
                      elevation: 20,
                      backgroundColor: secondaryColor,
                      onPressed: onReset,
                      child: GridText(
                        textContent: 'Reset',
                        fontSize: 14,
                        textColor: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridText extends StatelessWidget {
  const GridText({this.textContent, this.fontSize = 23, this.textColor});
  final String textContent;
  final double fontSize;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Text(
      textContent,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class GridCell extends StatelessWidget {
  const GridCell({
    this.textValue,
    this.cellTapped,
    this.onCellTapped,
    this.cellColor,
    this.textColor = Colors.black87,
  });
  final String textValue;
  final bool cellTapped;
  final Function onCellTapped;
  final Color cellColor;
  final Color textColor;

  onGridCellTapped() {
    onCellTapped(textValue);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onGridCellTapped,
      child: Container(
        width: 45,
        height: 45,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: cellTapped ? cellColor : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          textValue,
          style: TextStyle(
            color: cellTapped ? textColor : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
