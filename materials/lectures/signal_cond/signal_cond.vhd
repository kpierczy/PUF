entity SIGNAL_COND is					-- deklaracja sprzegu 'SIGNAL_SIMP'
  port (						-- deklaracja portow wejscia-wyjscia
    argA	:in  natural range 0 to 15;		-- deklaracja portu wejsciowego 'argA'
    argB	:in  natural range 0 to 15;		-- deklaracja portu wejsciowego 'argB'
    rezultat	:out natural range 0 to 15;		-- deklaracja portu wyjsciowego 'rezultat'
    wybor	:out natural range 0 to 3		-- deklaracja portu wyjsciowego 'wybor'
  );
end SIGNAL_COND;	 				-- zakonczenie deklaracji sprzegu

architecture cialo of SIGNAL_COND is			-- deklaracja ciala 'cialo' architektury

  signal decyzja : natural range 0 to 3;		-- deklaracja sygnalu

begin							-- poczatek czesci wykonawczej architektury

  decyzja <= 0 when argA - 5 > argB else		-- wybor 0 gdy 'argA - 5 > argB'
             1 when argA     > argB else		-- wybor 1 gdy 'argA > argB'
  	     2 when argB - 7 > argA else		-- wybor 2 gdy 'argB - 7 > argA'
             3;						-- wybor 3 w pozostalych przypadkach

  rezultat <= argA - argB when decyzja = 0 else		-- wybor 'argA - argB' gdy 'argA - 5 > argB'
              argA        when decyzja = 1 else		-- wybor 'argA' gdy 'argA > argB'
  	      argB - argA when decyzja = 2 else		-- wybor 'argB - argA' gdy 'argB - 7 > argA'
              7;					-- wybor '7' w pozostalych przypadkach

  wybor <= decyzja;					-- przypisanie sygnalu do portu wyjsciowego

end cialo;						-- zakonczenie deklaracji ciala 'cialo'
