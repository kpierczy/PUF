entity SIGNAL_SIMP is				-- deklaracja sprzegu 'SIGNAL_SIMP'
  port (					-- deklaracja portow wejscia-wyjscia
    argA	:in  bit;			-- deklaracja portu wejsciowego 'argA'
    argB	:in  bit;			-- deklaracja portu wejsciowego 'argB'
    rezultat	:out bit			-- deklaracja portu wyjsciowego 'rezultat'
  );
end SIGNAL_SIMP;	 			-- zakonczenie deklaracji sprzegu

architecture cialo of SIGNAL_SIMP is		-- deklaracja ciala 'cialo' architektury

  signal przewod1, przewod2 : bit;		-- deklaracja sygnalow

begin						-- poczatek czesci wykonawczej architektury

       rezultat	<= przewod2 xor argB ; 		-- przypisanie rezultatu operacji
  et1: przewod1	<= argA ; 			-- przypisanie portu wejsciowego z etykieta
       przewod2	<= not(przewod1);		-- przypisanie innego sygnalu

end cialo;					-- zakonczenie deklaracji ciala 'cialo'
