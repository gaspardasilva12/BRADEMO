import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post(this.userId, this.id, this.title, this.body);

  String toJson() {
    // Necessário converter para Map<String, dynamic>
    Map<String, dynamic> input = {
      "userId": this.userId,
      "id": this.id,
      "title": this.title,
      "body": this.body,
    };
    // Converte para JSON
    return jsonEncode(input);
  }

  static Post fromJson(String jsonSource) {
    // Converte para Map<String, dynamic>
    Map<String, dynamic> item = jsonDecode(jsonSource);
    // Cria um Post de um JSON
    return Post(item['userId'], item['id'], item['title'], item['body']);
  }

  // GET list of posts
  static Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Post.fromJson(jsonEncode(item))).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // GET single post
  static Future<Post> fetchPost(int id) async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  // POST create post
  static Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: post.toJson(),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(response.body);
    } else {
      throw Exception('Failed to create post');
    }
  }

  // PUT update post
  static Future<Post> updatePost(int id, Post post) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: post.toJson(),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(response.body);
    } else {
      throw Exception('Failed to update post');
    }
  }

  // DELETE post
  static Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
