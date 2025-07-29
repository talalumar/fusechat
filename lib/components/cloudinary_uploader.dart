import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryUploader{
  final String cloudName = 'dj845hxmm';
  final String uploadPreset = 'fuse-chat';

  // Picks image from gallery
  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
  
  // Upload to Cloudinary
  Future<String?> uploadImageToCloudinary(File imageFile) async{
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if(response.statusCode == 200){
      final resStr = await response.stream.bytesToString();
      final resData = json.decode(resStr);
      return resData['secure_url'];
    }else{
      print('Cloudinary upload failes: ${response.statusCode}');
      return null;
    }
  }


  Future<String?> pickAndUploadImage() async{
    final imageFile = await pickImage();
    if(imageFile == null) return null;
    return await uploadImageToCloudinary(imageFile);
  }
}