int i = 0;
int p = 0;
int k = 0;

active proctype A()
{
	i = 1;
	i = 100;
	p = 100;
	i = 1;
	k = 2;
	p = 8;
	k = 1;
	i = 3;
	i = 3;
	p = 8;
	i = 7;
	i = 0;
	p = 3;
	i = 4;
	p = 10;
}

proctype B()
{
	if
	:: (true) -> p++
	fi;
}

ltl p1 { [](i == 4 -> ( i <= 4 U i == 5)) }
ltl t1 { [](( i <= 4 U i == 5)) }
ltl p2 { <>(i == 7) }

ltl p3 { []( (k == 1 && (i <= 3 U i == 7)) -> (p <= 8 U p == 10)) }

ltl p4 { []( k == 1 && (i <= 3 U i == 7) -> p == 4) }

ltl p5 { []( k == 1 -> (i <= 3 U i == 7)) }














