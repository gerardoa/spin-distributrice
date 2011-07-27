int i = 0;
int p = 0;

active proctype A()
{
	i = 1;
	i = 2;
	i = 4;
	i = 3;
	i = 2;
	i = 5;
}

active proctype B()
{
	do
	:: (true) -> 
		atomic{
		  (i == 3);
		  p = 5;
		}
	od;
}

ltl p1 { [](i == 4 -> ( i <= 4 U i == 5)) }
ltl p2 { <>(i == 7) }












