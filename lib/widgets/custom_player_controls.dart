// lib/widgets/custom_player_controls.dart

import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomPlayerControls extends StatefulWidget {
  const CustomPlayerControls({Key? key}) : super(key: key);

  @override
  State<CustomPlayerControls> createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  final ValueNotifier<bool> _showControlsNotifier = ValueNotifier<bool>(true);
  Timer? _hideControlsTimer;

  @override
  void dispose() {
    _showControlsNotifier.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _showControlsNotifier.value = false;
      }
    });
  }

  void _toggleControlsVisibility() {
    _showControlsNotifier.value = !_showControlsNotifier.value;
    if (_showControlsNotifier.value) {
      _startHideControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showControlsNotifier,
      builder: (context, areControlsVisible, child) {
        if (areControlsVisible) {
          _startHideControlsTimer();
        }

        return GestureDetector(
          onTap: _toggleControlsVisibility,
          child: Container(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: areControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: <Widget>[
                  _buildTopBar(context),
                  _buildCenterPlayPause(),
                  _buildBottomBar(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Assistindo Episódio...',
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPlayPause() {
    final chewieController = ChewieController.of(context);
    return Center(
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: chewieController.videoPlayerController,
        builder: (context, value, child) {
          if (value.position >= value.duration && !value.isPlaying) {
            return IconButton(
              icon: const Icon(Icons.replay, color: Colors.white, size: 50.0),
              onPressed: () {
                chewieController.seekTo(Duration.zero);
                chewieController.play();
              },
            );
          }
          return IconButton(
            icon: Icon(
              value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: Colors.white,
              size: 50.0,
            ),
            onPressed: () => chewieController.togglePause(),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final chewieController = ChewieController.of(context);
    final videoPlayerController = chewieController.videoPlayerController;
    
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: videoPlayerController,
          builder: (context, value, child) {
            return Row(
              children: [
                Text(formatDuration(value.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: MaterialVideoProgressBar(
                      videoPlayerController,
                      colors: chewieController.materialProgressColors ?? ChewieProgressColors(playedColor: Colors.green),
                    ),
                  ),
                ),
                Text(formatDuration(value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            );
          },
        ),
      ),
    );
  }
}

String formatDuration(Duration position) {
  final ms = position.inMilliseconds;
  if (ms <= 0) return '0:00';
  final seconds = (ms / 1000).floor() % 60;
  final minutes = (ms / (1000 * 60)).floor() % 60;
  final hours = (ms / (1000 * 60 * 60)).floor();

  if (hours > 0) {
    return [hours, minutes, seconds].map((seg) => seg.toString().padLeft(2, '0')).join(':');
  } else {
    return [minutes, seconds].map((seg) => seg.toString().padLeft(2, '0')).join(':');
  }
}