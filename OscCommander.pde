//  OSC Commander
//  OSC testing tool, from the book Just the Best Parts: OSC for Artists, by James Britt
//  http://www.justthebestparts.com/books/osc/
//  James Britt / james@neureogami.com
//  See README.txt for license and copyright
import guicomponents.*;


GLabel serverAddressLabel, serverPortLabel, clientPortLabel;
GTextField serverAddressText, serverPortText, clientPortText;
GTextField oscCommandText, oscResponseText;
GLabel     headerLabel, oscResponse, helpText;

GButton updateDataButton, sendOscButton;

GOptionGroup sliderOptGroup;
GOption sliderOptFader, sliderOptRotary;

String sliderScreenPattern = "/1";
String sliderPattern = "/fader";
String configFile = "config.txt";



int canvasWidth =  600;
int canvasHeight = 680;

class NGSlider extends GWSlider {

  private int index = -1; 

  NGSlider(PApplet owner, int x, int y, int w ){
    super(owner, x, y,  w);
  }

  NGSlider(PApplet owner, int x, int y, int w, int i ){
    super(owner, x, y,  w);
    index = i;
  }

  int index(){
    return index;
  }

  void index(int i){
    index = i;
  }
}


void setup() {
  background(255);
  buildUI(); 
  loadData();
  createOscStuff();
}


void draw() {
  background(255);
}


void handleSliderEvents(GSlider slider) {
  NGSlider s = (NGSlider) slider;
  String addressPattern = sliderScreenPattern + sliderPattern + s.index();
  sendSliderOscValue(addressPattern, s.getValuef() );
}

void buildUI() {

  GComponent.globalColor = GCScheme.getColor(this,  GCScheme.GREY_SCHEME);

  size(canvasWidth, canvasHeight);

  int defaultIndentation = 10;
  int charSize           = 6;
  int defaultGap         = charSize;
  int addressLabelWidth  = 100;
  int portLabelWidth     = 80;
  int addressTextWidth   = 80;
  int portTextWidth      = 40;
  int basicHeight        = 16;
  int offsetHeight       = 8;

  int x, x2, x3, x4, y;

  int oscCommandTextWidth = width - defaultIndentation*2;
  int oscCommandLabelWidth = addressLabelWidth;


  x = defaultIndentation;
  y = 10;


  headerLabel = new GLabel(this, "Just the Best Parts: OSC for Artists - www.justthebestparts.com", 0, y, canvasWidth-150, basicHeight);

  headerLabel.setFont("Arial", 18);
  headerLabel.setTextAlign(GAlign.CENTER);

//  G4P.setFont(this, "Arial", 14);
  y = y + basicHeight + 30;

  serverAddressLabel = new GLabel(this, "Server address:", x, y, addressLabelWidth, basicHeight);
  x = x + addressLabelWidth + defaultGap;
  serverAddressText = new GTextField(this, "", x, y, addressTextWidth, basicHeight, true);
  
  x = x + addressTextWidth + (defaultGap*3);
    
  serverPortLabel = new GLabel(this, "Server port:", x, y, ("Server port:".length()*charSize), basicHeight);
  x = x + portLabelWidth + defaultGap;
  serverPortText = new GTextField(this, "", x, y, portTextWidth, basicHeight, true);


  x = x + portTextWidth + defaultGap +  + (defaultGap*3);
  clientPortLabel = new GLabel(this, "Client port:", x, y, ("Client port:".length()*charSize), basicHeight);
  x = x + portLabelWidth + defaultGap;
  clientPortText = new GTextField(this, "", x, y, portTextWidth, basicHeight, true);

  x = defaultIndentation;
  y = y + offsetHeight + offsetHeight + offsetHeight + basicHeight;

  x2 = x  + oscCommandLabelWidth + 10;

  GLabel oscCommandLabel = new GLabel(this, "OSC message", x, y, oscCommandLabelWidth, basicHeight);

  y = y + offsetHeight + basicHeight;

  oscCommandText = new GTextField(this, "", x, y, oscCommandTextWidth, basicHeight, true);

  y = y + offsetHeight + offsetHeight + offsetHeight + basicHeight;

  sendOscButton = new GButton(this, "Send ", x, y, 60, basicHeight);

  updateDataButton = new GButton(this, "Update ", canvasWidth - 90, y, 70, basicHeight);

  for(int i = 1; i< 6; i++){
    y = y + offsetHeight + basicHeight*3;
    NGSlider oscFader = new NGSlider(this, x+10, y, width - 50, i);
    oscFader.setValueType(GWSlider.DECIMAL);
    oscFader.setLimits(0.5f, 0f, 1.0f);
    oscFader.setPrecision(3);
    oscFader.setValue(0.0f);
  }

  y = y + offsetHeight + offsetHeight + offsetHeight + basicHeight;

  sliderOptGroup = new GOptionGroup();
  sliderOptFader = new GOption(this, "Fader", x, y, 50);
  sliderOptRotary = new GOption(this, "Rotary", x+100, y, 50);
  sliderOptGroup.addOption(sliderOptFader);
  sliderOptGroup.addOption(sliderOptRotary);
  sliderOptGroup.setSelected(sliderOptFader);

  y = y + offsetHeight + offsetHeight + offsetHeight + basicHeight;
  oscResponse = new GLabel(this, "OSC response", x, y, oscCommandTextWidth, basicHeight);

  y = y + offsetHeight + basicHeight;
  oscResponseText = new GTextField(this, "", x, y, oscCommandTextWidth, basicHeight, true);

  String help = "You can pass four kinds of arguments to OSC messages: Strings, integers, floating point, and Boolean.  ";
  help = help + "All string arguments must be in quotes.  Use the characters T and F to indicate true and false Boolean values.";
  helpText = new GLabel(this, help, x, y, int((help.length()) * (charSize/2.7)), 100);
  helpText.setFont("Arial", 14);

}

