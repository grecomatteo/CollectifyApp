class Message {
  final int senderID;
  final String senderName;
  final int receiverID;
  final String receiverName;
  final String message;
  final DateTime sendDate;

  Message(this.senderID, this.senderName, this.receiverID, this.receiverName, this.message, this.sendDate);

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderName': senderName,
      'receiverID': receiverID,
      'receiverName': receiverName,
      'message': message,
      'sendDate': sendDate,
    };
  }

  @override
  String toString() {
    return 'Message{senderID: $senderID, senderName: $senderName, receiverID: $receiverID, receiverName: $receiverName, message: $message, sendDate: $sendDate}';
  }
}