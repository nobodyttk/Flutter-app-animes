// lib/screens/video_player_screen.dart

// REMOVEMOS O IMPORT DO CACHED_NETWORK_IMAGE, POIS NÃO É MAIS USADO
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../widgets/custom_loading_indicator.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  // A propriedade 'placeholderImageUrl' foi REMOVIDA daqui

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    // O parâmetro 'placeholderImageUrl' foi REMOVIDO daqui
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      // LÓGICA DO PLACEHOLDER SIMPLIFICADA
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );
    
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _chewieController != null &&
               _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomLoadingIndicator(height: 100, width: 100),
                  SizedBox(height: 20),
                  Text('Carregando Vídeo...'),
                ],
              ),
      ),
    );
  }
}