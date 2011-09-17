byte i = 0;

active proctype A()
{
	a: i = 1;	

}

ltl p1 { [](A@a -> i == 1) }




