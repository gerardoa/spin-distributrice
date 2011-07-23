
mtype = { caffe, cappuccino, tea, nessuna }

local int credito = 0;
mtype scelta = nessuna;
local mtype bevanda_erogata = nessuna;

chan monete = [0] of { byte }
chan bevanda = [0] of { mtype }
chan tg = [0] of { short }
chan eroga  = [0] of { bool }
chan bicchiere = [0] of { mtype }

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

	:: bicchiere?bevanda_erogata	
	od
}

proctype Gettoniera()
{
	int prezzo = 0;
	/* int credito = 0; */
	byte m;
	
/* diminuzione credito all'erogazione e alla richiesta di resto */
	do
	:: monete?m ->
		assert(m == 5 || m == 10 || m == 20 || m == 50 || m == 100 || m == 200);
		credito = credito + m;
		if
		:: (prezzo > 0 && credito >= prezzo) ->
			eroga!true	
		:: else -> skip
		fi
	:: tg?prezzo ->
		if 
		:: (credito >= prezzo) ->
			eroga!true
		fi
	od
}

proctype Tastierino()
{
	do
	:: bevanda?caffe ->
		 scelta = caffe;
		 tg!35
	:: bevanda?cappuccino ->
		 scelta = cappuccino;
		 tg|50
	:: bevanda?tea ->
		 scelta = tea;
		 tg|40
	od
}

proctype Erogatore()
{
	do
	:: eroga?_ ->
		bicchiere!scelta;
		scelta = nessuna

	od
}

ltl p1 { [](((credito >= 35) && (scelta == caffe))  ->  ((bevanda_erogata == nessuna) U (bevanda_erogata == caffe))) }

ltl t1 { [](credito >= 0) }













































