
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
  // TODO exp.
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Aux state using OSC. */
void sendAux(int value) {
  OscMessage myMessage = new OscMessage("/key");
  myMessage.add(0);
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Encoder event using OSC. */
void sendEncoderTurn(int value) {
  OscMessage myMessage = new OscMessage("/encoder/turn");
  myMessage.add(value);
  oscP5.send(myMessage, myRemoteLocation);
}

/** Send Encoder pressed event using OSC. */
void sendEncoderButton() {
  OscMessage myMessage = new OscMessage("/encoder/button");
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocation);
}
