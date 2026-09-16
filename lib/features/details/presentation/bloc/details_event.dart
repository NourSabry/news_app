import 'package:equatable/equatable.dart';

sealed class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticle extends DetailsEvent {
  const LoadArticle();
}
