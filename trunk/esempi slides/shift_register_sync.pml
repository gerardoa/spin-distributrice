

proctype  modulo(chan inC; chan outC)
{ 
  byte stato = 0;
 byte x;
do
:: atomic{(stato == 0); inC?x; stato=1}
:: atomic{(stato == 1); outC!x; stato=0}
 od
}

init {
 byte Y;
chan trasm0 = [0] of {byte};
chan trasm1 = [0] of {byte};
chan trasm2 = [0] of {byte};
run modulo(trasm0, trasm1);
run modulo(trasm1, trasm2);
trasm0!15;
trasm0!16;

trasm2?Y;
trasm2?Y;
}
