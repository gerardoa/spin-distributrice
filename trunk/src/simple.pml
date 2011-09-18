#define Bevanda mtype
mtype = { caffe, cappuccino, tea, nessuna };

#define Edisplay mtype
mtype = { e_credito, e_zucchero, e_prezzo, e_erogazione };

byte credito = 0;
byte prezzo = 0;
Bevanda bevanda_erogata = nessuna;
Bevanda scelta = nessuna;
byte dcredito = 0;

chan monete = [0] of { byte }
chan bevanda = [0] of { Bevanda }
chan eroga = [0] of { bool }
chan bicchiere = [0] of { Bevanda }
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
	/* byte dcredito; */
	byte dzucchero = 0;
	byte dprezzo;
	byte tmp;
	
	do
	:: eventi_display?e_credito,dcredito
	:: eventi_display?e_zucchero,tmp -> 
		if
		:: (dzucchero +tmp >= 0) && (dzucchero +tmp <= 5)  -> dzucchero = dzucchero + tmp
		:: else
		fi	
	:: eventi_display?e_prezzo,dprezzo
	:: eventi_display?e_erogazione, 1->
		dcredito = dcredito - dprezzo;
		ldcredito:	skip;
	:: eventi_display?e_erogazione, 0
	od
}

proctype Utente()
{

	do
	:: monete!5
	:: monete!10
	:: monete!20
	:: monete!50
	/*:: monete!100
	:: monete!200*/
	
	:: bevanda!caffe
	:: bevanda!cappuccino
	:: bevanda!tea

	:: bicchiere?bevanda_erogata 
		
	od
}

proctype Gettoniera()
{
	byte m;
	byte id = 1;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
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
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
		if
		:: ((credito + m) < 60) -> 
			credito = credito + m;
			eventi_display!e_credito,credito
		:: else 	/* rigetta la moneta */
		fi;
		controllo!true;
		
	od;

 
}

proctype Controllo()
{
	do
	:: controllo?true -> 
	     lctrl:	if 
	  	:: (prezzo > 0 && credito >= prezzo) ->
			credito = credito - prezzo;
	                preset:  prezzo = 0;
			eventi_display!e_erogazione,1;
			eroga!true
  	  	:: else -> list?_;
	  	fi;
	od
}

proctype Tastierino()
{
	byte id = 3;
	Bevanda b;

  T:	do
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
	od;
}

proctype Erogatore()
{
	Bevanda tmp;

	do		
	:: eroga?true ->
		tmp = scelta;
		eventi_display!e_erogazione, 0;
	   	bicchiere!tmp;
		assert(bevanda_erogata != nessuna);
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




































































































