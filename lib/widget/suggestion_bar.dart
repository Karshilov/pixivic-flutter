import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requests/requests.dart';

class SuggestionBar extends StatefulWidget {
  @override
  SuggestionBarState createState() => SuggestionBarState();

  SuggestionBar(this.searchKeywordsIn, this.onCellTap, this.key);

  final String searchKeywordsIn; 
  final ValueChanged<String> onCellTap;
  final Key key;
}

class SuggestionBarState extends State<SuggestionBar> {
  String searchKeywords;
  List suggestions;

  @override
  void initState() {
    searchKeywords = widget.searchKeywordsIn;
    _loadSuggestions().then((value) {
      setState(() {
        suggestions = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(suggestions != null) {
      return Container(
        height: ScreenUtil().setHeight(50),
        width: ScreenUtil().setWidth(324),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            var keywordsColumn;
            if (suggestions[index]['keywordTranslated'] != '') {
              keywordsColumn = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  suggestionsKeywordsText(suggestions[index]['keyword']),
                  suggestionsKeywordsText(suggestions[index]['keywordTranslated']),
                ]
              );
            } else {
              keywordsColumn = suggestionsKeywordsText(suggestions[index]['keyword']);
            }

            return GestureDetector(
              onTap: () {
                widget.onCellTap(suggestions[index]['keyword']);
              },
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
                  color: Colors.teal[200],
                ),
                // width: ScreenUtil().setWidth(80),
                padding: EdgeInsets.all(8),
                child: Center(child: keywordsColumn,),
              ),
            );
          }
        ),
      );
    }
    else {
      return Center();
    }
  }

  Widget suggestionsKeywordsText(String suggestions) {
    return Text(
      suggestions, 
      strutStyle: StrutStyle(
        fontSize: 10,
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 10
      ),
    );
  }

  _loadSuggestions() async {
    List jsonList;
    var requests;
    String urlPixiv = 'https://api.pixivic.com/keywords/$searchKeywords/pixivSuggestions';
    String urlPixivic = 'https://api.pixivic.com/keywords/$searchKeywords/suggestions';
    requests = await Requests.get(urlPixiv);
    requests.raiseForStatus();
    jsonList = jsonDecode(requests.content())['data'];
    requests = await Requests.get(urlPixivic);
    requests.raiseForStatus();
    jsonList = jsonList + jsonDecode(requests.content())['data'];
    return jsonList;
  }

  void reloadSearchWords(String value) async{
    this.searchKeywords = value;
    _loadSuggestions().then((value) {
      setState(() {
        this.suggestions = value;
      });
    });
  }
  
}