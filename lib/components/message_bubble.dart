import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:fusechat/components/videoplayer_screen.dart';
import 'package:fusechat/components/fullscreen_image.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final String? mediaUrl;
  final bool isMe;
  final String? type;

  const MessageBubble({
    required this.text,
    required this.isMe,
    this.mediaUrl,
    this.type,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}


class _MessageBubbleState extends State<MessageBubble> {
  Uint8List? _thumbnail;
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'video' && widget.mediaUrl != null) {
      _loadOrCreateThumbnail(widget.mediaUrl!);
    }
  }

  Future<void> _loadOrCreateThumbnail(String videoUrl) async {
    final directory = await getTemporaryDirectory();
    final fileName = Uri.parse(videoUrl).pathSegments.last.split('?').first;
    final path = '${directory.path}/thumb_$fileName.jpg';
    final file = File(path);

    if (await file.exists()) {
      // ✅ Thumbnail already cached
      setState(() {
        _thumbnailPath = path;
      });
    } else {
      // ❌ No thumbnail, generate and save
      final data = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 25,
      );
      if (data != null) {
        await file.writeAsBytes(data);
        if (mounted) {
          setState(() {
            _thumbnailPath = path;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = widget.mediaUrl != null && widget.type == 'image';
    final isVideo = widget.mediaUrl != null && widget.type == 'video';

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: isImage
            ? () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FullscreenImage(imageUrl: widget.mediaUrl!)))
            : null,
        child: Container(
          margin: (isImage || isVideo)
              ? const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
              : widget.isMe
              ? const EdgeInsets.only(left: 40, right: 8, bottom: 4, top: 4)
              : const EdgeInsets.only(left: 8, right: 40, bottom: 4, top: 4),
          padding: (isImage || isVideo) ? EdgeInsets.zero : const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isImage || isVideo)
                ? Colors.transparent
                : widget.isMe
                ? Color(0xFF419cd7)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
          if (widget.type == 'uploading')
            Container(
            padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF419cd7).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 8),
            Text("Sending...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
              if (isImage)
                Hero(
                  tag: widget.mediaUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.mediaUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Color(0xFF419cd7),)),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),

              if (isVideo)
                _thumbnailPath == null
                    ? Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(color: Color(0xFF419cd7)),
                )
                    : GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoplayerScreen(videoUrl: widget.mediaUrl!),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_thumbnailPath!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                    ],
                  ),
                ),
              if (widget.text.isNotEmpty)
                GptMarkdown(
                  widget.text,
                  style: TextStyle(
                    color: widget.isMe ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
