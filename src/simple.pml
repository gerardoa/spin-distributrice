
mtype = { caffe, cappuccino, tea, nessuna }

byte credito = 0;
byte prezzo = 0;
mtype bevanda_erogata = nessuna;
mtype scelta = nessuna;
bool mutex = true;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
chan eroga = [0] of { bool }
chan bicchiere = [0] of { mtype }
chan controllo = [0] of { bool }

chan list = [3] of { byte };


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
	   c2: skip;
	:: bevanda!cappuccino
	:: bevanda!tea

	:: bicchiere?bevanda_erogata 
		
	od
}

proctype Gettoniera()
{
	byte m;
	byte id = 1;
	byte k;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
 G:	do
	:: atomic { monete?m ->			
		list!id; } 
	  	if
		     :: (id == 1) -> list?<1>
		     :: (id == 0) -> list?<0>
		fi;

		id = 1 - id; 
		/* assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200); */
	 pmutex:  skip;
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
  	  :: else -> list?_;
	  fi;
	od
}

proctype Tastierino()
{
	byte id = 3;
	byte b;

  T:	do
	:: atomic { bevanda?b -> list!id; }
	    start:	 if
		 :: (id == 3) -> list?<3>
		 :: (id == 4) -> list?<4>
		fi;
		if
		:: (id == 3) -> id = 4
		:: (id == 4) -> id = 3
		fi;
		if
		:: (b == caffe) ->
			prezzo = 35;
			scelta = caffe;
		:: (b == cappuccino) ->
			prezzo = 50;
			scelta = cappuccino;
		:: (b == tea) ->
			prezzo = 40;
			scelta = tea;
		fi;
		controllo!true;
	   end: skip;
	od;
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
		list?_;	
	od
}


/*
ltl pmutex { [](!(Gettoniera@pmutex && Tastierino@mutexp)) }
ltl pmutexe { <>((Gettoniera@pmutex && Tastierino@mutexp)) }
*/
ltl c1 { []((credito >= 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}
ltl cp1 { []((credito >= 50 && scelta == cappuccino ) ->  (bevanda_erogata == nessuna U bevanda_erogata == cappuccino))}
ltl t1 { []((credito >= 40 && scelta == tea ) ->  (bevanda_erogata == nessuna U bevanda_erogata == tea))}
ltl c1e { []((credito < 35 && scelta == caffe ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))}

ltl c2 { []((credito >= 35 && Utente@c2 ) ->  (bevanda_erogata == nessuna U bevanda_erogata == caffe))} 

ltl test1 { [](Tastierino@start -> (<>Tastierino@end)) } 

















































































