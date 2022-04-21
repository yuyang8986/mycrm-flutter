class ResponseDto<T>
{
  bool isSuccess;
  String message;
  T data;
  Exception e;

  ResponseDto(this.isSuccess, this.message,this.data, this.e);
}