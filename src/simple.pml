#define NM 4

#define Bevanda mtype
mtype = { caffe, cappuccino, tea, nessuna };

#define Edisplay mtype
mtype = { e_credito, e_zucchero, e_prezzo, e_erogazione, e_fine_erogazione };

#define Zucchero mtype
mtype = { piu, meno };

byte credito = 0;
byte prezzo = 0;
byte zucchero = 0;
byte resto;
Bevanda bevanda_erogata = nessuna;
Bevanda scelta = nessuna;
byte dcredito = 0;
byte cmonete[NM];

chan monete = [0] of { byte }
chan bevanda = [0] of { Bevanda }
chan c_zucchero = [0] of { Zucchero }
chan eroga = [0] of { bool }
chan bicchiere = [0] of { Bevanda, byte }
chan controllo = [0] of { bool }
chan eventi_display = [0] of { Edisplay, byte }
	
chan list = [4] of { byte };

init 
{
	atomic {
	run Display();
	run Utente();
	run Gettoniera();
	run Tastierino();
	run Controllo();
	run Erogatore()
	}
}

proctype Display()
{
	/* byte dcredito; (dichiarata globale per la verifica delle proprietà) */
	byte dzucchero = 0;
	byte dprezzo;
	int tmp;
	byte dresto;
	
	do
	:: eventi_display?e_credito,dcredito
	:: eventi_display?e_zucchero,tmp -> 
		dzucchero = dzucchero + tmp
	:: eventi_display?e_prezzo,dprezzo
	:: eventi_display?e_erogazione, dresto->
		dcredito = dcredito - dprezzo - dresto;
		ldcredito:	skip;
	:: eventi_display?e_fine_erogazione, 0 ->
		dzucchero = 0
	od
}

proctype Utente()
{
	byte lvl_zucchero;

	do
	:: monete!5
	:: monete!10
	:: monete!20
	:: monete!50
	
	:: bevanda!caffe
	:: bevanda!cappuccino
	:: bevanda!tea
	:: c_zucchero!piu
	:: c_zucchero!meno

	:: bicchiere?bevanda_erogata, lvl_zucchero
	od
}

proctype Gettoniera()
{
	byte m;
	byte id = 1;
	byte i;

 G:	do
	:: atomic { monete?m ->			
		list!id; } 
	    start:	if
		     :: (id == 1) -> 
	    check1:		list?<1>
		     :: (id == 0) -> 
	    check2:		list?<0>
		fi;

	  pmutex: id = 1 - id; 
		assert(m == 5 || m == 10 || m == 20 || m == 50);
		if
		:: ((credito + m) <= 100 ) -> 
			for (i : 0..NM-1) {
				if 
				:: (cmonete[i] > 255) -> goto G
				:: else
				fi
			}
			/* aggiornamento credito */
			credito = credito + m;
			eventi_display!e_credito,credito;
			/* aggiornamento numero di monete presenti */
			if
			:: (m == 5) -> i = 3;
			:: (m == 10) -> i = 2;
			:: (m == 20) -> i = 1;
			:: (m == 50) -> i = 0;
			fi;
			cmonete[i] = cmonete[i] + 1;
		:: else 	/* rigetta la moneta */
		fi;
		controllo!true;
	fine:	skip;
	od; 
}

proctype Controllo()
{
	byte r;
	byte i;
	byte vmonete[NM];

	vmonete[0] = 50;
	vmonete[1] = 20;
	vmonete[2] = 10;
	vmonete[3] = 5;
	

	do
	:: controllo?true -> 
	     lctrl:	if 
	  	:: (prezzo > 0 && credito >= prezzo) ->
			r = credito - prezzo;
			credito = credito - prezzo;
	                preset:  prezzo = 0;

			resto = 0;
			for (i : 0..NM-1) {
				if
				:: ((r / vmonete[i]) <= cmonete[i] ) ->
					resto = resto + (r / vmonete[i]) * vmonete[i];
 					r = r % vmonete[i];
					cmonete[i] = cmonete[i] - (r / vmonete[i]);
				:: else ->
					resto = resto + (cmonete[i] * vmonete[i]);
					r = r - (cmonete[i] * vmonete[i]);
					cmonete[i] = 0;
				fi
			}
		cresto:	credito = credito - resto;
			
			eventi_display!e_erogazione,resto;

		     p5:	skip;
			eroga!true
  	  	:: else -> list?_;
	  	fi;
	od;
}

