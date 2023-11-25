import 'package:flutter/material.dart';

Widget buildFutureBuilder(List<Future<dynamic>> futures, Widget Function(List<dynamic>) builder) {
  return FutureBuilder(
    // 传入Future列表
    future: Future.wait(futures),
    // 构建页面的回调
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      return _handleSnapshot(snapshot, builder);
    },
  );
}

Widget _handleSnapshot(AsyncSnapshot<List<dynamic>> snapshot, Widget Function(List<dynamic>) builder) {
  // 当重新触发FutureBuilder时，虽然snapshot.connectionState会变为waiting，但是snapshot中的数据不会消失，所以hasData为true，因此要先判断状态再判断是否有数据或错误
  if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  } else if (snapshot.connectionState == ConnectionState.done) {
    if (snapshot.hasData) {
      // 数据准备完成，构建页面
      final dataList = snapshot.data!;
      return builder(dataList);
    } else {
      // 数据准备完成，但是没有数据
      return const Center(
        child: Text('Not Found Data'),
      );
    }
  } else if (snapshot.hasError) {
    // 如果发生错误，显示错误信息
    return Center(
      child: Text('Error: ${snapshot.error}'),
    );
  } else {
    // 如果发生未知错误，显示错误信息
    return const Center(
      child: Text('Unknown Error'),
    );
  }
}