void handleOptionEvents(GOption selected, GOption deselected) {
  if (selected == sliderOptRotary) {
    sliderPattern = "/rotary";
  }

  if (selected == sliderOptFader) {
    sliderPattern = "/fader";
  }
}

void handleButtonEvents(GButton button) {
  if ( button == updateDataButton ) { updateData(); }
  if ( button == sendOscButton )  { sendOSC();  }
}

/*
   We get a string that, mostly, is space-delimited.
   But it may have some quoted text, and we need to treat all the text in quotes
   as one chunk.


   For example, given

   12 T "Some    text!"  2  "Here is more text"

   we want to return an array of strings:

   [  "12", "T", "Some,    text!",  "2",  "Here is more text"]


 */
String[] stringToArgs(String s){

  Boolean inText = false;
  String[] new_s = {""};
  int new_s_size = new_s.length;
  char[] s_chars = new char[s.length()];

  s.getChars(0, s_chars.length, s_chars, 0);

  for(char letter : s_chars) {
    println("******* letter: " + letter );
    if( letter == '"' ) {
      println("---- Have a \" !  inText was " + inText );

      inText = !inText; 
      new_s_size = new_s.length;
      new_s[new_s_size-1] =  new_s[new_s_size-1]  + letter;
      println("---- inText now " + inText );

    } else {
      if ( letter == ' '  && !inText ) {
        if (!new_s[new_s.length-1].equals("") ) {
          new_s = append(new_s, "");
        }
      } else {
        println("  Append " + letter );
        new_s_size = new_s.length;
        new_s[new_s_size-1] =  new_s[new_s_size-1]  + letter;
      }
    }
  }
  println("new_s size = " + new_s.length);
  return new_s;
}


void updateData(){

  String text = "";

  text =  trim(clientPortText.getText()) + "\n"; 
  text = text + trim(serverAddressText.getText()) + ":"; 
  text = text + trim(serverPortText.getText()) + "\n"; 
  text = text + trim(oscCommandText.getText()); 

  String[] data = split(text, "\n");

  remakeOscStuf();

  try {
    saveStrings(configFile, data);
  } catch(Exception e) {
    println("Error saving data to '" + configFile + "'");
    e.printStackTrace();
  }

}

void loadData(){
  String defaultValues[] = split("127.0.0.1:8000\n127.0.0.1:8080\n/some/address/pattern 123, \"SOme text\" 3.1415", "\n");
  try {
    String lines[] = loadStrings(configFile);

    for (int i=0; i < lines.length; i++) { defaultValues[i] =  lines[i]; }

    int i = 0;

    String[] parts = split(defaultValues[i], ":");

    // clientAddressText.setText(trim(parts[0]) );
    clientPortText.setText(trim(parts[1]) );   
    i++;

    parts = split(defaultValues[i], ":");

    serverAddressText.setText(trim(parts[0]) );
    serverPortText.setText(trim(parts[1]) );

    i++;

    oscCommandText.setText(trim(defaultValues[i]));
  } catch(Exception e) {
    println("Error loading data from '" + configFile + "'");
    e.printStackTrace();
  }

}


