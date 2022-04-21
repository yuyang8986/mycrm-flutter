class FileItemDto{
  String name;
  String url;

FileItemDto(
  {
    this.name,
    this.url,
});

factory FileItemDto.fromJson(Map<String, dynamic> json) => new FileItemDto(
    name: json["name"],
    url: json["url"]
);
}