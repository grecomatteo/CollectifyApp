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
    var senderIDBytes = utf8.encode(senderID.toString());
    var senderNameBytes = utf8.encode(senderName);
    var receiverIDBytes = utf8.encode(receiverID.toString());
    var receiverNameBytes = utf8.encode(receiverName);
    var messageBytes = utf8.encode(message);
    var sendDateBytes = utf8.encode(sendDate.toString());

    //Return a list of all the compressed variables
    return [senderIDBytes, senderNameBytes, receiverIDBytes, receiverNameBytes, messageBytes, sendDateBytes];
  }

  factory Message.decompressObject(List<List<int>> compressedBytes) {

    var senderID = int.parse(utf8.decode(compressedBytes[0]));
    var senderName = utf8.decode(compressedBytes[1]);
    var receiverID = int.parse(utf8.decode(compressedBytes[2]));
    var receiverName = utf8.decode(compressedBytes[3]);
    var message = utf8.decode(compressedBytes[4]);
    var timeDifference = DateTime.now().timeZoneOffset;
    var sendDate = DateTime.parse(utf8.decode(compressedBytes[5])).add(Duration(hours: timeDifference.inHours));

    //Return the message
    return Message(senderID, senderName, receiverID, receiverName, message, sendDate);
  }
}