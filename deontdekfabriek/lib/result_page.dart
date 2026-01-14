import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final String bandName;
  final String festivalName;
  final VoidCallback onMinigameCompleted;

  const ResultPage({
    super.key,
    required this.score,
    required this.bandName,
    required this.festivalName,
    required this.onMinigameCompleted,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _videoError;
  bool _isPlaying = false;
  bool _isLiked = false;
  int _likeCount = 1234;
  final List<String> _comments = [
    'Amazing festival! ',
    'Love the eco-friendly vibes!',
    'Food was yummy',
    'Great job on the stage!',
    'Goated Festival',
  ];

  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    
    try {
      // Load video from assets
      _videoController = VideoPlayerController.asset(
        'assets/videos/outro.mp4',
      );
      
      // Add listener for errors
      _videoController!.addListener(() {
        if (_videoController!.value.hasError) {
          if (mounted) {
            setState(() {
              _videoError = _videoController!.value.errorDescription ?? 'Video error';
            });
          }
        }
      });
      
      // Initialize the controller
      await _videoController!.initialize();
      
      if (!mounted) {
        _videoController?.dispose();
        return;
      }
      
      if (_videoController!.value.hasError) {
        setState(() {
          _videoError = _videoController!.value.errorDescription ?? 'Unknown error';
        });
        return;
      }
      
      setState(() {
        _isVideoInitialized = true;
        _isPlaying = true;
      });
      
      _videoController!.setLooping(true);
      await _videoController!.play();
      
      // Listen to playback state changes
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Error initializing video: $error');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _videoError = 'Failed to load video: ${error.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCommentsSheet(),
    );
  }

  Widget _buildCommentsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade800,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _comments[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final phoneWidth = size.width * 0.25; // Even narrower phone frame
    final phoneHeight = phoneWidth * 1.9; // Phone aspect ratio

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: phoneWidth,
          height: phoneHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.grey.shade700,
              width: 10,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                // Video player (center area)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: _isVideoInitialized && _videoController != null
                        ? Stack(
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                              // Pause/Play button overlay (fades out when playing)
                              AnimatedOpacity(
                                opacity: _isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Center(
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              // Tap area to pause/play (always active)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (_videoController!.value.isPlaying) {
                                      await _videoController!.pause();
                                    } else {
                                      await _videoController!.play();
                                    }
                                    setState(() {
                                      _isPlaying = _videoController!.value.isPlaying;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_videoError != null) ...[
                                    const Icon(
                                      Icons.error_outline,
                                      size: 60,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Video Error',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        _videoError!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Check console for details',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ] else ...[
                                    const CircularProgressIndicator(
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Loading video...',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                // TikTok-like UI buttons inside the frame on the right side
                Positioned(
                  right: 12,
                  bottom: phoneHeight * 0.15,
                  child: Column(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: _isLiked ? Colors.red : Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatCount(_likeCount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Comments button
                      GestureDetector(
                        onTap: _showComments,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.comment_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatCount(_comments.length),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
