import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_permission/flutter_plugin_permission.dart';

void main() => runApp(
  new MaterialApp(
    home: new Scaffold(
      appBar: new AppBar(
        title: new Text('Plugin example app'),
        ),
      body: new MyApp(),
    ),
  ),
);

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String permission;

  List<String> selects = new List();

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPluginPermission.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
          child: new Column(children: <Widget>[
            new Text('Running on: $_platformVersion\n'),
            new Text('Single choice'),
            new DropdownButton(items: _getDropDownItems(), value: permission, onChanged: onDropDownChanged),
            new RaisedButton(onPressed: checkPermission, child: new Text("Check permission")),
            new RaisedButton(onPressed: requestPermission, child: new Text("Request permission")),
            new RaisedButton(onPressed: getPermissionStatus, child: new Text("Get permission status")),
            new RaisedButton(onPressed: FlutterPluginPermission.openSettings, child: new Text("Open settings")),
            new Text('Multiple choice'),
            new ListTile(
                onTap: () {
//                  showListDialog(context);
                  List<PermissionItem> list = new List();
                  Permission.values.forEach((permission) {
                    String item  = getPermissionString(permission);
                    list.add(new PermissionItem(name: item, isCheck: false));
                  });
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new PermissionList(list: list))).then((value) {
                    setState(() {
                      if(selects.isNotEmpty) {
                        selects.clear();
                      }
                      List<PermissionItem> temp = value;
                      for (var i = 0; i < temp.length; i++) {
                        selects.add(temp[i].name);
                      }
                    });
                  });
                },
                title: new Text("Chick Request permissions selected ${selects.length}")),
            new RaisedButton(onPressed: requestPermissions, child: new Text("Request permissions")),
          ]),
    );
  }
  onDropDownChanged(String permission) {
    setState(() => this.permission = permission);
    print(permission);
  }

  requestPermission() async {
    bool res = await FlutterPluginPermission.requestPermission(permission);
    print("permission request result is " + res.toString());
  }

  requestPermissions() async {
    if(selects.length == 0) {
      return;
    }
    await FlutterPluginPermission.requestPermissions(selects);
  }

  checkPermission() async {
    bool res = await FlutterPluginPermission.checkPermission(permission);
    print("permission is " + res.toString());
  }

  getPermissionStatus() async {
    final res = await FlutterPluginPermission.getPermissionStatus(permission);
    print("permission status is " + res.toString());
  }

  List<DropdownMenuItem<String>>_getDropDownItems() {
    List<DropdownMenuItem<String>> items = new List();
    Permission.values.forEach((permission) {
      var item  = new DropdownMenuItem(child: new Text(getPermissionString(permission)), value: getPermissionString(permission));
      items.add(item);
    });
    return items;
  }

  showListDialog(BuildContext cxt) {

    List<PermissionItem> list = new List();
    Permission.values.forEach((permission) {
      String item  = getPermissionString(permission);
      list.add(new PermissionItem(name: item, isCheck: false));
    });

    print('===============list.length=======${list.length}');

    showDialog(
        context: cxt,
        builder: (cxt) => new Dialog(
          child: new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(title: new Text('选择'),),
                  new Divider(height: 2.0, color: Colors.blue,),
                  new Expanded(
                    child: new ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new Row(
                          children: <Widget>[
                            new Expanded(child: new Text(list[index].name)),
                            new Checkbox(value: list[index].isCheck, onChanged: (bool value) {
                              setState(() {
                                print("=====================$value");
                                list[index].isCheck = value;
                              });
                            })
                          ],
                        );
                      }
                  ),
                  ),
                  new RaisedButton(onPressed: () {
                    for (PermissionItem p in list) {
                      if (p.isCheck) {
                        print(p.name);
                        selects.add(p.name);
                      }
                    }
                    Navigator.pop(context);
                  },
                    child: new Text('OK ${selects.length}'),
                  )
                ],
              )
          ),
        )
    );
  }
}

class PermissionItem {
  String name;
  bool isCheck;
  PermissionItem({this.name, this.isCheck});
}

class PermissionItemList extends StatefulWidget {
  PermissionItemList(PermissionItem item) : item = item, super(key: new ObjectKey(item));
  final PermissionItem item;
  @override
  PermissionItemState createState() => new PermissionItemState(item);
}

class PermissionItemState extends State<PermissionItemList> {
  final PermissionItem item;
  PermissionItemState(this.item);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      onTap: null,
      title: new Row(
        children: <Widget>[
          new Expanded(child: new Text(item.name)),
          new Checkbox(value: item.isCheck, onChanged: (bool value) {
            setState(() {
              item.isCheck = value;
            });
          })
        ],
      ),
    );
  }
}

class PermissionList extends StatefulWidget {
  PermissionList({Key key, this.list}) :super(key: key);

  List<PermissionItem> list;

  @override
  _PermissionListState createState() {
    return new _PermissionListState();
  }
}

class _PermissionListState extends State<PermissionList> {

  List<PermissionItem> temp = new List();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Product List"),
        ),
        body: new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Expanded(child: new ListView(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                children: widget.list.map((PermissionItem item) {
                  return new PermissionItemList(item);
                }).toList(),
              )),
              new RaisedButton(onPressed: () {

                if(temp.isNotEmpty) {
                 temp.clear();
                }
                for (PermissionItem p in widget.list) {
                  if (p.isCheck) {
                    temp.add(p);
                    print(p.name);
                  }
                }

                Navigator.pop(context, temp);
              },
                child: new Text('Save'),
              )
            ],
          ),
        )
    );
  }
}