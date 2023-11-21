// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';


Future<void> main() async {
  ServerSocket server = await ServerSocket.bind('localhost', 4567);
  print('Listening on localhost:${server.port}');
  await for (Socket socket in server) {
    socket.write('Hello, World!\n');
    await socket.close();
  }
}