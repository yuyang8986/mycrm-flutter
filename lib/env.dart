const testConfig = {
  'baseUrl': 'https://mycrmapi.azurewebsites.net/api/',
  "tokenEndpoint": "https://mycrmidentity.azurewebsites.net/connect/token",
  //'baseUrl': 'http://10.0.2.2:5001/api/',
  //"tokenEndpoint": "http://10.0.2.2:5000/connect/token"
    //'baseUrl': 'http://192.168.1.8:5001/api/',
  //"tokenEndpoint": "http://192.168.1.8:5000/connect/token"
};

const productionConfig = {
  'baseUrl': 'https://mycrmapi.azurewebsites.net/api/',
  "tokenEndpoint": "https://mycrmidentity.azurewebsites.net/connect/token"
};
final bool isProduction = bool.fromEnvironment('dart.vm.product');

final environment = isProduction ? productionConfig : testConfig;
