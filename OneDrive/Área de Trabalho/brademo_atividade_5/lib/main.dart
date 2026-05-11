import 'package:flutter/material.dart';
import 'post.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PostScreen());
  }
}

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _result = '';
  List<Post> _posts = [];

  void _fetchPosts() async {
    try {
      List<Post> posts = await Post.fetchPosts();
      setState(() {
        _posts = posts;
        _result = 'Fetched ${posts.length} posts';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _fetchPost() async {
    int id = int.tryParse(_idController.text) ?? 1;
    try {
      Post post = await Post.fetchPost(id);
      setState(() {
        _result = 'Fetched post: ${post.title}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _createPost() async {
    int userId = int.tryParse(_userIdController.text) ?? 1;
    String title = _titleController.text;
    String body = _bodyController.text;
    Post newPost = Post(userId, 0, title, body);
    try {
      Post created = await Post.createPost(newPost);
      setState(() {
        _result = 'Created post with id: ${created.id}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _updatePost() async {
    int id = int.tryParse(_idController.text) ?? 1;
    int userId = int.tryParse(_userIdController.text) ?? 1;
    String title = _titleController.text;
    String body = _bodyController.text;
    Post updatedPost = Post(userId, id, title, body);
    try {
      Post updated = await Post.updatePost(id, updatedPost);
      setState(() {
        _result = 'Updated post: ${updated.title}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _deletePost() async {
    int id = int.tryParse(_idController.text) ?? 1;
    try {
      await Post.deletePost(id);
      setState(() {
        _result = 'Deleted post $id';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('JSONPlaceholder Posts')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _fetchPosts, child: Text('Get All')),
                ElevatedButton(onPressed: _fetchPost, child: Text('Get by ID')),
                ElevatedButton(onPressed: _createPost, child: Text('Create')),
                ElevatedButton(onPressed: _updatePost, child: Text('Update')),
                ElevatedButton(onPressed: _deletePost, child: Text('Delete')),
              ],
            ),
            SizedBox(height: 20),
            Text(_result),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_posts[index].title),
                    subtitle: Text(_posts[index].body),
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
