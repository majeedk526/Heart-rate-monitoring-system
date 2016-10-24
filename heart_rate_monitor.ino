
byte pinSignal = A0;

volatile unsigned int thresh = 275;

volatile unsigned int s = 0;
volatile int P = thresh;
volatile int T = thresh;
volatile unsigned long numSample=0, pNumSample=0; //previous number sample

volatile int IBI = 400; // time b/w heart beat (in ms)
volatile int N = 0;
volatile boolean isPulse = false;
volatile bool isFirstBeat = true, isSecondBeat = false; 
volatile unsigned int rate[10];
volatile unsigned long BPM = 0;

volatile int valnum = 0;

int i = 0;

word runningTotal = 0;


void setup() {
  // put your setup code here, to run once:
  pinMode(13, OUTPUT);
  interruptSetup();
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(20);
}


void interruptSetup() {

  TCCR2A = 0x02; //sets WGM21
  TCCR2B = 0x06; //sets CS21 and CS22
  OCR2A = 0x7C; // set o/p compare register to 124 
  TIMSK2 = 0x02; //enables timer interrupt
  sei();  // enable interrupts
}

ISR(TIMER2_COMPA_vect) {
  //Reading analog signal from sensor
  s = analogRead(pinSignal);

  //Sampling, selecting every 7th Reading 
  if (valnum == 7) {
    Serial.print("s_");
    Serial.println(s);
    valnum = 0;
  } else {
    valnum++;
  }

  numSample += 2;
  N = numSample - pNumSample;

  //Update Peak Value
  if (s>P && s>thresh) {
    P=s;
  }

  //Update trough value
  if (s<thresh && N> (IBI/5)*3) {
    if (s<T) {
      T=s;
    }
  }

  if (N>250) {

    //Check For high Pulse
    if (s>thresh && !isPulse && N > (IBI/5)*3) {
      digitalWrite(13, HIGH);
      isPulse = true;
      IBI = numSample - pNumSample;
      pNumSample = numSample; 

      // detect first beat
      if (isFirstBeat) {
        isFirstBeat  = false;
        isSecondBeat = true;
        sei();
        return;
      }

      // update IBI on second beat
      if (isSecondBeat) {
        isSecondBeat = false;
        for (i=0; i<10; i++) {
          rate[i] = IBI;
        }
      }

      // Average out IBI value
      runningTotal = 0;
      for (i=0; i<8; i++) {
        rate[i] = rate[i+1];
        runningTotal += rate[i];
      }

      rate[9] = IBI;
      runningTotal += rate[9];
      runningTotal /= 10;

      // Calculate BPM
      BPM = 50000/runningTotal;
      // send BPM
      Serial.print("b_");
      Serial.println(BPM);
    }
  } 

  //update trough value
  if (s<thresh && isPulse) {
    digitalWrite(13, LOW);
    isPulse = false;
    thresh = (P-T)/2 + T;
    P = thresh;
    T = thresh;
  }
}

