
byte pinSignal = A0;

#define thresh 512

volatile unsigned int s = 0;
volatile int P = thresh;
volatile int T = thresh;
volatile unsigned long numSample=0, pNumSample=0;

volatile int IBI = 600; // time b/w heart beat (in ms)
volatile int N = 0;


void setup() {
  // put your setup code here, to run once:

  interruptSetup();
  Serial.begin(115200);

}

void loop() {
  // put your main code here, to run repeatedly:

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
  
  if(s>P){P=s;}

 if(s<thresh && N> (IBI/5)*3){
    if(s<T){T=s;}
 }
  
  Serial.print("\tP = ");
  Serial.print(P);
  Serial.print("\tT = ");
  Serial.println(T);
  
  }
