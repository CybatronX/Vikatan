const int Pin1 = 8;
const int Pin2 = 9;
const int Pin3 = 3;
const int Pin4 = 4;
const int Pin5 = 5;

void setup() {
  Serial.begin(9600);
  
  pinMode(Pin1, OUTPUT);
  pinMode(Pin2, OUTPUT);
  pinMode(Pin3, OUTPUT);
  pinMode(Pin4, OUTPUT);
  pinMode(Pin5, OUTPUT);
}

void loop(){
  
  digital Write(Pin1, LOW);
  digital Write(Pin2, LOW);
  digital Write(Pin3, LOW);
  digital Write(Pin4, LOW);
  digital Write(Pin5, LOW);
  
  if(Serial.available())
  {
     ch = Serial.read();
     if(ch == '1')
     {
       digital.Write(Pin1, HIGH);
       delay(500);
       digital.Wite(Pin1, LOW);
     }
  }
}
