import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenerationState {
  const GenerationState({this.imageModel = 'DALL-E 3', this.imageStyle = 'Aucun', this.imageRatio = '1:1', this.videoModel = 'Runway Gen-3', this.videoDuration = '5s', this.videoRatio = '16:9', this.videoStyle = 'Réaliste'});
  final String imageModel, imageStyle, imageRatio, videoModel, videoDuration, videoRatio, videoStyle;
  GenerationState copyWith({String? imageModel, String? imageStyle, String? imageRatio, String? videoModel, String? videoDuration, String? videoRatio, String? videoStyle}) => GenerationState(
    imageModel: imageModel ?? this.imageModel, imageStyle: imageStyle ?? this.imageStyle, imageRatio: imageRatio ?? this.imageRatio,
    videoModel: videoModel ?? this.videoModel, videoDuration: videoDuration ?? this.videoDuration, videoRatio: videoRatio ?? this.videoRatio, videoStyle: videoStyle ?? this.videoStyle,
  );
}

class GenerationViewModel extends Notifier<GenerationState> {
  @override
  GenerationState build() => const GenerationState();
  void selectImageModel(String value) => state = state.copyWith(imageModel: value);
  void selectImageStyle(String value) => state = state.copyWith(imageStyle: value);
  void selectImageRatio(String value) => state = state.copyWith(imageRatio: value);
  void selectVideoModel(String value) => state = state.copyWith(videoModel: value);
  void selectVideoDuration(String value) => state = state.copyWith(videoDuration: value);
  void selectVideoRatio(String value) => state = state.copyWith(videoRatio: value);
  void selectVideoStyle(String value) => state = state.copyWith(videoStyle: value);
}

final generationViewModelProvider = NotifierProvider<GenerationViewModel, GenerationState>(GenerationViewModel.new);
