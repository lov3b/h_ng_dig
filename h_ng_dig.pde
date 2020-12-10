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

// Användarfel
boolean gissatRatt=false;
int felGissningar = 0;

//Färger
final color rod = color(255, 0, 0);
final color gron = color(0, 255, 0);
final color bla = color(0, 0, 255);
final color turkos = color(0, 255, 255);
final color svart = color(0);

// Images
// En array över de olika bilderna för olika stadier i användarens fel. Den sissta är en dummy bild.
PImage[] kulle = new PImage[9];
PImage sun;

void setup() {
  size(800, 800);
  surface.setTitle("Häng Dig!");
  //Bestäm ett slumpmässigt ord från ordarrayen
  rValInt = int(random(0, antalOrd));
  rVal = ord[rValInt];
  println(rVal);

  rectMode(CENTER);
  // Kolla ifall ordet är udda eller jämnt antal karaktärer
  if (rVal.length() % 2 == 0) {
    rValUdda = false;
    mittenBokstav = rVal.length()/2;
  } else {
    rValUdda = true;
    mittenBokstav = int(rVal.length()/2)+1;
  }
  println(mittenBokstav);

  // Images
  for (int i=0; i < 9; i++) {
    kulle[i] = loadImage("Kulle"+i+".png");
  }
  sun = loadImage("sun.png");
  sun.resize(120, 101);

  //Resize
  for (int i=0; i < 8; i++) {
    kulle[i].resize(2554/2, 1216/2);
  }
}

// Dela det valda ordet in till enstaka bokstaver i en array.
String[] divideWord(String wordToDivide) {
  String[] ret = wordToDivide.split("");
  return ret;
}

// Återvänder en array där "understräcken" ska vara för det hemliga ordet
int[] PositionOfLetter() {
  int antalBokstaver = rVal.length();
  int[] kordinaterForUnderstrack = new int[antalBokstaver];
  int mitten = (width/2);
  if (rValUdda) {
    kordinaterForUnderstrack[mittenBokstav-1] = mitten;
    println("test: "+ str(kordinaterForUnderstrack[mittenBokstav]));
    for (int i=1; i < mittenBokstav; i++) {
      kordinaterForUnderstrack[(mittenBokstav -1 - i)] = mitten-distansTot*i;
      kordinaterForUnderstrack[(mittenBokstav -1 + i)] = mitten+distansTot*i;
    }
  } else {
    for (int i=0; i < mittenBokstav; i++) {
      kordinaterForUnderstrack[mittenBokstav-1-i] = mitten-(distansTot/2)-(distansTot*i);
      kordinaterForUnderstrack[mittenBokstav+i] = mitten+(distansTot/2)+(distansTot*i);
    }
  }
  return kordinaterForUnderstrack;
}

//void skrivutFails() {
//  switch(felGissningar) {
//    case 1
//  }

void draw() {
  // Ett switch statement som gör det möjligt med olika playstates. 
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

// Funktion för att skriva ut understräcken
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
  fill(gron);
  text("Välkommen till 'Häng Dig'\nGissa på en bokstav i popuprutan\n"+
    "Starta genom att klicka på fönstret eller tryck på valfri tangent", width/2, height/2);
  // Byt playstate ifall en knapp trycks ner
  if (mousePressed||keyPressed) {
    state=playState;
  }
}
void drawPlay() {
  background(gron);
  image(kulle[felGissningar], 80, 0);
  image(sun, width-120, 0);
  if (felGissningar >= 7) {
    state=gameoverState;
  }

  noStroke();
  fill(rod);
  drawUnderstrack();
  println(PositionOfLetter());
  //Hämta in det hemliga ordet som en array med en bokstav i varje plats.
  String[] secretWordArray = divideWord(rVal);
  println("NUMMER 3: "+secretWordArray[2]);

  // ANTECKNING TILL MIG SJÄLV
  // Fixa så att det inte blir NullPointerException error när man trycker på cancel. 
  anvandarValStr = JOptionPane.showInputDialog("Skriv en bokstav");
  anvandarVal = anvandarValStr.toUpperCase().charAt(0);

  // Loopa igenom alla bokstäver i det hemliga ordet och ändra harBlivitTaget till true ifall användaren gissade rätt. 
  for (int i=0; i < rVal.length(); i++) {
    if (secretWordArray[i].charAt(0) == anvandarVal && harBilvitTaget[i] == false) {
      println(i);
      harBilvitTaget[i] = true;
      gissatRatt=true;
    }
  }

  // Höj en counter ifall användaren har gissat fel, annars så sätts gessatRatt till false så att det funkar att loopa igenom blocket ovan igen. 
  if (gissatRatt == false) {
    felGissningar +=1;
  } else {
    gissatRatt = false;
  }
  println("felgissningar: "+ felGissningar);

  // Stycket kod skriver ut de bokstäverna som användaren har gissat rätt i det hemliga ordet. 
  int[] understrackKordinater = PositionOfLetter();
  for (int i=0; i < rVal.length(); i++) {
    if (harBilvitTaget[i]) {
      text(""+secretWordArray[i], float(understrackKordinater[i]), (height/4.0)*3-height*0.02125);
    }
  }
}

void drawGameover() {
  background(rod);
  image(kulle[7], 80, 0);
  fill(svart);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("GAME OVER!\n"+
    "Starta om genom att klicka på fönstret, eller tryck på valfri tangent", width/2, height-height/3.5);
  if (mousePressed||keyPressed) {
    felGissningar =0;
    state=playState;
  }
}

void drawWin() {
  background(turkos);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Du vann!\n"+
    "Starta om genom att klicka på fönstret, eller tryck på valfri tangent", width/2, height/2);
  if (mousePressed||keyPressed) {
    felGissningar =0;
    state=playState;
  }
}
