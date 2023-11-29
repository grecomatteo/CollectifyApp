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

  @override
  String toString() {
    return 'Message{senderID: $senderID, senderName: $senderName, receiverID: $receiverID, receiverName: $receiverName, message: $message, sendDate: $sendDate}';
  }

  List<List<int>> compressObject() {
    //Encode each variable separately
    final codec = utf8.fuse(zlib);
    final senderIDBytes = Uint8List.fromList(codec.encode(this.senderID.toString()));
    final senderNameBytes = Uint8List.fromList(codec.encode(this.senderName));
    final receiverIDBytes = Uint8List.fromList(codec.encode(this.receiverID.toString()));
    final receiverNameBytes = Uint8List.fromList(codec.encode(this.receiverName));
    final messageBytes = Uint8List.fromList(codec.encode(this.message));
    final sendDateBytes = Uint8List.fromList(codec.encode(this.sendDate.toString()));

    //Compress each variable separately
    final senderIDCompressedBytes = zlib.encode(senderIDBytes);
    final senderNameCompressedBytes = zlib.encode(senderNameBytes);
    final receiverIDCompressedBytes = zlib.encode(receiverIDBytes);
    final receiverNameCompressedBytes = zlib.encode(receiverNameBytes);
    final messageCompressedBytes = zlib.encode(messageBytes);
    final sendDateCompressedBytes = zlib.encode(sendDateBytes);

    //Return a list of all the compressed variables
    return [senderIDCompressedBytes, senderNameCompressedBytes, receiverIDCompressedBytes, receiverNameCompressedBytes, messageCompressedBytes, sendDateCompressedBytes];
  }

  factory Message.decompressObject(List<List<int>> compressedBytes) {
    //Decompress each variable separately
    final senderIDDecompressedBytes = zlib.decode(compressedBytes[0]);
    final senderNameDecompressedBytes = zlib.decode(compressedBytes[1]);
    final receiverIDDecompressedBytes = zlib.decode(compressedBytes[2]);
    final receiverNameDecompressedBytes = zlib.decode(compressedBytes[3]);
    final messageDecompressedBytes = zlib.decode(compressedBytes[4]);
    final sendDateDecompressedBytes = zlib.decode(compressedBytes[5]);

    //Decode each variable separately
    final codec = utf8.fuse(zlib);
    final senderID = int.parse(codec.decode(senderIDDecompressedBytes));
    final senderName = codec.decode(senderNameDecompressedBytes);
    final receiverID = int.parse(codec.decode(receiverIDDecompressedBytes));
    final receiverName = codec.decode(receiverNameDecompressedBytes);
    final message = codec.decode(messageDecompressedBytes);
    final sendDate = DateTime.parse(codec.decode(sendDateDecompressedBytes));

    //Return the message
    return Message(senderID, senderName, receiverID, receiverName, message, sendDate);
  }
}