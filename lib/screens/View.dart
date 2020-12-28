import 'package:first_memo/database/db.dart';
import 'package:first_memo/database/memo.dart';
import 'package:first_memo/screens/edit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewPage extends StatefulWidget {

  ViewPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _ViewPageState createState() => _ViewPageState();
}


class _ViewPageState extends State<ViewPage> {
  BuildContext _context;

  String title = '';
  String text = '';
  String createTime = '';
  String deleteId = '';

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.delete),
                onPressed: () {
                  deleteId = widget.id;
                  showAlertDialog(context);
            }),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context,
                CupertinoPageRoute(
                  builder: (context) => EditPage(id: widget.id)
                )).then((value) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
        body: Padding(padding: EdgeInsets.all(10), child: loadBuilder()));
  }

  Future<List<Memo>> loadMemo(String id) async {
    DBHelper sd = DBHelper();
    return await sd.findMemo(id);
  }

  loadBuilder() {
    return FutureBuilder<List<Memo>>(
      future: loadMemo(widget.id),
      builder: (BuildContext context, AsyncSnapshot<List<Memo>> snapshot) {
        if (snapshot?.data?.isEmpty ?? true) {
          return Container(child: Text("데이터를 불러올 수 없음"));
        } else {
          Memo memo = snapshot.data[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(height: 60,
                  child: SingleChildScrollView(
                    child: Text(memo.title,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
              )),
              Text(
                '메모를 생성한 시간' + memo.createTime.split('.')[0],
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Text(
                '메모를 수정한 시간' + memo.editTime.split('.')[0],
                style: TextStyle(fontSize: 11),
                textAlign: TextAlign.end,
              ),
              Padding(padding: EdgeInsets.all(10)),
              Expanded(child: SingleChildScrollView(child: Text(memo.text))),
            ],
          );
        }
      },
    );
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
}
