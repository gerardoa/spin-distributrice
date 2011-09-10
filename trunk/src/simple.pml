
mtype = { caffe, cappuccino, tea, nessuna, credito_agg }

local mtype bevanda_erogata = nessuna;
local byte credito = 0;
byte prezzo = 0;
mtype scelta = nessuna;
bool mutex_tastierino = true;
bool flag_eroga = false;
bool flag_scelta = false;
bool mutex = true;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
/* chan prezzo = [0] of { short } */
chan eroga = [0] of { bool }
chan bicchiere = [0] of { mtype }
chan ok = [0] of { bool }
chan verifica = [0] of { bool }
chan controllo = [0] of { bool }


init 
{
	atomic {
	run Utente();
	run Gettoniera();
	run Tastierino();
	run Controllo();
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
		sc: skip;
	:: bevanda!cappuccino
	:: bevanda!tea

	:: bicchiere?bevanda_erogata 
		
	od
}

proctype Gettoniera()
{
	byte m;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
 G:	do
	:: monete?m ->			
		atomic { mutex == true -> mutex = false }
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		
		if
		:: ((credito + m) < 256) -> 
			credito = credito + m
		:: else
		fi;
		controllo!true;
		
	od;

 
}

proctype Controllo()
{
              do
	:: controllo?true -> 
	  if 
	  :: (prezzo > 0 && credito >= prezzo) ->
		credito = credito - prezzo;
		prezzo = 0;
		eroga!true
  	  :: else -> mutex = true;
	  fi;
	od
}

proctype Tastierino()
{
	do
	::bevanda?caffe -> atomic { mutex == true;  mutex = false }
		 prezzo = 35;
		 scelta = caffe;
		 controllo!true
	::bevanda?cappuccino -> atomic { mutex == true;  mutex = false }
		 prezzo = 50;
		 scelta = cappuccino;
		controllo!true
	::bevanda?tea -> atomic { mutex == true;  mutex = false }
		 prezzo = 40;
		 scelta = tea;
		controllo!true
	od
}

proctype Erogatore()
{
	mtype tmp;

	do		
	:: eroga?true ->
		tmp = scelta;
		bicchiere!tmp;
		assert(bevanda_erogata != nessuna);
		scelta = nessuna;
		bevanda_erogata = nessuna;		   		
		mutex = true;	
	od
}

/* ltl p2 { <>(credito >= 35 && scelta == caffe) } */

ltl p1 { []((credito >= 35 && (scelta == nessuna U scelta == caffe)) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl p2 { []((credito == 35 && (scelta == nessuna U scelta == tea)) ->  (bevanda_erogata == nessuna U bevanda_erogata == tea))}

/*ltl t1 { [](Gettoniera:p >= 0) }*/
ltl t1 { []( bevanda_erogata == nessuna U bevanda_erogata == caffe ) } 
ltl t2 { []((credito >= 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl t3 { []((credito == 30 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}

















































































