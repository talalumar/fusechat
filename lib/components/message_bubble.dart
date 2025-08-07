import 'package:flutter/material.dart';
import 'package:fusechat/components/videoplayer_screen.dart';
import 'package:fusechat/components/fullscreen_image.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final String? mediaUrl;
  final bool isMe;
  final String? type;
  final String? thumbnailPath;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    this.mediaUrl,
    this.type,
    this.thumbnailPath,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}


class _MessageBubbleState extends State<MessageBubble> {


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
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyLarge?.color,
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
            CircularProgressIndicator(color: Colors.white,),
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
                widget.thumbnailPath == null
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
                        child: CachedNetworkImage(
                          imageUrl: widget.thumbnailPath!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(child: CircularProgressIndicator(color: Color(0xFF419cd7),)),
                          errorWidget: (_, __, ___) => Icon(Icons.error),
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
                    color: widget.isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

