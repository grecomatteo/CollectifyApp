import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

class Message {
  final int senderID;
  final String senderName;
  final int receiverID;
  final String receiverName;
  final String message;
  final DateTime sendDate;

  Message(this.senderID, this.senderName, this.receiverID, this.receiverName, this.message, this.sendDate);

  List<List<int>> compressObject() {
    //Encode each variable separately
    final senderIDBytes = utf8.encode(senderID.toString());
    final senderNameBytes = utf8.encode(senderName);
    final receiverIDBytes = utf8.encode(receiverID.toString());
    final receiverNameBytes = utf8.encode(receiverName);
    final messageBytes = utf8.encode(message);
    final sendDateBytes = utf8.encode(sendDate.toString());

    //Return a list of all the compressed variables
    return [senderIDBytes, senderNameBytes, receiverIDBytes, receiverNameBytes, messageBytes, sendDateBytes];
  }

  factory Message.decompressObject(List<List<int>> compressedBytes) {

    final senderID = int.parse(utf8.decode(compressedBytes[0]));
    final senderName = utf8.decode(compressedBytes[1]);
    final receiverID = int.parse(utf8.decode(compressedBytes[2]));
    final receiverName = utf8.decode(compressedBytes[3]);
    final message = utf8.decode(compressedBytes[4]);
    final sendDate = DateTime.parse(utf8.decode(compressedBytes[5]));

    //Return the message
    return Message(senderID, senderName, receiverID, receiverName, message, sendDate);
  }
}