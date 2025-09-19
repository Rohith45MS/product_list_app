// import 'package:dio/dio.dart';
// import 'api_constants.dart';
//
// class ApiClient {
//   static final ApiClient _instance = ApiClient._internal();
//   factory ApiClient() => _instance;
//   ApiClient._internal();
//
//   late Dio _dio;
//
//   void init() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseUrl,
//         headers: ApiConstants.defaultHeaders,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//       ),
//     );
//
//     // Add interceptors for logging
//     _dio.interceptors.add(
//       LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//         logPrint: (obj) => print('DIO: $obj'),
//       ),
//     );
//
//     // Add response interceptor for debugging
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onResponse: (response, handler) {
//           print('API Response Type: ${response.data.runtimeType}');
//           print('API Response Data: ${response.data}');
//           handler.next(response);
//         },
//       ),
//     );
//   }
//
//   Dio get dio => _dio;
// }
