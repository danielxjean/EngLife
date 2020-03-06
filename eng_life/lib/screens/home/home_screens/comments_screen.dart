import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eng_life/models/comment.dart';
import 'package:eng_life/models/user.dart';

/// Comments Page class
class CommentsPage extends StatefulWidget {
  final User user;
  final DocumentReference documentReference;
  CommentsPage({this.user, this.documentReference});

  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsPage> {
  TextEditingController _comment =  new TextEditingController();
  var _formKey = GlobalKey<FormState>();


  /// This function disposes of the comment if called upon
  void dispose() {
    super.dispose();
    _comment?.dispose(); // the '?' checks if the _comment is null and if it is, it returns null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.red[900],
        title: Text('Comments'),
      ),
      body: Form(
        key:_formKey,
        child: Column(
          children: <Widget>[
            listOfComments(),
            Divider(
              height: 20.0,
              color: Colors.red[900],
            ),
            inputCommentWidget()
          ],
        ),
      ),
    );
  }

  Widget inputCommentWidget() {
    return Container(
      height: 45.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 45.0),
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45.0),
              image: DecorationImage(image: NetworkImage(widget.user.profilePictureUrl))
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                validator: (String commentInput) {
                  if (commentInput.isEmpty)
                    return "Please enter a comment";
                  else
                    return "Comment posted";
                },
                controller: _comment,
                decoration: InputDecoration(
                  hintText: "Add comment...",
                ),
                onFieldSubmitted: (value) {
                  _comment.text = value;
                },
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Post', style: TextStyle(
                color: Colors.red[900],
              ),
              ),
            ),
            onTap: () {
              if (_formKey.currentState.validate())
                commentPost();
            },
          )
        ],
      )
    );
  }


  commentPost() {
    var inputComment = Comment(
      displayName: widget.user.displayName,
      profilePictureUrl: widget.user.profilePictureUrl,
      comment: _comment.text,
      uid: widget.user.uid,
      timeStamp: FieldValue.serverTimestamp(),
    );
    widget.documentReference.collection("comments").document().setData(inputComment.toMap(inputComment)).whenComplete(() {
    _comment.text = "";
  });
}

  Widget listOfComments () {
    return Flexible(
      child: StreamBuilder(
        stream: widget.documentReference
          .collection("comments")
          .orderBy('timeStamp', descending: false)
          .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return (Center(child: CircularProgressIndicator()));
          } else {
            return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: ((context, index)=> commentItem(snapshot.data.documents[index])),
            );
            }
        }),
      ),
    );
}

  Widget commentItem(DocumentSnapshot documentSnapshot) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(documentSnapshot.data['profilePictureUrl']),
              radius: 20,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Row(
            children: <Widget>[
              Text(documentSnapshot.data['displayName'], style: TextStyle(fontWeight: FontWeight.bold,)),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(documentSnapshot.data['comment']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// should we add this Comments class in home.dart