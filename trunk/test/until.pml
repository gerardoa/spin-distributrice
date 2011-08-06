byte i = 0;
int p = 0;
int k = 0;

mtype = {nes, caf, tea}
mtype bev = nes; 

proctype A()
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
	if
	:: (true) -> p = 10;
	:: (true) -> p = 10;
	fi;
	i = 7;
}

active proctype B()
{
	bev = nes;
l1:	bev = nes; 
	atomic { 
		bev = tea;
		bev = nes;
	 }
	 do :: true -> i++ od
	/* bev = caf; */
}

proctype C()
{
	do
	:: true -> p++
	od
}


ltl p1 { []( (k == 1 && (i <= 3 U i == 7)) -> (p <= 8 U p == 10)) }

ltl t1 { [](bev == nes U bev == caf) }





