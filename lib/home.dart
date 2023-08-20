import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'calendar.dart';
import 'exams.dart';
import 'map.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _c = TextEditingController();
  TextEditingController _year = TextEditingController();
  TextEditingController _month = TextEditingController();
  TextEditingController _day = TextEditingController();
  TextEditingController _hour = TextEditingController();
  TextEditingController _minute = TextEditingController();

  @override
  void initState() {
    _c = TextEditingController();
    _year = TextEditingController();
    _month = TextEditingController();
    _day = TextEditingController();
    _hour = TextEditingController();
    _minute = TextEditingController();
    createNotification();
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow Notifications'),
            content: const Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Don\'t Allow',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
            ],
          ),
        );
      }
    });
    AwesomeNotifications().actionStream.listen((notification) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarScreen(elements: elements),
          ),
              (route) => route.isFirst);
    });
    super.initState();
  }

  void createNotification() {
    for (var element in elements) {
      if (isNextWeek(element.dateTime)) {
        createNotificationForExam(element);
      }
    }
  }

  bool isNextWeek(DateTime datetime) {
    final day = DateTime.now().add(const Duration(days: 7));
    return day.day == datetime.day && day.month == datetime.month && day.year == datetime.year;
  }

  Future<void> createNotificationForExam(ExamApplication exam) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'channel',
        title: 'Exam: ${exam.course}',
        body:
        'You have an exam next week !!!',
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'CONFIRM',
          label: 'Confirm',
        )
      ],
    );
  }
  int createUniqueId() {
    return DateTime.now().microsecondsSinceEpoch.remainder(100000);
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
    _c.dispose();
    _year.dispose();
    _month.dispose();
    _day.dispose();
    _hour.dispose();
    _minute.dispose();
    super.dispose();
  }

  final String title = "MIS LAB 3";
  final List<ExamApplication> elements = [
    ExamApplication(
        course: "Mobilni Informaciski Sistemi",
        dateTime: DateTime(2023, 8, 20, 17, 30)),
    ExamApplication(
        course: "Verojatnost i Statistika",
        dateTime: DateTime(2023, 8, 19, 15, 30),
        lat: 42.004715,
        long: 21.408212)
  ];
  String _course = "";
  String _y = "2022";
  String _m = "2";
  String _d = "1";
  String _h = "18";
  String _min = "45";

  void addExamApplication(course, year, month, day, hour, minute) {
    setState(() {
      elements.add(ExamApplication(
          course: course,
          dateTime: DateTime(year, month, day, hour, minute)));
    });
    if(isNextWeek(DateTime(year, month, day, hour, minute)))
      createNotificationForExam(ExamApplication(course: course, dateTime: DateTime(year, month, day, hour, minute)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right:5.0),
              child: Container(
                color: Colors.white,
                child:IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(elements: elements),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.map_outlined,
                    color: Colors.blue,
                  ),
                  iconSize: 20.0,
                ),),),
            Padding(
              padding: EdgeInsets.only(right:5.0),
              child: Container(
                color: Colors.white,
                child:IconButton(
                  onPressed: () {
                     FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.blue,
                  ),
                  iconSize: 20.0,
                ),),),
            Padding(
              padding: EdgeInsets.only(right:5.0),
              child: Container(
                color: Colors.white,
                child:IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(elements: elements),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                  ),
                  iconSize: 20.0,
                ),),),
            Padding(
                padding: EdgeInsets.only(right:15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blue// Background color
                  ),
                  child: const Text("Add +"),
                  onPressed: () {
                    setState(() {
                      _course = _c.text;
                      _y = _year.text;
                      _m = _month.text;
                      _d = _day.text;
                      _h = _hour.text;
                      _min = _minute.text;
                      addExamApplication(
                          _course,
                          int.parse(_y),
                          int.parse(_m),
                          int.parse(_d),
                          int.parse(_h),
                          int.parse(_min));
                      _c.text = "";
                      _year.text = "";
                      _month.text = "";
                      _day.text = "";
                      _hour.text = "";
                      _minute.text = "";
                    });
                  },
                ))
          ],
        ),
        body: Column(
          children: [
            SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextField(
                    onChanged: (v) => setState(() {
                      _course = v;
                    }),
                    controller: _c,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Course name',
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                        width: double.infinity,
                        child: TextField(
                          onChanged: (v) => setState(() {
                            _y = v;
                          }),
                          controller: _year,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'YYYY',
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(0),
                        width: double.infinity,
                        child: TextField(
                          onChanged: (v) => setState(() {
                            _m = v;
                          }),
                          controller: _month,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'MM',
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                        width: double.infinity,
                        child: TextField(
                          onChanged: (v) => setState(() {
                            _d = v;
                          }),
                          controller: _day,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'DD',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 8, 5, 0),
                        width: double.infinity,
                        child: TextField(
                          onChanged: (v) => setState(() {
                            _h = v;
                          }),
                          controller: _hour,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'HH',
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 10, 0),
                        width: double.infinity,
                        child: TextField(
                          onChanged: (v) => setState(() {
                            _min = v;
                          }),
                          controller: _minute,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'MM',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  print(elements[index]);
                  return Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            elements[index].course,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Text(
                            "${elements[index].dateTime.year.toString()}-${elements[index].dateTime.month.toString().padLeft(2, '0')}-${elements[index].dateTime.day.toString().padLeft(2, '0')} ${elements[index].dateTime.hour.toString().padLeft(2, '0')}:${elements[index].dateTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
