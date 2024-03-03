import 'package:teledart/teledart.dart';
//import 'package:teledart/telegram.dart';
//https://pub.dev/packages/teledart

class teledartService {
  static late TeleDart teledart;

  void initTeledart() {
    //bot token id and telegram user name, obtained from t.me/botfather
    var teledart = TeleDart('6769249691:AAGd7KPTTR-lz5BZLMEfGiLUunNpL2M0fDo',
        Event('ibdp_cs_restaurant_bot'));
    teledart.start();
    setTeledart(teledart);
    ///if /id, /ID, or /Id is sent in a chat with this bot added, it will respond with the chat id
    ///this is necessary to tell the bot where to send the messages to
    ///this is only for private groups, if you want to use this with a channel then you have
    /// to find the chat id through a different way. i found mine by forwarding a message from
    /// the public channel to @jsondumpbot
    teledart.onMessage(entityType: 'bot_command', keyword: 'ID').listen(
        (message) =>
            teledart.sendMessage(message.chat.id, message.chat.id.toString()));
    teledart.onMessage(entityType: 'bot_command', keyword: 'id').listen(
        (message) =>
            teledart.sendMessage(message.chat.id, message.chat.id.toString()));
    teledart.onMessage(entityType: 'bot_command', keyword: 'Id').listen(
        (message) =>
            teledart.sendMessage(message.chat.id, message.chat.id.toString()));
  }

  void setTeledart(TeleDart inputTeledart) {
    teledart = inputTeledart;
  }

  TeleDart getTeledart() {
    return teledart;
  }

  //make sure the bot has permission to send messages to the person/group/channel!

  void sendTelegramMessageWaiter(String inputMessage) {
    TeleDart teledartObtained = teledartService().getTeledart();
    teledartObtained.sendMessage(-1001941628765, inputMessage);
    //join at https://t.me/waiter_ibdp_restaurant
  }

  void sendTelegramMessagePreparer(String inputMessage) {
    TeleDart teledartObtained = teledartService().getTeledart();
    teledartObtained.sendMessage(-1002020806232, inputMessage);
    //join at https://t.me/preparer_ibdp_restautant
  }
}
