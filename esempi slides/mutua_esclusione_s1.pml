byte X;
byte flag1 = 0;
byte flag2 = 0;

proctype A()
{
  inizio: flag1 = 1;
  (flag2 == 0);
  X = X + 1;
  X = X - 1;
 flag1 = 0;
goto inizio
}

proctype B()
{
  inizio: flag2 = 1;
  (flag1 == 0);
  X = X + 1;
  X = X - 1;
 flag2 = 0;
goto inizio
}

init{ run B(); run A()}


