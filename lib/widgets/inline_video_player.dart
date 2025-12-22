import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String url;
  const InlineVideoPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Use networkUrl (non-deprecated) and enable scrubbing in Chewie so users can seek by tapping the progress bar.
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoController
        .initialize()
        .then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: false,
            looping: false,
            showControls: true,
            allowFullScreen: true,
          );
          setState(() => _initialized = true);
        })
        .catchError((_) {
          // initialization failed
        });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Constrain the player to the video's aspect ratio so the controls (including progress bar)
    // remain inside the frame and don't overflow.
    final aspect = _videoController.value.aspectRatio;
    return AspectRatio(
      aspectRatio: aspect > 0 ? aspect : 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}
