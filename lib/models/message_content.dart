class MessageContent {
  final String? text;
  final String? imagePath;
  final String? filePath;
  final String? fileMimeType;

  const MessageContent({this.text, this.imagePath, this.filePath, this.fileMimeType});

  bool get isText => text != null;
  bool get isImage => imagePath != null;
  bool get isFile => filePath != null;
  bool get isMultimodal => (text != null ? 1 : 0) + (imagePath != null ? 1 : 0) + (filePath != null ? 1 : 0) > 1;

  factory MessageContent.text(String text) => MessageContent(text: text);
  factory MessageContent.image(String path) => MessageContent(imagePath: path);
  factory MessageContent.file(String path, String mime) => MessageContent(filePath: path, fileMimeType: mime);

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (imagePath != null) 'image_path': imagePath,
        if (filePath != null) 'file_path': filePath,
        if (fileMimeType != null) 'file_mime': fileMimeType,
      };
}
