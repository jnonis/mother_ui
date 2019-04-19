
/** Send load patch using OSC. */
void sendLoadPatch(String patch) {
  OscMessage myMessage = new OscMessage("/loadpatch");
  myMessage.add(patch);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Knobs state using OSC. */
void sendKnobs() {
  OscMessage myMessage = new OscMessage("/knobs");
  myMessage.add(knob1.getValueI());
  myMessage.add(knob2.getValueI());
  myMessage.add(knob3.getValueI());
  myMessage.add(knob4.getValueI());
  myMessage.add(volume.getValueI());
  myMessage.add(expr.getValueI());
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Aux state using OSC. */
void sendAux(int value) {
  println("Send AUX: " + value);
  OscMessage myMessage = new OscMessage("/key");
  myMessage.add(0);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send FS state using OSC. */
void sendFs(int value) {
  println("Send FS: " + value);
  OscMessage myMessage = new OscMessage("/fs");
  myMessage.add(100 - value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Encoder event using OSC. */
void sendEncoderTurn(int value) {
  OscMessage myMessage = new OscMessage("/encoder/turn");
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Encoder pressed event using OSC. */
void sendEncoderButton(int value) {
  OscMessage myMessage = new OscMessage("/encoder/button");
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send load state event using OSC. */
void sendLoad() {
  OscMessage myMessage = new OscMessage("/loadState");
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send save state event using OSC. */
void sendSave() {
  OscMessage myMessage = new OscMessage("/saveState");
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocation);
}
