
mtype = { caffe, cappuccino, tea, nessuna }

local mtype bevanda_erogata = nessuna;
local int credito = 0;
bool erogatore = true;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
/* chan prezzo = [0] of { short } */
chan scelta = [0] of { mtype, short }
chan credito_agg  = [0] of { bool }
chan bicchiere = [0] of { mtype }
chan ok = [0] of { bool }

init 
{
	atomic {
	run Utente();
	run Gettoniera();
	run Tastierino();
	run Erogatore()
	}
}

proctype Utente()
{
	/* mtype bevanda_erogata = nessuna;	*/

	do
	:: monete!5
	:: monete!10
	:: monete!20
	:: monete!50
	:: monete!100
	:: monete!200
	
	:: bevanda!caffe
	:: bevanda!cappuccino
	:: bevanda!tea

	:: bicchiere?bevanda_erogata -> assert(bevanda_erogata != nessuna)	
	od
}

proctype Gettoniera()
{
	byte m;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
	do
	:: monete?m ->  if
		:: erogatore == true -> 
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		atomic {
		credito = credito + m;
		credito_agg!true;
		}
		:: else ->
			skip;
		fi
		/* (erogatore == true); */
		/* ok?true */
	od
}

proctype Tastierino()
{
	do
	:: atomic {bevanda?caffe -> 
		if
		:: (erogatore == true) ->
		 	scelta!caffe(35);
		:: else ->
			skip;
		fi
		ok?true; 
		}
/*	:: atomic {bevanda?cappuccino ->
		 scelta!cappuccino(50);
		ok?true
		}
	:: atomic {bevanda?tea ->
		 scelta!tea(40);
		ok?true
		} */
	od
}

proctype Erogatore()
{
	mtype s = nessuna;
	short p = 0;

	do		
	:: atomic { scelta?s(p) -> erogatore = false; }
		if 
		:: (credito >= p) ->
			bicchiere!s;
			credito = credito - p;
			s = nessuna
		:: else -> skip
		fi; 
		atomic {
		erogatore = true; 
		ok!true; }
	:: atomic { credito_agg?true -> erogatore = false; }
		if 
		:: (credito >= p && s != nessuna) ->
			bicchiere!s;
			credito = credito - p;
			s = nessuna
		:: else -> skip
		fi;
		atomic {
		erogatore = true; 
		ok!true; }
	od
}

ltl p2 { <>(credito >= 35 && scelta == caffe) }

ltl p1 { [](credito >= 35 && scelta == caffe ->  bevanda_erogata == nessuna U bevanda_erogata == caffe)}

/*ltl t1 { [](Gettoniera:p >= 0) }*/
/* ltl t1 { [](scelta == caffe  ->  (bevanda_erogata == nessuna) U (bevanda_erogata == caffe)) } */























































