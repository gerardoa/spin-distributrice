chan ab = [0]  of { bool }

int i = 0;

active proctype A()
{
	skip;
	f1 : i = 0;
	ab!1;
	f2: skip
}

active proctype B()
{
	do
	:: ab?1 -> skip
	:: (i == 0) -> skip
	od
}

ltl p1 { <> A@f1 } /* l'istruzione (i = 0) rimane eseguibile in questo modo con w.f. non da' errore*/
ltl p2 { <> A@f2 } /* l'istruzione (ab!1) NON rimane eseguibile e la w.f. non aiuta in questo caso*/




