import 'package:flutter/material.dart';
import 'package:fusechat/components/fullscreen_image.dart';
import 'package:fusechat/components/videoplayer_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class MessageBubble extends StatelessWidget {
  final String text;
  final String? mediaUrl;
  final bool isMe;
  final String? type;

  MessageBubble({required this.text, required this.isMe, this.mediaUrl,this.type});

  Future<Uint8List?> _getVideoThumbnail(String url) async {
    return await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 25,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImage = mediaUrl != null && type == 'image';
    final isVideo = mediaUrl != null && type == 'video';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: isImage
            ? (){Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenImage(imageUrl: mediaUrl!)));}
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: (isImage || isVideo) ? EdgeInsets.zero : EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isImage || isVideo) ? Colors.transparent : isMe ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(isImage ? 0 : 16),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (isImage)
                Hero(
                  tag: mediaUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      mediaUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (isVideo && mediaUrl != null)
                FutureBuilder<Uint8List?>(
                  future: _getVideoThumbnail(mediaUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoplayerScreen(videoUrl: mediaUrl!),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                snapshot.data!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                          ],
                        ),
                      );
                    }
                    return Text('Could not load thumbnail');
                  },
                ),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}