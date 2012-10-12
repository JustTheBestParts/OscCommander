import oscP5.*;
import netP5.*;

OscP5 clientOscP5;

NetAddress oscServerAddress;

final static int UNKNOWN = -1;
final static int STRING  = 0;
final static int INTEGER = 1;
final static int FLOAT   = 2;
final static int TRUE    = 4;
final static int FALSE   = 8;

String  textRegex        = "(\")(.+)(\")";
java.util.regex.Pattern isTextPattern    = java.util.regex.Pattern.compile(textRegex);
java.util.regex.Pattern isIntPattern     = java.util.regex.Pattern.compile("^[0-9]+$");
java.util.regex.Pattern isFloatPattern   = java.util.regex.Pattern.compile("^[0-9\\.]+$");
java.util.regex.Pattern isBooleanPattern = java.util.regex.Pattern.compile("^[TFtf]");



void createOscStuff(){
  oscServerAddress = new NetAddress(serverAddressText.getText(), int(serverPortText.getText()) );
  clientOscP5 = new OscP5(this, int(trim(clientPortText.getText())) );
  println("clientOscP5 =" + clientOscP5.properties().toString() );
}

void oscEvent(OscMessage oscMessage) {
  println("* * *  OSC Commander received a message * * * ");
  print(" addrpattern: " + oscMessage.addrPattern());
  println("; typetag: " + oscMessage.typetag());

  String value = "";

  for (int i = 0; i < oscMessage.arguments().length; i++ ) {
    if (oscMessage.typetag().charAt(i) == 's' ) {
      value += "\"" + oscMessage.arguments()[i].toString() + "\" ";
    } else {
      value += oscMessage.arguments()[i].toString() + " ";
    }
  }
  oscResponseText.setText( oscMessage.addrPattern() + " " + trim(value) );  
}

String removeWrappingQuotes(String arg) {
  return( match(arg, textRegex)[2] );
}

void sendOSC(){

  println("client port: "+ int(clientPortText.getText())  );
  println("Send OSC message " +  trim(oscCommandText.getText() ));

  oscResponseText.setText("");  

  String rawMessageText = trim(oscCommandText.getText() );
  String[] messageParts = stringToArgs(rawMessageText);

  OscMessage m = new OscMessage(trim(messageParts[0]));

  String arg;

  for(int i=1; i < messageParts.length; i++) {
    arg = trim(messageParts[i]);
    switch ( getDataType( arg ) ) {
      case STRING:
        arg = removeWrappingQuotes(arg);
        m.add(arg); 
        println("Text: " + arg );     
        break;

      case INTEGER:
        m.add(int(arg)); 
        println("Int: " + arg );     
        break;

      case FLOAT:
        m.add(float(arg)); 
        println("Float: " + arg );     
        break;

      case TRUE:
        m.add(true); 
        println("TRUE: " + arg );     
        break;

      case FALSE:
        m.add(false); 
        println("FALSE: " + arg );     
        break;

      case UNKNOWN:
        println("Unknown!: " + arg);   
        break;

    } 
  } 
  println("Send message to " +  oscServerAddress );
  clientOscP5.send(m, oscServerAddress); 
}


int getDataType( String arg ) {

  java.util.regex.Matcher ma = isTextPattern.matcher(arg);   
  if (ma.find()) {
    return STRING;
  } else {

    println("   not text ...");
    ma = isIntPattern.matcher(arg);  
    if (ma.find()) {
      println("Integer: " + int(ma.group()) );     
      return INTEGER;
    } else {

      println("   not int ...");
      ma = isFloatPattern.matcher(arg);  
      if (ma.find()) {
        println("Float: " + float(ma.group()) );     
        return FLOAT;
      } else {

        println("   not float ...");
        ma = isBooleanPattern.matcher(arg);  
        if (ma.find()) {
          println("   Boolean? ...");
          if ( ma.group().toLowerCase().equals("t") ) { 

            println("Boolean: t" );      
            return TRUE;
          }
          if (ma.group().toLowerCase().equals("f") ) { 

            println("Boolean: f");     
            return FALSE;
          }
        } else { 

          println("Unknown!: " + arg);   
          return UNKNOWN;
        }
      }
    }
  }
  return UNKNOWN;
}

void sendSliderOscValue(String addressPattern, float value ){
  OscMessage m = new OscMessage(addressPattern);
  m.add( value );   
  println("Send to " + oscServerAddress + ": " + addressPattern + " " + value );
  clientOscP5.send(m, oscServerAddress); 
}

  
// Since the config file is just an ordered sequence of lines of text 
// we need to follow this load/save convention:
// server addy
// server port
// client addy
// client port
// osc message


void remakeOscStuf() {
  clientOscP5.dispose();
  createOscStuff();
}



