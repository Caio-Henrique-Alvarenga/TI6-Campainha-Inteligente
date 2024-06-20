import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as Path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appDirPath = appDir.path;
      final String fileName = Path.basename(pickedFile.path);
      final String localPath = '$appDirPath/$fileName';

      final File localImage = await File(pickedFile.path).copy(localPath);

      setState(() {
        _image = localImage;
      });

      await _uploadImage(localImage);
    }
  }

  Future<void> _uploadImage(File image) async {
    final url = Uri.parse('http://192.168.1.10:5000/recognize');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('img', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (jsonResponse['status'] == 'morador') {
        _showMoradorDialog(jsonResponse['nome']);
      } else if (jsonResponse['status'] == 'conhecido') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KnownPersonScreen(
              image: _image!,
              name: jsonResponse['nome'],
            ),
          ),
        );
      } else if (jsonResponse['status'] == 'desconhecido') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnknownPersonScreen(
              image: _image!,
            ),
          ),
        );
      }
    } else {
      // Handle error response
    }
  }


  void _showMoradorDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bem-vindo $name'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campainha Inteligente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
              _image!,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            )
                : Text('Nenhuma imagem selecionada.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Selecionar Imagem'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class KnownPersonScreen extends StatelessWidget {
  final File image;
  final String name;

  KnownPersonScreen({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pessoa Conhecida'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              image,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text('$name chegou'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para permitir entrada
              },
              child: Text('Permitir Entrada'),
            ),
            SizedBox(height: 10), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                // Lógica para negar entrada
              },
              child: Text('Negar Entrada'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnknownPersonScreen extends StatelessWidget {
  final File image;

  UnknownPersonScreen({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pessoa Desconhecida'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              image,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text('Esta pessoa tocou sua campainha'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para permitir entrada
              },
              child: Text('Permitir Entrada'),
            ),
            SizedBox(height: 10), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                // Lógica para negar entrada
              },
              child: Text('Negar Entrada'),
            ),
            SizedBox(height: 10), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPersonScreen(image: image),
                  ),
                );
              },
              child: Text('Registrar Pessoa'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPersonScreen extends StatefulWidget {
  final File image;

  RegisterPersonScreen({required this.image});

  @override
  _RegisterPersonScreenState createState() => _RegisterPersonScreenState();
}

class _RegisterPersonScreenState extends State<RegisterPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _group = 'conhecido';

  Future<void> _registerImage(File image, String nome, String status) async {
    final url = Uri.parse('http://192.168.1.10:5000/register');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('img', image.path))
      ..fields['nome'] = nome
      ..fields['status'] = status;

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      _showRegisterSuccesDialog(nome);

    } else {
      // Handle error response
    }
  }

  void _showRegisterSuccesDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name foi registrado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Registrar Pessoa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.file(
                widget.image,
                height: 300,
                width: 300,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _group,
                items: ['conhecido', 'morador']
                    .map((group) => DropdownMenuItem(
                  value: group,
                  child: Text(group),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _group = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Grupo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Lógica para registrar a pessoa
                    _registerImage(widget.image, _nameController.text, _group);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
