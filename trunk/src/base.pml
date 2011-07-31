
mtype = { caffe, cappuccino, tea, nessuna, credito_agg }

local mtype bevanda_erogata = nessuna;
local short credito = 0;
short prezzo = 0;
mtype scelta = nessuna;
bool mutex_tastierino = true;
bool flag_eroga = false;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
/* chan prezzo = [0] of { short } */
chan eroga = [0] of { bool }
chan bicchiere = [0] of { mtype }
chan ok[2] = [0] of { bool }
chan verifica = [0] of { bool }


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

	:: bicchiere?bevanda_erogata -> 
		assert(bevanda_erogata != nessuna);
		bevanda_erogata = nessuna
	od
}

proctype Gettoniera()
{
	byte m;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
 G:	do
	:: monete?m -> 
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		credito = credito + m;
		mutex_tastierino = false;
		goto Controllo	
	:: atomic {verifica?true -> mutex_tastierino = false }
		goto Controllo
	od;

 Controllo:
	if 
	:: (prezzo > 0 && credito >= prezzo) ->
		credito = credito - prezzo;
		prezzo = 0;
		eroga!true
	:: else -> 
		if
		:: (flag_eroga == false) -> mutex_tastierino = true;
		:: else -> skip
		fi
	fi;
	goto G;
}

proctype Tastierino()
{
	do
	:: bevanda?caffe -> 
		atomic {
		 (mutex_tastierino == true);
		 prezzo = 35;
		 scelta = caffe;
		}
		verifica!true
	:: bevanda?cappuccino ->
		atomic {
		 (mutex_tastierino == true);
		 prezzo = 50;
		 scelta = cappuccino;
		}
		verifica!true
	:: bevanda?tea ->
		atomic {
		 (mutex_tastierino == true);
		 prezzo = 40;
		 scelta = tea;
		}
		verifica!true
	od
}

proctype Erogatore()
{
	mtype tmp;

	do		
	:: atomic { eroga?true -> flag_eroga = true }
		tmp = scelta;
		scelta = nessuna;
		flag_eroga = false;
		bicchiere!tmp;
			mutex_tastierino = true
	od
}

/* ltl p2 { <>(credito >= 35 && scelta == caffe) } */

ltl p1 { []((credito >= 35 && (scelta == nessuna U scelta == caffe)) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}

/*ltl t1 { [](Gettoniera:p >= 0) }*/
/* ltl t1 { [](scelta == caffe  ->  (bevanda_erogata == nessuna) U (bevanda_erogata == caffe)) } */






































































