// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'Message.dart';

Map<Socket, int> sockets = {};
List<Message> messages = [];

void startServer() {
  //Create test messages
  messages.add(Message(1, "admin", 2, "user", "Test, sendDate: hola } message 1", DateTime.now()));
  messages.add(Message(2, "user", 1, "admin", "Test message 2", DateTime.now()));
  messages.add(Message(1, "admin", 2, "user", "Test message 3", DateTime.now()));
  messages.add(Message(2, "user", 1, "admin", "Test message 4", DateTime.now()));
  messages.add(Message(1, "admin", 2, "user", "Test message 5", DateTime.now()));
  messages.add(Message(2, "user", 1, "admin", "Test message 6", DateTime.now()));
  messages.add(Message(3, "Miguel", 1, "admin", "Test message 6", DateTime.now()));

  Future<ServerSocket> serverFuture = ServerSocket.bind('0.0.0.0', 55555);
  serverFuture.then((ServerSocket server) {
    server.listen((Socket socket) {
      socket.listen((List<int> data) {
        try {
          handleData(data, socket);
        } catch (e) {
          print(e);
        }
      });
    });
  });
}

void handleData(List<int> data, Socket socket) {
  String message = String.fromCharCodes(data).trim();
  //ConnectedUser:ID
  if (message.startsWith("ConnectedUser:")) {
    //Add the user with the given ID to the list of connected users
    var split = message.split(":");
    int userID = int.parse(split[1]);
    print("New user connected: $userID");
    sockets[socket] = userID;
    socket.write("ConnectedUser:$userID");
  } else if (message.startsWith("GetUsersWithCommunication:")) {
    //Get all users with communication with the user with the given ID
    var split = message.split(":");
    int userID = int.parse(split[1]);
    print("GetUsersWithCommunication: $userID");
    List<int> users = getUsersWithCommunication(userID);
    socket.write("UsersWithCommunication:${users.join(":")}");
  } else if (message.startsWith("GetLastMessage:")) {
    print(message + "\n");
    //Get all messages between the two users with the given IDs
    var split = message.split(":");
    int userID1 = int.parse(split[1]);
    List<int> userIDs = [];
    for (int i = 2; i < split.length; i++) {
      userIDs.add(int.parse(split[i]));
    }
    List<List<int>> messageList = [];
    for (int i = 0; i < userIDs.length; i++) {
      messageList.addAll(getLastMessage(userID1, userIDs[i]));
    }
    socket.write("LastMessage:${messageList.join(";")}");
  } else if (message.startsWith("GetMessages:")) {
    //Get all messages between the two users with the given IDs
    var split = message.split(":");
    int userID1 = int.parse(split[1]);
    List<int> userIDs = [];
    for (int i = 2; i < split.length; i++) {
      userIDs.add(int.parse(split[i]));
    }
    List<List<List<int>>> messageList = [];
    for (int i = 0; i < userIDs.length; i++) {
      messageList.addAll(getMessages(userID1, userIDs[i]));
    }
    socket.write("Messages:${messageList.join(";")}");
  } else if (message.startsWith("DisconnectedUser:")) {
    //Remove the user with the given ID from the list of connected users
    var split = message.split(":");
    int userID = int.parse(split[1]);
    print("User disconnected: " + sockets.length.toString());
    sockets.removeWhere((key, value) => value == userID);
  }
}

List<int> getUsersWithCommunication(int userID) {
  List<int> users = [];
  for (int i = 0; i < messages.length; i++) {
    if (messages[i].senderID == userID) {
      users.add(messages[i].receiverID);
    } else if (messages[i].receiverID == userID) {
      users.add(messages[i].senderID);
    }
  }
  return users;
}

List<List<List<int>>> getMessages(int userID1, int userID2) {
  List<List<List<int>>> compressedMessages = [];
  for (int i = 0; i < messages.length; i++) {
    if ((messages[i].senderID == userID1 && messages[i].receiverID == userID2) ||
        (messages[i].senderID == userID2 && messages[i].receiverID == userID1)) {
      compressedMessages.add(messages[i].compressObject());
    }
  }

  return compressedMessages;
}

List<List<int>> getLastMessage(int userID1, int userID2) {
  List<List<List<int>>> compressedMessages = [];
  //Get the last messages between the two users
  for (int i = 0; i < messages.length; i++) {
    if ((messages[i].senderID == userID1 && messages[i].receiverID == userID2) ||
        (messages[i].senderID == userID2 && messages[i].receiverID == userID1)) {
      compressedMessages.add(messages[i].compressObject());
    }
  }

  //Sort the messages by date
  compressedMessages.sort((a, b) {
    DateTime dateA = Message.decompressObject(a).sendDate;
    DateTime dateB = Message.decompressObject(b).sendDate;
    return dateA.compareTo(dateB);
  });

  //Get the last message
  List<List<int>> lastMessage = compressedMessages[compressedMessages.length - 1];



  return lastMessage;
}

void main() {
  startServer();
}