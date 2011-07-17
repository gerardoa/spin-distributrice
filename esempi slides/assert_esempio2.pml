byte x = 1;

proctype A()
{
atomic{
 (x == 1);
 x = x + 1;
 assert(x == 2)
}
}

proctype B()
{
atomic {
 (x == 1);
 x = x - 1;
 assert(x == 0)
}
}

init {
 run A(); 
 run B()
}
