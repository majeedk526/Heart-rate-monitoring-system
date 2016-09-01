
byte pinSignal = A0;

#define thresh 250

volatile unsigned int s = 0;
volatile int P = thresh;
volatile int T = thresh;
volatile unsigned long numSample=0, pNumSample=0;

volatile int IBI = 600; // time b/w heart beat (in ms)
volatile int N = 0;
volatile boolean isPulse = false;
volatile bool isFirstBeat = true, isSecondBeat = false; 
volatile unsigned int rate[10];
volatile unsigned long BPM = 0;

int i = 0;

word runningTotal = 0;


void setup() {
  // put your setup code here, to run once:

  interruptSetup();
  Serial.begin(115200);

}

void loop() {
  // put your main code here, to run repeatedly:
  delay(20);
}


void interruptSetup(){
  
  TCCR2A = 0x02; //sets WGM21
  TCCR2B = 0x06; //sets CS21 and CS22
  OCR2A = 0x7C; // set o/p compare register to 124 
  TIMSK2 = 0x02; //enables timer interrupt
  sei();  // enable interrupts
  
  }

ISR(TIMER2_COMPA_vect){
  
  s = analogRead(pinSignal);
  Serial.print("s = ");
  Serial.print(s);

  numSample += 2;
  N = numSample - pNumSample;

  Serial.print("\tN = ");
  Serial.print(N);
  
  if(s>P){P=s;}

 if(s<thresh && N> (IBI/5)*3){
    if(s<T){T=s;}
 }
  
  //Serial.print("\tP = ");
  //Serial.print(P);
  //Serial.print("\tT = ");
  //Serial.print(T);
  
  Serial.print("\tIBI");
  Serial.print(IBI);
    
  if(N>250){

    if(s>thresh && N > (IBI/5)*3){
  
         isPulse = true;
         IBI = numSample - pNumSample;
         pNumSample = numSample;     
      }
    
    }


    if(isFirstBeat){
        isFirstBeat  = false;
        isSecondBeat = true;
        sei();
        return;
      }

   if(isSecondBeat){
      isSecondBeat = false;
      isFirstBeat = true;

      for(i=0; i <9; i++){
          rate[i] = IBI;
        }  
    }

  runningTotal = 0;
  for(i=0; i<8; i++){
      rate[i] = rate[i+1];
      runningTotal += rate[i];
    }

    rate[9] = IBI;
    runningTotal += rate[9];
    runningTotal /= 10;
    BPM = 15000/runningTotal;
    Serial.print("\tBPM = ");
    Serial.println(BPM);


  }
