// lib/core/utils/video_player_utils/youtube_utils.dart

class YouTubeUtils {
  /// Extracts the video ID from a YouTube URL
  static String? extractVideoIdFromUrl(String url) {
    if (url.isEmpty) return null;

    // Handle YouTube URLs with playlist parameters
    final hasPlaylist = url.contains('list=');
    if (hasPlaylist) {
      // Extract just the video part before any playlist parameters
      final videoIdMatch = RegExp(r'v=([a-zA-Z0-9_-]+)').firstMatch(url);
      if (videoIdMatch != null) {
        return videoIdMatch.group(1);
      }

      // Check for youtu.be format with playlist
      final youtuBeLinkMatch =
          RegExp(r'youtu\.be\/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (youtuBeLinkMatch != null) {
        return youtuBeLinkMatch.group(1);
      }
    }

    // Regular expressions for different YouTube URL formats
    RegExp regExp1 = RegExp(
      r"^https?:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)",
    );
    RegExp regExp2 = RegExp(
      r"^https?:\/\/(?:www\.|m\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]+)",
    );
    RegExp regExp3 = RegExp(
      r"^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]+)",
    );

    // Check each format
    if (regExp1.hasMatch(url)) {
      return regExp1.firstMatch(url)?.group(1);
    } else if (regExp2.hasMatch(url)) {
      return regExp2.firstMatch(url)?.group(1);
    } else if (regExp3.hasMatch(url)) {
      return regExp3.firstMatch(url)?.group(1);
    }

    // If the URL doesn't match any format, it might be just the video ID
    if (url.length >= 11 && !url.contains("/") && !url.contains(":")) {
      return url;
    }

    return null;
  }

  /// Checks if a URL is a valid YouTube URL
  static bool isYouTubeUrl(String url) {
    return extractVideoIdFromUrl(url) != null;
  }
}
