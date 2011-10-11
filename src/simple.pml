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

  	do
	:: atomic { bevanda?b -> list!id; }
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
	   end: 	skip;
	:: atomic { c_zucchero?z -> list!id; }
	    	 if
		 :: (id == 3) -> 
			list?<3>
		 :: (id == 4) -> 
			list?<4>
		fi;
	  	if
		:: (id == 3) -> id = 4
		:: (id == 4) -> id = 3
		fi;

		if 
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


ltl pmutex { [](!(Gettoniera@pmutex && Tastierino@pmutex)) }
ltl pmutexe { <>((Gettoniera@pmutex && Tastierino@pmutex)) }
ltl c1 { []((credito >= 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl cp1 { []((credito >= 50 && scelta == cappuccino ) ->  (bevanda_erogata == nessuna U bevanda_erogata == cappuccino))}
ltl t1 { []((credito >= 40 && scelta == tea ) ->  (bevanda_erogata == nessuna U bevanda_erogata == tea))}
ltl c1e { []((credito < 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}

/* ltl c2 { []((credito >= 35 && Utente@c2 ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))} */

ltl test1 { [] (Tastierino@start -> <> Tastierino@end) } 

ltl c3 { []( (credito == 100 && Tastierino@lcontrollo && scelta == caffe ) -> (credito == 100 U credito == 65) ) }

ltl c4 { []((Controllo@preset && prezzo == 35) -> (bevanda_erogata == nessuna U bevanda_erogata == caffe)) }
ltl cp4 { []((Controllo@preset && prezzo == 50) -> (bevanda_erogata == nessuna U bevanda_erogata == cappuccino)) }	
ltl next { [](( (Gettoniera@check1 +  Gettoniera@check2 + Tastierino@check1 + Tastierino@check2 == 2) && len(list) == 2) -> X(Gettoniera@pmutex || Tastierino@pmutex)) }
ltl p1 { []<> (Controllo@lctrl) }
ltl p2 { [] (len(list) < 4) }
ltl p3 { []<> (dcredito == credito)}
ltl p4 { [] (Display@ldcredito ->  (dcredito == credito)) }
ltl p5 { [] (Controllo@cresto -> (resto <= credito))} 
	ltl p6 { [] !(zucchero == 6) } 








































































































