import javax.swing.JOptionPane;
import processing.sound.*;
// Max 15 karaktärer i varje ord, annars blir understräcken för långa
boolean[] harBlivitTaget = new boolean[1];
char[] gissadeBokstaver = new char[0];
String rVal;
int rValInt;
String anvandarValStr;
char anvandarVal;
boolean rValUdda;
int mittenBokstav;
final int distansLangd = 30;
final int distansMellanrum = 20;
final int distansTot = distansLangd+distansMellanrum;

//States
final int startState = 1;
final int playState = 2;
final int gameoverState = 3;
final int winState = 4;
int state = startState;

// Användarfel
boolean gissatRatt=false;
int felGissningar = 0;
int antalGissningar = 0;

//Färger
final color rod = color(255, 0, 0);
final color gron = color(0, 255, 0);
final color bla = color(0, 0, 255);
final color turkos = color(0, 255, 255);
final color svart = color(0);

// En array över de olika bilderna för olika stadier i användarens fel.
PImage[] kulle = new PImage[8];
PImage sun;

// Sound
SoundFile boing;

void setup() {
  size(800, 800);
  surface.setTitle("Häng Dig! https://youtu.be/dQw4w9WgXcQ");
  randomOrd();
  rectMode(CENTER);
  // Tack Elias för ljudet!
  boing = new SoundFile(this, "boing.mp3");

  // Images
  for (int i=0; i < 8; i++) {
    kulle[i] = loadImage("Kulle"+i+".png");
  }
  sun = loadImage("sun.png");
  sun.resize(120, 101 );

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

void randomOrd() {
  // Bestäm ett slumpmässigt ord genom ett externt API
  String[] word = loadStrings("https://random-word-api.herokuapp.com/word?number=1");
  word[0] = word[0].replace("[", "").replace("]", "").replace('"', '%').replace("%", "").toUpperCase();
  rVal = word[0];
  println(rVal);

  // Kolla ifall ordet är udda eller jämnt antal karaktärer
  if (rVal.length() % 2 == 0) {
    rValUdda = false;
    mittenBokstav = rVal.length()/2;
  } else {
    rValUdda = true;
    mittenBokstav = int(rVal.length()/2)+1;
  }

  harBlivitTaget = expand(harBlivitTaget, rVal.length());
  for (int i=0; i < rVal.length(); i++) {
    harBlivitTaget[i]=false;
  }
}

// Återvänder en array där "understräcken" ska vara för det hemliga ordet
int[] PositionOfLetter() {
  int antalBokstaver = rVal.length();
  int[] kordinaterForUnderstrack = new int[antalBokstaver];
  int mitten = (width/2);
  if (rValUdda) {
    kordinaterForUnderstrack[mittenBokstav-1] = mitten;
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

void draw() {
  // Ett switch statement som gör det möjligt med olika play-states. 
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

// Jag skrev en funktion för att ändra harBlivitTaget till helt false efter en omgång
// Kändes snyggare att lägga en linje kod i drawWin och drawGameover än 5
void fixFalseArray() {
  for (int i=0; i < rVal.length(); i++) {
    if (harBlivitTaget[i] == true) {
      harBlivitTaget[i] =false;
    }
  }
}

// Loopa igenom det hemliga ordet, skapa en array med allting för att därefter ändra om allting till lowercase förutom den första bokstaven
// Därefter kommer den sista forloopen att bygga en sträng utifrån arrayen
String storForstaBokstav() {
  char[] rValStorBokstavArray = new char[rVal.length()];
  rValStorBokstavArray[0] = rVal.toUpperCase().charAt(0);
  String rValUtskriv = "";

  for (int i=1; i < rVal.length(); i++) {
    rValStorBokstavArray[i] = rVal.toLowerCase().charAt(i);
  }
  for (int i=0; i<rVal.length(); i++) {
    rValUtskriv =rValUtskriv + rValStorBokstavArray[i];
  }
  return rValUtskriv;
}

void keyPressed() {
  if (state==playState) {
    if (key != CODED) {
      if ((key >= 'a' && key <= 'z')||(key >= 'A' && key <= 'Z')) {

        // Blocket har en counter för att hålla koll på hur många gissningar användaren har gjort
        // Kommer att expandera en array som innehåller alla gissningar för att sedan lägga in nästa gissning
        // Därefter kommer allting att sorteras i bokstavsordning. 
        anvandarVal = str(key).toUpperCase().charAt(0);
        antalGissningar++;
        gissadeBokstaver = expand(gissadeBokstaver, antalGissningar);
        gissadeBokstaver[antalGissningar-1] = anvandarVal;
        gissadeBokstaver = sort(gissadeBokstaver);

        String[] secretWordArray = rVal.split("");
        // Loopa igenom alla bokstäver i det hemliga ordet och ändra harBlivitTaget till true ifall användaren gissade rätt. 
        for (int i=0; i < rVal.length(); i++) {
          if (secretWordArray[i].charAt(0) == anvandarVal && harBlivitTaget[i] == false) {
            harBlivitTaget[i] = true;
            gissatRatt=true;
          }
        }

        // Höj en counter ifall användaren har gissat fel, annars så sätts gissatRatt till false så att det funkar att loopa igenom blocket ovan igen. 
        if (gissatRatt == false) {
          felGissningar +=1;
          boing.play();
        } else {
          gissatRatt = false;
        }

        // Loopa igenom alla användarens svar och ifall inget är fel så sätts state till winState i if satsen nedan.
        boolean gissatBra = true;
        for (int i=0; i < rVal.length(); i++) {
          if (harBlivitTaget[i] == false) {
            gissatBra = false;
          }
        }
        if (gissatBra) {
          state=winState;
        }
      }
    }
  }
}

void drawPlay() {
  if (felGissningar >= 7) {
    state=gameoverState;
  }
  boolean gissatBra = true;
  for (int i=0; i < rVal.length(); i++) {
    if (harBlivitTaget[i] == false) {
      gissatBra = false;
    }
  }
  if (gissatBra) {
    state=winState;
  }
  background(gron);
  image(kulle[felGissningar], 80, 0);
  image(sun, width-120, 0);
  noStroke();
  fill(rod);
  drawUnderstrack();

  String[] secretWordArray = rVal.split("");
  // Stycket kod skriver ut de bokstäverna som användaren har gissat rätt i det hemliga ordet över understräcken. 
  int[] understrackKordinater = PositionOfLetter();
  for (int i=0; i < rVal.length(); i++) {
    if (harBlivitTaget[i]) {
      text(""+secretWordArray[i], float(understrackKordinater[i]), (height/4.0)*3-height*0.02125);
    }
  }
  skrivGissningar();
}

// Skriv ut användarens gissningar
// Skapa en sträng som innehåller samma sak som arrayen gissadeBokstaver, för att sedan skriva ut den.
void skrivGissningar() {
  String gissadeBokstaverUtskriv = "";
  for (int i=0; i< gissadeBokstaver.length; i++) {
    gissadeBokstaverUtskriv =gissadeBokstaverUtskriv + gissadeBokstaver[i];
  }
  textAlign(LEFT, LEFT);
  text("Du har gissat på: " + gissadeBokstaverUtskriv, 50, (height/8)*7);
  textAlign(CENTER, CENTER);
}

void drawGameover() {
  background(rod);
  image(kulle[7], 80, 0);
  fill(svart);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("GAME OVER!\n"+
    "Starta om genom att klicka på fönstret, eller tryck på valfri tangent", width/2, height-height/3.5);
  textAlign(LEFT, LEFT);
  text("Rätt ord: "+storForstaBokstav(), 50, 50);
  textAlign(CENTER, CENTER);
  skrivGissningar();
  if (mousePressed) {
    // Återställ viktiga variabler 
    felGissningar =0;
    randomOrd();
    fixFalseArray();
    state=playState;
  }
}

void drawWin() {
  background(turkos);
  fill(svart);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Du vann!\n"+
    "För att starta om klicka på fönstret", width/2, height/2);
  textAlign(LEFT, LEFT);
  text("Rätt ord: "+storForstaBokstav(), 50, 50);
  textAlign(CENTER, CENTER);
  skrivGissningar();
  if (mousePressed) {
    // Återställ viktiga variabler 
    felGissningar =0;
    randomOrd();
    fixFalseArray();
    state=playState;
  }
}
