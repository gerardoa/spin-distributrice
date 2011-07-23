int p;

init {
	printf("hello world\n");
	p = 6;
	if 
	:: p = 4 ->
		p = 1;
		p = 9
	:: p = 6
	:: p = 3
	fi;
	p = 10
}

ltl name { []((p == 4) ->  (<> (p == 7))) }









