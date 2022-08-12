void setup() {
  String my_str = "This is my string.";
  
  Serial.begin(9600);
  
  // (1) print the string
  Serial.println(my_str);
  
  // (2) change the string to upper-case
  my_str.toUpperCase();
  Serial.println(my_str);
  
  // (3) overwrite the string
  my_str = "My new string.";
  Serial.println(my_str);
  
  // (4) replace a word in the string
  my_str.replace("string", "Arduino sketch");
  Serial.println(my_str);
  
  // (5) get the length of the string
  Serial.print("String length is: ");
  Serial.println(my_str.length());
}

void loop() {
}

