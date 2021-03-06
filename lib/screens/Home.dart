import 'package:first_memo/database/db.dart';
import 'package:first_memo/database/memo.dart';
import 'package:first_memo/screens/View.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'write.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  String deleteId = '';

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 5, top: 40, bottom: 20),
          child: Container(
            child: Text('메에모오',
                style: TextStyle(fontSize: 36, color: Colors.blue)),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(child: memoBuilder(context))
      ]),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => WritePage(),
            ),
          ).then((value) {
            setState(() {});
          });
        },
        tooltip: '메모를 추가하려면 클릭하세요.',
        label: Text('메모추가'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<List<Memo>> loadMemo() async {
    DBHelper sd = DBHelper();
    return await sd.memos();
  }

  Future<void> deleteMemo(String id) async {
    DBHelper sd = DBHelper();
    await sd.deleteMemo(id);
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 경고'),
          content: Text("삭제하시겠습니까? \n삭제된 메모는 복구되지 않습니다."),
          actions: <Widget>[
            FlatButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.pop(context, "삭제");
                setState(() {
                  deleteMemo(deleteId);
                });
                deleteId = '';
              },
            ),
            FlatButton(
              child: Text('취소'),
              onPressed: () {
                deleteId = '';
                Navigator.pop(context, "취소");
              },
            ),
          ],
        );
      },
    );
  }

  Widget memoBuilder(BuildContext parentcontext) {
    return FutureBuilder(
      builder: (context, Snap) {
        if (Snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (Snap?.data?.isEmpty ?? true) {
          return Container(
              alignment: Alignment.center,
              child: Text('메모를 지금 추가해보세요!\n\n\n\n\n\n\n\n',
                  style: TextStyle(fontSize: 15, color: Colors.blueAccent),
                  textAlign: TextAlign.center));
        } else {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            itemCount: Snap.data.length,
            itemBuilder: (context, index) {
              Memo memo = Snap.data[index];
              return InkWell(
                  onTap: () {
                    Navigator.push(
                      parentcontext,
                      CupertinoPageRoute(
                        builder: (context) => ViewPage(id: memo.id),
                      ),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  onLongPress: () {
                    deleteId = memo.id;
                    showAlertDialog(parentcontext);
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(memo.title,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                              ),
                              Text(memo.text, style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'Last Updated : ' + memo.editTime.split('.')[0],
                                style: TextStyle(fontSize: 11),
                                textAlign: TextAlign.end,
                              )
                            ],
                          )
                          // Widget to display the list of project
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(240, 240, 240, 1),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        boxShadow: [BoxShadow(color: Colors.lightBlue, blurRadius: 3)],
                        borderRadius: BorderRadius.circular(12),
                      )));
            },
          );
        }
      },
      future: loadMemo(),
    );
  }
}
