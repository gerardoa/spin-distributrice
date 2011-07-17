byte x = 1;

proctype A()
{
 (x == 1);
 x = x + 1;
 assert(x == 2)
}

proctype B()
{
 (x == 1);
 x = x - 1;
 assert(x == 0)
}

init {
 run A(); 
 run B()
}
