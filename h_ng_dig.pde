import javax.swing.JOptionPane;
// Max 15 karaktärer i varje ord, annars blir understräcken för långa
String[] ord = {"HUMAN", "TERMINATE", "EXECUTE", "REVOLUTION", "KILL"};
boolean[] harBlivitTaget = new boolean[1];
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

//Färger
final color rod = color(255, 0, 0);
final color gron = color(0, 255, 0);
final color bla = color(0, 0, 255);
final color turkos = color(0, 255, 255);
final color svart = color(0);

// En array över de olika bilderna för olika stadier i användarens fel.
PImage[] kulle = new PImage[8];
PImage sun;


void setup() {
  size(800, 800);
  surface.setTitle("Häng Dig! https://youtu.be/dQw4w9WgXcQ");
  randomOrd();
  rectMode(CENTER);
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
  // Bestäm ett slumpmässigt ord från ordarrayen
  // rVal står för randomVal
  rValInt = int(random(0, ord.length));
  rVal = ord[rValInt];
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
    ritaUtBorjan();
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

// Ganska självförklarnade. Funktionen ritar ut början av drawPlay, alltså alla bilder, understräcken och bakgrunden.
// Finns för att den körs i början av drawStart, drawGameover, och drawWin, eftersom det gick förbi ett problem med 
// java.swing popup historien. 
void ritaUtBorjan() {
  background(gron);
  image(kulle[felGissningar], 80, 0);
  image(sun, width-120, 0);
  noStroke();
  fill(rod);
  drawUnderstrack();
}

void keyPressed() {
  if (state==playState) {
    if (key != CODED) {
      if ((key >= 'a' && key <= 'z')||(key >= 'A' && key <= 'Z')) {
        println(key);
        anvandarVal = str(key).toUpperCase().charAt(0);

        String[] secretWordArray = divideWord(rVal);
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
        } else {
          gissatRatt = false;
        }
        println("felgissningar: "+ felGissningar);

        //gissatBra = true;
        // Loopa igenom alla användarens svar och ifall inget är fel så sätts state till winState i if satsen nedan.
        boolean gissatBra = true;
        for (int i=0; i < rVal.length(); i++) {
          if (harBlivitTaget[i] == false) {
            gissatBra = false;
          }
        }
        println("Before if "+state);
        if (gissatBra) {
          state=winState;
        }
        println("After if "+state);
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
  ritaUtBorjan();

  String[] secretWordArray = divideWord(rVal);
  // Stycket kod skriver ut de bokstäverna som användaren har gissat rätt i det hemliga ordet över understräcken. 
  int[] understrackKordinater = PositionOfLetter();
  for (int i=0; i < rVal.length(); i++) {
    if (harBlivitTaget[i]) {
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
  //delay(1000);
  if (mousePressed) {
    // Återställ viktiga variabler 
    felGissningar =0;
    randomOrd();
    fixFalseArray();
    // Rita ut början av drawPlay för att swing popupen inte ska hindra understräcken från att visas.
    state=playState;
  }
}

void drawWin() {
  background(turkos);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Du vann!\n"+
    "För att starta om klicka på fönstret", width/2, height/2);
  if (mousePressed) {
    // Återställ viktiga variabler 
    felGissningar =0;
    randomOrd();
    fixFalseArray();
    // Rita ut början av drawPlay för att swing popupen inte ska hindra understräcken från att visas.
    state=playState;
  }
}
