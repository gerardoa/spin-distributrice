int i = 0;
int p = 0;

active proctype A()
{
	i = 1;
	i = 3;
	i = 2;
	if 
	:: (true) -> i = 7
	:: (true) -> skip
	fi;
	i = 4;
	i = 2;
	i = 5;
}

active proctype B()
{
	if
	:: (true) -> p++
	fi;
}

ltl p1 { [](i == 4 -> ( i <= 4 U i == 5)) }
ltl t1 { [](( i <= 4 U i == 5)) }
ltl p2 { <>(i == 7) }












