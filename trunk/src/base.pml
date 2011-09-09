
mtype = { caffe, cappuccino, tea, nessuna, credito_agg }

local mtype bevanda_erogata = nessuna;
local byte credito = 0;
byte prezzo = 0;
mtype scelta = nessuna;
bool mutex_tastierino = true;
bool flag_eroga = false;
bool flag_scelta = false;

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

	do
	:: monete!5
	:: monete!10
	:: monete!20
	:: monete!50
	:: monete!100
	:: monete!200
	
	:: bevanda!caffe ->
		sc: skip 
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
	:: atomic { monete?m ->  atomic { (flag_scelta == false); mutex_tastierino = false; } }
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		/*(flag_scelta == false);*/
		if
		:: ((credito + m) < 256) -> 
			credito = credito + m
		:: else
		fi;
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
		:: else
		fi
	fi;
	goto G;
}

proctype Tastierino()
{
	do
	::atomic { bevanda?caffe -> flag_scelta = true; }
		atomic { 
		 (mutex_tastierino == true);
		 prezzo = 35;
		 scelta = caffe; 
		 flag_scelta = false;
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
		bicchiere!tmp;
	   	scelta = nessuna;
		flag_eroga = false;
		mutex_tastierino = true
	od
}

/* ltl p2 { <>(credito >= 35 && scelta == caffe) } */

ltl p1 { []((credito >= 35 && (scelta == nessuna U scelta == caffe)) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl p2 { []((credito == 35 && (scelta == nessuna U scelta == tea)) ->  (bevanda_erogata == nessuna U bevanda_erogata == tea))}

/*ltl t1 { [](Gettoniera:p >= 0) }*/
ltl t1 { []( bevanda_erogata == nessuna U bevanda_erogata == caffe ) } 
ltl t2 { []((credito >= 35 && Utente@sc) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}












































































