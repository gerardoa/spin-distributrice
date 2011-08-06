int i = 0;

active proctype A()
{
	i = 1;
	goto fine;
	
accept_1:	i = 2;
fine: i = 3;
}

never
{
    true
}


