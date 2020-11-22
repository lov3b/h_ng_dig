import javax.swing.JOptionPane;
// Max 15 karaktärer i varje ord, annars blir understräcken för långa
String[] ord = {"HUMAN", "TERMINANTE", "EXECUTE", "REVOLUTION", "KILL"};
boolean[] harBilvitTaget = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false};
String rVal;
int rValInt;
final int antalOrd = 5;
String anvandarValStr;
char anvandarVal;
boolean rValUdda;
final int startState = 1;
final int playState = 2;
final int gameoverState = 3;
final int winState = 4;
int mittenBokstav;
final int distansLangd = 30;
final int distansMellanrum = 20;
final int distansTot = distansLangd+distansMellanrum;
int state = startState;

// Images
PImage hill;
PImage sun;
PImage sky;

void setup() {
  size(800, 800);
  surface.setTitle("Häng Dig!");
  rValInt = int(random(0, antalOrd));
  //TEST
  //rValInt = 1;
  rVal = ord[rValInt];
  println(rVal);
  rectMode(CENTER);

  if (rVal.length() % 2 == 0) {
    rValUdda = false;
    mittenBokstav = rVal.length()/2;
  } else {
    rValUdda = true;
    mittenBokstav = int(rVal.length()/2)+1;
  }
  println(mittenBokstav);
  
  // Images
  hill = loadImage("hill.png");
  sun = loadImage("sun.png");
  sun.resize(120,101);
  sky = loadImage("sky.png");
}


// Fixa så att rektangeln ligger i centrum av den inmatade kordinaten
//int rectAlign(int input) {
//  int output=input-(distansLangd/2);
//  return output;
//}

// Divide word into single letters in an array.
String[] divideWord(String wordToDivide) {
  String[] ret = wordToDivide.split("");
  return ret;
}


// CURENT VERSION OF POSITONOFLETTER
int[] PositionOfLetter() {
  //String[] secretWordArrayFunction = divideWord(rVal);
  int antalBokstaver = rVal.length();

  int[] kordinaterForUnderstrack = new int[antalBokstaver];

  int mitten = (width/2);
  if (rValUdda) {
    kordinaterForUnderstrack[mittenBokstav-1] = mitten;
    //println("test: "+ str(mitten-(distansLangd/2)));
    println("test: "+ str(kordinaterForUnderstrack[mittenBokstav]));
    for (int i=1; i < mittenBokstav; i++) {

      kordinaterForUnderstrack[(mittenBokstav -1 - i)] = mitten-distansTot*i;
      kordinaterForUnderstrack[(mittenBokstav -1 + i)] = mitten+distansTot*i;
    }
  } else {
    for (int i=0; i < mittenBokstav; i++) {
      kordinaterForUnderstrack[mittenBokstav-1-i] = mitten-(distansTot/2)-(distansTot*i);
      kordinaterForUnderstrack[mittenBokstav+i] = mitten+(distansTot/2)+(distansTot*i);
      // TEST för utskrivning av bokstäver 
      //text("K", 375, (height/4)*3-20);
    }
  }
  //println(kordinaterForUnderstrack);
  return kordinaterForUnderstrack;
}


void draw() {
  switch(state) {
  case startState:
    drawStart();
    break;
  case playState:
    drawPlay();
    break;
  case gameoverState:
    drawGameover();
    break;
  case winState:
    drawWin();
    break;
  }
}

void drawUnderstrack() {
  int[] understrackKordinat = PositionOfLetter();
  for (int i=0; i < rVal.length(); i++) {
    rect(understrackKordinat[i], (height/4)*3, distansLangd, height*0.005);
    println(understrackKordinat[i]);
  }
}

void drawStart() {
  textSize(20);
  textAlign(CENTER, CENTER);
  background(0);
  fill(0, 255, 0);
  text("Välkommen till 'Häng Dig'\nGissa på en bokstav i popuprutan\n"+
    "Starta genom att klicka på fönstret eller tryck på valfri tangent", width/2, height/2);
  if (mousePressed||keyPressed) {
    state=playState;
  }
}
void drawPlay() {
  background(0,255,0);
  //image(sky,0,0);
  image(hill,(width/2)-512/2,200);
  image(sun,width-120,0);
  noStroke();
  fill(255, 0, 0);
  drawUnderstrack();
  println(PositionOfLetter());
  String[] secretWordArray = divideWord(rVal);
  println("NUMMER 3: "+secretWordArray[2]);
   anvandarValStr = JOptionPane.showInputDialog("Skriv en bokstav");

  anvandarVal = anvandarValStr.toUpperCase().charAt(0);
  for (int i=0; i < rVal.length(); i++) {
    //println("Använderval: " +"." +anvandarVal+".");
    //println("Hemliga ordet: " + "."+secretWordArray[i]+".");


    if (secretWordArray[i].charAt(0) == anvandarVal && harBilvitTaget[i] == false) {
      println(i);
      harBilvitTaget[i] = true;
      
    }
  }
  int[] understrackKordinater = PositionOfLetter();
  for(int i=0; i < rVal.length(); i++){
     if(harBilvitTaget[i]){
        text(""+secretWordArray[i],float(understrackKordinater[i]),(height/4.0)*3-height*0.02125);
     }
     
  }
  
}

void drawGameover() {
  background(255, 0, 0);
  textSize(20);
  textAlign(CENTER, CENTER);
  background(0);
  text("GAME OVER!\n"+
    "Starta om genom att klicka på fönstret, eller tryck på valfri tangent", width/2, height/2);
  if (mousePressed||keyPressed) {
    state=playState;
  }
}

void drawWin() {
  background(0, 255, 255);
  textSize(20);
  textAlign(CENTER, CENTER);
  background(0);
  text("Du vann!\n"+
    "Starta om genom att klicka på fönstret, eller tryck på valfri tangent", width/2, height/2);
  if (mousePressed||keyPressed) {
    state=playState;
  }
}