proctype Tastierino()
{
	byte id = 3;
	Bevanda b;
	Zucchero z;
	int zi;
	bool bz;

  	do
	:: atomic { bevanda?b -> list!id; }
		bz = 0;
	    	goto start;
	    bev:	if
		:: (b == caffe) ->
			prezzo = 35;
			scelta = caffe;
			eventi_display!e_prezzo,35
		:: (b == cappuccino) ->
			prezzo = 50;
			scelta = cappuccino;
			eventi_display!e_prezzo,50
		:: (b == tea) ->
			prezzo = 40;
			scelta = tea;
			eventi_display!e_prezzo,40
		fi;
         lcontrollo:	controllo!true;
	   fine: 	skip;
	:: atomic { c_zucchero?z -> list!id; }
		bz = 1;
	    	goto start;
	   zuc:	if 
		:: (z == piu) -> zi = 1;
		:: (z == meno) -> zi = -1;
		fi;
		if
		:: (zucchero +zi >= 0) && (zucchero +zi <= 5)  -> 
			zucchero = zucchero + zi;
			eventi_display!e_zucchero,zi
		:: else
		fi;
		list?_;
	od;

	start:	 if
		 :: (id == 3) -> 
	check1:		list?<3>
		 :: (id == 4) -> 
	check2:		list?<4>
		fi;
	pmutex:	if
		:: (id == 3) -> id = 4
		:: (id == 4) -> id = 3
		fi;
		if 
		:: (bz == 0) -> goto bev;
		:: (bz == 1) -> goto zuc;
		fi;
}

proctype Erogatore()
{
	Bevanda tmp;

	do		
	:: eroga?true ->
		tmp = scelta;
		eventi_display!e_fine_erogazione, 0;
	   	bicchiere!tmp, zucchero;
		assert(bevanda_erogata != nessuna);
		zucchero = 0;
		scelta = nessuna;
		bevanda_erogata = nessuna;		   		
		list?_;	
	od
}

/* garantire mutua esclusione tra la gettoniera e il tastierino  */
ltl pmutex { [](!(Gettoniera@pmutex && Tastierino@pmutex)) }
/* controprova della precedente, in questo caso bisogna ottenere un errore */
ltl pmutexe { <>((Gettoniera@pmutex && Tastierino@pmutex)) }

/* assicurano che qualora le condizioni necessarie per erogare una bevanda siano soddisfatte, 
allora la bevanda selezionata sara' la prossima ad essere erogata */
ltl c1 { []((credito >= 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl cp1 { []((credito >= 50 && scelta == cappuccino ) ->  (bevanda_erogata == nessuna U bevanda_erogata == cappuccino))}
ltl t1 { []((credito >= 40 && scelta == tea ) ->  (bevanda_erogata == nessuna U bevanda_erogata == tea))}
/* controprova di c1, in questo caso ci si aspetta un errore */
ltl c1e { []((credito < 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}

/* prima o poi la gettoniera riuscirà ad ottenere il mutex ed a espletare tutte le sue operazioni */
ltl g1 { [] (Gettoniera@start -> <> Gettoniera@fine) } 

/* il credito che verra' scalato per il caffe e' 35 */
ltl c3 { []( (credito == 100 && Tastierino@lcontrollo && scelta == caffe ) -> (credito == 100 U credito == 65) ) }
/* se il credito scalato e' 35, allora la bevanda erogata sara' caffe */
ltl c4 { []((Controllo@preset && prezzo == 35) -> (bevanda_erogata == nessuna U bevanda_erogata == caffe)) }
ltl cp4 { []((Controllo@preset && prezzo == 50) -> (bevanda_erogata == nessuna U bevanda_erogata == cappuccino)) }	

/* se gettoniera e tastierino sono entrambi in attesa del mutext uno dei due lo ricevera' nello stato successivo */
ltl next { [](( (Gettoniera@check1 +  Gettoniera@check2 + Tastierino@check1 + Tastierino@check2 == 2) && len(list) == 2) -> X(Gettoniera@pmutex || Tastierino@pmutex)) }
/* proprieta' di progresso: la macchina effettuera' il controllo infinitamente spesso */
ltl p1 { []<> (Controllo@lctrl) }
/* safety: la lunghezza della lista sarà sempre minore di 4 */
ltl p2 { [] (len(list) < 4) }
/* è sempre vero che prima o poi il credito mostrato dal display sara' uguale al credito interno */
ltl p3 { []<> (dcredito == credito)}
/* aggiornando il credito del display con il prezzo locale e il resto comunicato dal controllo si ottine il credito reale */
ltl p4 { [] (Display@ldcredito ->  (dcredito == credito)) }
/* il resto restituito è sempre minore o ugale del credito rimanente*/
ltl p5 { [] (Controllo@cresto -> (resto <= credito))} 
/* reachability: lo zucchero in qualche comportamento raggiungerà il livello 5 (questa proprietà deve risultare in un errore) */
ltl p6 { [] !(zucchero == 5) } 








































































































