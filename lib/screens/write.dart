import 'dart:convert'; // for the utf8.encode method
import 'package:crypto/crypto.dart';
import 'package:first_memo/database/db.dart';
import 'package:first_memo/database/memo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable

class WritePage extends StatefulWidget {
  WritePage({Key key, this.id}) : super(key: key);
  final String id;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<WritePage> {
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
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveDB,
            ),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                TextField(
                  maxLines: 1,
                  onChanged: (String title) {
                    this.title = title;
                  },
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  keyboardType: TextInputType.multiline,
                  //obscureText: false,
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                    hintText: '제목을 적어주세요',
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                TextField(
                    onChanged: (String text) {
                      this.text = text;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    //obscureText: false,
                    decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        hintText: '내용을 적어주세요')
                )
              ],
            )));
  }

  Future<void> saveDB() async {
    DBHelper sd = DBHelper();

    var fido = Memo(
      id: Str2Sha512(DateTime.now().toString()),
      title: this.title,
      text: this.text,
      createTime: DateTime.now().toString(),
      editTime: DateTime.now().toString(),
    );

    await sd.insertMemo(fido);

    print(await sd.memos());
  }

  String Str2Sha512(String text) {
    var bytes = utf8.encode(text); // data being hashed
    var digest = sha512.convert(bytes);
    return digest.toString();
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
