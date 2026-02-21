import 'package:equatable/equatable.dart';

class MediaFileEntity extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final String disk;
  final String fileName;
  final String imageUrl;
  final String originalUrl;

  const MediaFileEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.disk,
    required this.fileName,
    required this.imageUrl,
    required this.originalUrl,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    disk,
    fileName,
    imageUrl,
    originalUrl,
  ];

  @override
  String toString() {
    return 'MediaFileEntity(id: $id, uuid: $uuid, name: $name, disk: $disk, fileName: $fileName, imageUrl: $imageUrl, originalUrl: $originalUrl)';
  }
}
