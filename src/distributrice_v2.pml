
mtype = { caffe, cappuccino, tea, nessuna, credito_agg }

local mtype bevanda_erogata = nessuna;
local int credito = 0;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
/* chan prezzo = [0] of { short } */
chan erogatore = [2] of { mtype, short }
chan bicchiere = [0] of { mtype }
chan ok[2] = [0] of { bool }

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
	:: atomic { monete?m -> 
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		credito = credito + m;
		erogatore!credito_agg;
		}
		ok[0]?true
	od
}

proctype Tastierino()
{
	do
	:: atomic {bevanda?caffe -> 
		 	erogatore!caffe(35);
		}
		ok[1]?true; 
	:: atomic {bevanda?cappuccino ->
		 erogatore!cappuccino(50);
		}
		ok[1]?true; 
	:: atomic {bevanda?tea ->
		 erogatore!tea(40);
		}
		ok[1]?true; 
	od
}

proctype Erogatore()
{
	mtype s = nessuna;
	mtype scelta = nessuna;
	short p = 0;
	short prezzo = 0;

	do		
	:: erogatore?s(p) -> 
		if 
		:: (s != credito_agg) ->
			scelta = s;
			prezzo = p
		:: else -> skip 
		fi;
		if 
		:: (credito >= prezzo) ->
			bicchiere!s;
			credito = credito - prezzo;
			scelta = nessuna
		:: else -> skip
		fi; 

		if 
		:: (s != credito_agg) ->
			ok[1]!true
		:: else -> ok[0]!true 
		fi
	od
}

/* ltl p2 { <>(credito >= 35 && scelta == caffe) } */

/* ltl p1 { [](credito >= 35 && scelta == caffe ->  bevanda_erogata == nessuna U bevanda_erogata == caffe)} */

/*ltl t1 { [](Gettoniera:p >= 0) }*/
/* ltl t1 { [](scelta == caffe  ->  (bevanda_erogata == nessuna) U (bevanda_erogata == caffe)) } */




























































