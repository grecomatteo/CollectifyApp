class Message {
  final int senderID;
  final int receiverID;
  final String message;
  final DateTime sendDate;

  Message(this.senderID, this.receiverID, this.message, this.sendDate);

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'sendDate': sendDate,
    };
  }

  @override
  String toString() {
    return 'Message{senderID: $senderID, receiverID: $receiverID, message: $message, sendDate: $sendDate}';
  }
}